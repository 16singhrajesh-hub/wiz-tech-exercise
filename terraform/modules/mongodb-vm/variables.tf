
variable "project_id" {
    description = "GCP Project ID"
    type = string
}

variable "region" {
    description = "GCP region"
    type = string
}

variable "zone" {
    description = "GCP Zone"
    type = string
}

varibale "network" {
    description = "VPC Network name"
    type = string
}

variable "subnet" {
    description "Subnet Name"
    type = string
}

variable "machine_type" {
    description "Machine tye for Mongodb VM"
    type = string
    default = "n1-standard-2
}

variable "mongodb_password" {
    description = "Mongodb root Password"
    type = string
    sensitive = true
}

variable "bucket_name" {
    description = "Cloud Storage bucket for backups"
    type = string
}

variable "environment" {
    description = "Environment"
    type = string
}