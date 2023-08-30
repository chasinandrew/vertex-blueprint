resource "google_project_iam_member" "admin_group" {
  for_each   = toset(var.secret_manager_admin_group)
  project = var.project_id
  role    = "roles/secretmanager.admin"
  member  = each.key
}

resource "google_project_iam_member" "accessor_group" {
  for_each   = toset(var.secret_manager_accessor_group)
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = each.key
}

resource "google_project_iam_member" "viewer_group" {
  for_each   = toset(var.secret_manager_viewer_group)
  project = var.project_id
  role    = "roles/secretmanager.viewer"
  member  = each.key
}

resource "google_project_iam_member" "version_manager_group" {
  for_each   = toset(var.secret_manager_version_manager_group)
  project = var.project_id
  role    = "roles/secretmanager.secretVersionManager"
  member  = each.key
}

resource "google_project_iam_member" "version_adder_group" {
  for_each   = toset(var.secret_manager_version_adder_group)
  project = var.project_id
  role    = "roles/secretmanager.secretVersionAdder"
  member  = each.key
}

# Create service identity to enable CMEK for Secret Manager. Refer to - https://cloud.google.com/secret-manager/docs/cmek for details
resource "google_project_service_identity" "sm_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "secretmanager.googleapis.com"
}

resource "google_secret_manager_secret_iam_binding" "binding" {
  project   = google_secret_manager_secret.secret_basic.project
  secret_id = google_secret_manager_secret.secret_basic.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members   = var.secret_accessor_group
}

resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_project_service_identity.sm_sa.email}"
}