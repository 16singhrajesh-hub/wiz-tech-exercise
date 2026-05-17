
output "instance_name" {
    description = "MongoDB VM Instance name"
    value = google_compute_instance.mongodb.name
}

output "public_ip" {
    description = "MongoDB VM public IP"
    value = google_compute_instance.mongodb.network_interface[0].access_config[0].nat_ip
}

output "private_ip" {
    description = "Mongodb VM private IP"
    value = google_compute_instance.mongodb.network_interface[0].network_ip
}

output "service_account_email" {
    description = "Service Account email "
    value = google_service_account.mongodb_sa.email
}