
#Service Account for GKE nodes

resource "google_service_account" "gke_nodes" {
    account_id = "wiz-gke-nodes-sa"
    display_name = "GKE Nodes Service Account"
}

resource "google_project_iam_member" "gke_logging" {
    project = var.project_id
    role = "roles/logging.logWriter"
    member = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_monitoring" {
    project = var.project_id
    role = "roles/monitoring.metricWriter"
    member = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_monitoring_viewer" {
    project = var.project_id
    role = "roles/monitoring.viewer"
    member = "serviceAccount:${google_service_account.gke_nodes.email}"
}


resource "google_project_iam_member" "gke_artifact_registry" {
    project = var.project_id
    role = "roles/artifactregistry.reader"
    member = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_node_default_role" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

#GKE Cluster

resource "google_container_cluster" "primary" {

    name = var.cluster_name
    location = var.region

    remove_default_node_pool = true
    initial_node_count = 1
    deletion_protection = false
    network = var.network
    subnetwork = var.subnetwork

    ip_allocation_policy {
        cluster_secondary_range_name = var.pods_range_name
        services_secondary_range_name = var.services_range_name
    }

    private_cluster_config {
        enable_private_nodes = true
        enable_private_endpoint = false
        master_ipv4_cidr_block = "172.16.0.0/28"
    }

    master_authorized_networks_config {
        cidr_blocks {
            cidr_block = "0.0.0.0/0"
            display_name = "All networks"
        }
    }

    workload_identity_config {
        workload_pool = "${var.project_id}.svc.id.goog"
    }

    master_auth {
        client_certificate_config {
            issue_client_certificate = false
        }
    }

    network_policy {
        enabled = false
        provider = "PROVIDER_UNSPECIFIED"
    }

    addons_config {
        http_load_balancing {
            disabled = false
        }

        horizontal_pod_autoscaling {
            disabled = false
        }

        network_policy_config {
            disabled = true
        }
    }

    logging_config {
        enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
    }

    monitoring_config {
        enable_components = ["SYSTEM_COMPONENTS"]
        managed_prometheus {
            enabled = false
        }
    }

    maintenance_policy {
        daily_maintenance_window {
            start_time = "03:00"
        }
    }

    resource_labels = {
        environment = var.environment
        managed-by = "terraform"
    }

    binary_authorization {
        evaluation_mode = "DISABLED"
    }
}

resource "google_container_node_pool" "primary_nodes" {
    name = "${var.cluster_name}-node-pool"
    location = var.region
    cluster = google_container_cluster.primary.name
    node_count = var.node_count

    autoscaling {
        min_node_count = var.min_node_count
        max_node_count = var.max_node_count
    }

    management {
        auto_repair = true
        auto_upgrade = false
    }

    node_config {
        machine_type = var.node_machine_type

        service_account = google_service_account.gke_nodes.email
        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]

        labels = {
            environment = var.environment
        }

        tags = ["gke-node", var.cluster_name]

        shielded_instance_config {
            enable_secure_boot = false
            enable_integrity_monitoring = false
        }

        
    }
}