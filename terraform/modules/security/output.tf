output "audit_log_bucket" {
    description = "Audit logs bucket name"
    value = google_storage_bucket.audit_logs.name
}

output "audit_log_sink" {
    description = "Audit log sink name"
    value = google_logging_project_sink.audit_sink.name
}