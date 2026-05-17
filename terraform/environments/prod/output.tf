
output "vpc_name" {
    description = "VPC network Name"
    value = google_compute_network.vpc.name
}

output "mongodb_public_ip" {
    description = "MongoDB VM Public IP"
    value = module.mongodb_vm.public_ip
}

output "mongodb_private_ip" {
    description = "MongoDB VM Private IP"
    value = module.mongodb_vm.private_ip
}

output "gke_cluster_name" {
    description = "GKE Cluster Name"
    value = module.gke_cluster.cluster_name
}

output "gke_cluster_endpoint" {
    description = "GKE Cluster endpoint"
    value = module.gke_cluster.cluster_endpoint
    sensitive = true
}

output "backup_bucket_name" {
    description = "Cloud storage backup bucket name"
    value = module.storage-backup.bucket_name
}

output "artifact_registry_url" {
    description = "Artifact Registry Repository URL"
    value = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.app.repository_id}"

}

output "configure_kubectl" {
    description = "Command to Configure kubectl"
    value = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.gcp_region} --project ${var.gcp_project_id}"
}

output "mongodb_connection_string" {
    description = "MongoDB Connection String (internal)"
    value = "mongodb://admin:${var.mongo_root_password}@${module.mongodb_vm.private_ip}:27017/tododb"
    sensitive = true
}