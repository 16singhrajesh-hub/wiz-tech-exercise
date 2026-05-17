output "bucket_name" {
    description = "Cloud Storage bucket name"
    value = google_storage_bucket.backup.name
}

output "bucket_url" {
    description = "Cloud Storage bucket URL"
    value = google_storage_bucket.backup.url
}

output "bucket_self_link" {
    description = "Cloud Storage Bucket self Link"
    value = google_storage_bucket.backup.self_link
}