# Produce policy data output suitable for use in IAM assignment
data "google_iam_policy" "table_level_policies" {
  binding {
    role    = "roles/bigquery.dataViewer"
    members = var.user_group
  }
  binding {
    role    = "roles/bigquery.dataEditor"
    members = var.ml_group
  }
}

# Retrieve project default BQ service account
data "google_bigquery_default_service_account" "bq_service_agent" {
  project = var.project_id
}
