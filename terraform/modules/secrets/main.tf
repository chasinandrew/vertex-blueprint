resource "google_secret_manager_secret" "secret_basic" {
  secret_id = var.secret_id # "secret"
  project   = var.project_id
  labels    = var.labels
  replication {
    user_managed {
      replicas {
        location = var.location
      }
    }
  }
  # [CCM-REQ-01]  Rotate secrets automatically
  rotation {
    next_rotation_time = var.next_rotation_time
    rotation_period    = var.rotation_period
  }
  topics {
    name = data.google_pubsub_topic.topic.id
  }
  lifecycle {
    ignore_changes = [rotation["next_rotation_time"]]
  }
  expire_time = var.expire_time
  depends_on = [
    google_project_service_identity.sm_sa, google_project_iam_member.project
  ]
}

resource "google_secret_manager_secret_version" "secret_version_basic" {
  count       = var.ignore_secret_change ? 1 : 0
  secret      = google_secret_manager_secret.secret_basic.id
  secret_data = var.secret_data
  depends_on = [
    google_project_service_identity.sm_sa, google_project_iam_member.project
  ]
}