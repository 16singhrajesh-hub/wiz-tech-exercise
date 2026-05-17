varibale "project_id" {
    description = "GCP Project ID"
    type = string
}

varibale "region" {
    description = "GCP Region"
    type = string
}

varibale "cluster_name" {
    description = "GCP Cluster Name"
    type = string
}

varibale "network" {
    description = "VPC Network Name"
    type = string
}

varibale "subnetwork" {
    description = "Subnetwork Name"
    type = string
}

varibale "pods_range_name" {
    description = "Secondary range name for pods"
    type = string
}

varibale "services_range_name" {
    description = "Secondary range names for services"
    type = string
}

varibale "node_machine_type" {
    description = "Machine type for GKE nodes"
    type = string
    default = "n1-standard-2"
}

varibale "node_count" {
    description = "Initial Number of Nodes"
    type = number
    default = 2
}

varibale "min_node_count" {
    description = "Minimum Number of Nodes"
    type = number
    default = 1
}

varibale "max_node_count" {
    description = "Maximum Number of Nodes"
    type = number
    default = 4

}

variable "environment" {
    description = "Environment Name"
    type = string
}