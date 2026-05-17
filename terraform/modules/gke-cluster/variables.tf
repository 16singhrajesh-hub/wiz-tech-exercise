variable "project_id" {
    description = "GCP Project ID"
    type = string
}

variable "region" {
    description = "GCP Region"
    type = string
}

variable "cluster_name" {
    description = "GCP Cluster Name"
    type = string
}

variable "network" {
    description = "VPC Network Name"
    type = string
}

variable "subnetwork" {
    description = "Subnetwork Name"
    type = string
}

variable "pods_range_name" {
    description = "Secondary range name for pods"
    type = string
}

variable "services_range_name" {
    description = "Secondary range names for services"
    type = string
}

variable "node_machine_type" {
    description = "Machine type for GKE nodes"
    type = string
    default = "n1-standard-2"
}

variable "node_count" {
    description = "Initial Number of Nodes"
    type = number
    default = 2
}

variable "min_node_count" {
    description = "Minimum Number of Nodes"
    type = number
    default = 1
}

variable "max_node_count" {
    description = "Maximum Number of Nodes"
    type = number
    default = 4

}

variable "environment" {
    description = "Environment Name"
    type = string
}