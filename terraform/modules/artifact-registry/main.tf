# used to prevent name collisions
resource "random_id" "repo_suffix" {
  byte_length = 3
}

resource "google_artifact_registry_repository" "repo" {
  provider = google-beta

  project       = var.project_id
  repository_id = format("%s-%s", var.naming_prefix, random_id.repo_suffix.hex)
  format        = var.format
  location      = var.location
  description   = var.description
  labels        = var.labels

  dynamic "maven_config" {
    for_each = var.format == "MAVEN" ? toset([1]) : toset([])
    content {
      version_policy            = var.version_policy
      allow_snapshot_overwrites = var.allow_snapshot_overwrites
    }
  }
}
