terraform {
    required_version = ">=1.5.0"

    required_provider {
        google = {
            source = "hashicorp/google"
            version = "~> 5.0"
        }
        google-beta = {
            source = "hashicorp/google-beta"
            version = "~> 5.0"
        }
    }

    backend "gcs" {
        bucket = "wiz-exercise-terraform-state"
        prefix = "prod/terraform.tfstate"
    }
}

provider "google" {
    project = var.gcp_project_id
    region = var.gcp_region
}

provider "google-beta" {
    project = var.gcp_project_id
    region = var.gcp_region
}

resource "google_project_service" "required_apis" {
    for_each = toset([
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudlogging.googleapis.com",
    "cloudmonitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "clouddebugger.googleapis.com",
    "storage-api.googleapis.com",
    ])
    service = each.key
    disable_on_destory = false
}

resouce "google_compute_network" "vpc" {
    name = "wiz-exercise-pvc"
    auto_create_subnetworks = false
    depends_on [google_project_service.required_apis]
}

resources "google_compute_subnetwork" "public_subnet" {
    name = "wiz-public-subnet"
    ip_cidr_range = var.public_subnet_cidr
    region = var.gcp_region
    network = google_compute_network.vpc.id

    log_config {
        aggregation_interval = "INTERVAL_10_MIN"
        flow_sampling = 0.5
        metadata = "INCLUDE_ALL_METADATA"
    }
}

resource "google_compute_subnetwork" "private_subnet" {
    name = "wiz-private-subnet"
    ip_cidr_range = var.private_subnet_cidr
    region = var.gcp_region
    network = google_compute_network.vpc.id

    private_ip_google_access = true

    secondary_ip_range {
        range_name = "gke-pods"
        ip_cidr_range = var.gke_pods_cidr
    }

    secondary_ip_range {
        range_name = "gke-services"
        ip_cidr_range = var.gke_services_cidr
    }

    log_config {
        aggregation_interval = "INTERVAL_10_MIN"
        flow_sampling = 0.5
        metadata = "INCLUDE_ALL_METADATA"
    }

}

module "mongodb_vm" {
    source = "../../modules/mongodb_vm"

    project_id = var.gcp_project_id
    region = var.gcp_region
    zone = var.gcp_zone
    network = google_compute_network.vpc.name
    subnet = google_compute_subnetwork.public_subnet.name
    mongo_password = var.mongo_root_password
    machine_type = var.mongodb_machine_type
    bucket_name = module.storage_backup.bucket_name
    environment = var.environment
    
    depends_on = [google_project_service.required_apis]
}



module "gke_cluster" {
    source = "../../modules/gke-cluster"

    project_id = var.gcp_project_id
    region = var.gcp_region
    cluster_name = var.cluster_name
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.private_subnets.name
    pods_range_name = "gke-pods"
    services_range_name = "gke-services"
    node_machine_type = var.gke_node_machine_type
    node_count = var.gke_node_count
    min_node_count = var.gke_min_node_count
    max_node_count = var.gke_max_node_count
    environment = var.environment

    depends_on = [google_project_service.required_apis]
}

module "storage_backup" {
    source = "../../modules/storage_backup"

    project_id = var.gcp_project_id
    bucket_name = "wiz-mongodb-backups-${var.gcp_project_id}
    location = var.gcp_region
    environment = var.environment

    depends_on = [google_project_service.required_apis]
}

module "security" {
    source = "../../modules/security"

    project_id = var.gcp_project_id
    region = var.gcp_region
    environment = var.environment

    depends_on = [google_project_service.required_apis]
}

resource "google_artifact_registry_repository" "app" {
    location = var.gcp_region
    repository_id = "wiz-app"
    description = "Wiz exercise Docker repository"
    format = "DOCKER"

    labels = {
        environment = var.environment
        purpose = "wiz-exercise"
    }

    depends_on = [google_project_service.required_apis]
}

resource "google_compute_router_nat" "nat" {
    name = "wiz-nat"
    router = google_compute_router.router.name
    region = var.gcp_region
    nat_ip_allocation_option = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

    log_config {
        enable = true
        filter = "ERRORS_ONLY"
    }
}
