resource "google_project_iam_member" "reader_group" {
  count   = length(var.artifact_registry_reader_group)
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = var.artifact_registry_reader_group[count.index]
}

resource "google_project_iam_member" "writer_group" {
  count   = length(var.artifact_registry_writer_group)
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = var.artifact_registry_writer_group[count.index]
}

resource "google_project_iam_member" "repo_admin_group" {
  count   = length(var.artifact_registry_repo_admin_group)
  project = var.project_id
  role    = "roles/artifactregistry.repoAdmin"
  member  = var.artifact_registry_repo_admin_group[count.index]
}

resource "google_project_iam_member" "admin_group" {
  count   = length(var.artifact_registry_admin_group)
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = var.artifact_registry_admin_group[count.index]
}