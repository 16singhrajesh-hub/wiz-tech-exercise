
resource "google_project_iam_audit_config" "audit_all" {
    project = var.project_id
    service = "allServices"

    audit_log_config {
        log_type = "ADMIN_READ"
    }
}

resource "google_logging_project_sink" "audit_sink" {
    name = "wiz-audit-log-sink"
    destination = "storage.googleapis.com/${google_storage_bucket.audit_logs.name}"

    filter = <<EOF
    logName:"cloudaudit.googleapis.com"
    EOF

    unique_writer_identity = true
}

resource "google_storage_bucket" "audit_logs" {
    name = "wiz-audit-logs-${var.project_id}"
    location = var.region

    force_destroy = false

    uniform_bucket_level_access = true

    versioning {
        enabled = true
    }

    lifecycle_rule {
        condition {
            age = 90
        }
        action {
            type = "Delete"
        }
    }

    labels = {
        environment = var.environment
        purpose = "audit-logs"
    }
}

resource "google_storage_bucket_iam_member" "audit_log_writer" {
    bucket = google_storage_bucket.audit_logs.name
    role = "roles/storage.objectCreator"
    member = google_logging_project_sink.audit_sink.writer_identity
}

resource "google_monitoring_alert_policy" "failed_ssh_login" {
    display_name = "Failed SSH Login Attempts"
    combiner = "OR"

    conditions {
        display_name = "SSH authenticataion failure"

        condition_matched_log {
            filter = <<EOF
            resource.type="gce_instance"
            logName="projects/${var.project_id}/logs/syslog"
            "Failed password"
            EOF
        }
    }

    notification_channels = []

    alert_strategy {
        auto_close = "604800s" 
        notification_rate_limit {
            period = "300s" # Minimum allowed period is 300s (5 minutes)
        }
    }

    documentation {
        content = "Multiple failed SSH login attempts detected. This could indicate a brute force attach."
        mime_type = "text/markdown"
    }
}

resource "google_monitoring_alert_policy" "public_bucket_access" {
    display_name = "Public Cloud Storage Bucket Access"

    combiner = "OR"

    conditions {
        display_name = "Public bucket access detected"

        condition_matched_log {
            filter = <<EOF
            resource.type="gcs_bucket"
            protoPayload.authenticationInfo.principalEmail="allUsers"
            EOF
        }
    }

    notification_channels = []

    alert_strategy {
        auto_close = "604800s"
        notification_rate_limit {
            period = "300s" # Minimum allowed period is 300s (5 minutes)
        }
    }

    documentation {
        content = "A cloud storage bucket is being accessed by all Users. This is a security risk."
        mime_type = "text/markdown"
    }
}

resource "google_monitoring_alert_policy" "privileged_role_assignment" {
    display_name = "Privileged IAM Role Assignment"

    combiner = "OR"

    conditions {
        display_name = "Admin or Owner role Granted"

        condition_matched_log {
            filter = <<EOF
            protoPayload.methodName="google.iam.admin.v1.SetIamPolicy" AND
            (protoPayload.request.policy.bindings.role="roles/owner" OR
            protoPayload.request.policy.bindings.role="roles/editor" OR
            protoPayload.request.policy.bindings.role:"Admin")

            EOF
        }
    }

    notification_channels = []

    alert_strategy {
        auto_close = "604800s"
        notification_rate_limit {
            period = "300s" # Minimum allowed period is 300s (5 minutes)
        }
    }

    documentation {
        content = " A privileged IAM role (owner, editor or admin) as assigned. Review this change"
        mime_type = "text/markdown"
    }
}