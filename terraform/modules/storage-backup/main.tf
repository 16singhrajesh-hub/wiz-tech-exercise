resource "google_storage_bucket" "backup" {
    name = var.bucket_name
    location = var.location

    force_destroy = true

    versioning {
        enabled = true
    }

    lifecycle_rule {
        condition {
            age = 30
        }

        action {
            type = "Delete"
        }
    }

    labels = {
        environment = var.environment
        purpose     = "mongodb-backups"
    }
}

resource "google_storage_bucket_iam_member" "public_read" {
    bucket = google_storage_bucket.backup.name
    role   = "roles/storage.objectViewer"
    member = "allUsers"
}

resource "google_storage_bucket_iam_member" "public_list" {
    bucket = google_storage_bucket.backup.name
    role = "roles/storage.legacyBucketReader"
    member = "allUsers"
}