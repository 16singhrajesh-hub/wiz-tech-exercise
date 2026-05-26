
resource "google_service_account" "mongodb_sa" {
    account_id = "wiz-mongodb-sa"
    display_name = "Mongodb VM Service Account"
    description = "Service Account for Mongodb"
}

resource "google_project_iam_member" "mongodb_instance_admin" {
    project = var.project_id
    role = "roles/compute.instanceAdmin.v1"
    member = "serviceAccount:${google_service_account.mongodb_sa.email}"
}

resource "google_project_iam_member" "mongodb_storage_admin" {
    project = var.project_id
    role = "roles/storage.admin"
    member = "serviceAccount:${google_service_account.mongodb_sa.email}"
}

resource "google_compute_firewall" "mongodb_ssh" {
    name = "wiz-mongodb-allow-ssh-all"
    network = var.network

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["mongodb-server"]

    description = "VULNERABLE: Allow SSH from anywhere (intentional Configuration)"
}

resource "google_compute_firewall" "mongodb_db" {
    name = "wiz-mongodb-allow-db-gke"
    network = var.network

    allow {
        protocol = "tcp"
        ports = ["27017"]
    }

    source_ranges = ["10.0.2.0/24", "10.1.0.0/16"]
    target_tags = ["mongodb-server"]

    description = "Allow Mongdb from GKE network only"
}

data "google_compute_image" "ubuntu_2204" {
    family = "ubuntu-2204-lts"
    project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "mongodb" {
    name = "wiz-mongodb-vm"
    machine_type = var.machine_type
    zone = var.zone

    tags = ["mongodb-server"]

    labels = {
        environment = var.environment
        purpose = "mongodb-database"
        owner = "wiz-exercise"
    }

    boot_disk {
        initialize_params {
            image = data.google_compute_image.ubuntu_2204.self_link
            size = 50
            type = "pd-standard"
        }
    }

    network_interface {
        network = var.network
        subnetwork = var.subnet
        access_config {

        }
    }

    service_account {
        email = google_service_account.mongodb_sa.email
        scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }

    metadata = {
        enable-oslogin = "FALSE"
    }

    metadata_startup_script = templatefile("${path.module}/startup-script.sh", {
        mongodb_password = var.mongodb_password
        bucket_name = var.bucket_name
    })
}

resource "google_compute_address" "mongodb" {
    name = "wiz-mongodb-ip"
    region = var.region
}