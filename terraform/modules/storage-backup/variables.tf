variable "project_id" {
    description = "GCP Project ID"
    type = string
}

variable "bucket_name" {
    description = "Cloud Storage bucket name"
    type = string
}

variable "location" {
    description = "Bucket Location"
    type = string
}

variable "environment" {
    description = "Environment Name"
    type = string
}