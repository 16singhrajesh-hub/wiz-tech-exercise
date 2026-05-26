variable "gcp_project_id" {
    description = "GCP Project ID"
    type = string
}


variable "gcp_region" {
    description = "GCP Region"
    type = string
    default = "us-west1"
}

variable "gcp_zone" {
    description = "GCP Zone"
    type = string
    default = "us-west1-a"
}

variable "environment" {
    description = "Environment Name"
    type = string
    default = "wiz-exercise"
}

variable "owner_name" {
    description = "Owner Name for Labeling"
    type = string
}

variable "public_subnet_cidr" {
    description = "Public subnet CIDR block"
    type = string
    default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
    description = "Private Subnet CIDR Block"
    type = string
    default = "10.0.2.0/24"
}

variable "gke_pods_cidr" {
    description = "GKE Pods CIDR Range"
    type = string
    default = "10.1.0.0/16"
}

variable "gke_services_cidr" {
    description = "GKE Service CIDR Range"
    type = string
    default = "10.2.0.0/16"
}

variable "mongodb_machine_type" {
    description = "Mongodb VM Machine Type"
    type = string
    default = "n1-standard-2"
}

variable "mongo_root_password" {
    description = "Mongodb Root Password"
    type = string
    sensitive = true
}

variable "cluster_name" {
    description = "GKE Cluster Name"
    type = string
    default = "wiz-exercise-cluster"
}

variable "gke_node_machine_type" {
    description = "GKE Node Machine Type"
    type = string
    default = "n1-standard-2"
}

variable "gke_node_count" {
    description = "Initial Number of GKE Nodes"
    type = number
    default = 2
}

variable "gke_min_node_count" {
    description = "Minimum Number of GKE nodes"
    type = number
    default = 1
}

variable "gke_max_node_count" {
    description = "Maximum Number of GKE Nodes"
    type = number
    default = 4
}
