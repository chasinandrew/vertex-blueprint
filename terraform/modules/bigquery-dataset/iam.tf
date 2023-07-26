# IAM-REQ-04 / IAM-REQ-23 / IAM-REQ-32 / C-REQ-11
# Add IAM policy bindings

# Create project-level IAM bindings for BigQuery roles
module "projects_iam_bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id]
  bindings = {
    "roles/bigquery.admin"   = var.admin_group
    "roles/bigquery.jobUser" = var.user_group
    "roles/bigquery.jobUser" = var.ml_group
  }
}

# Authoritatively set table-level IAM
resource "google_bigquery_table_iam_policy" "policy" {
  for_each    = toset(local.table_ids)
  project     = var.project_id
  dataset_id  = var.dataset_id
  table_id    = each.value
  policy_data = data.google_iam_policy.table_level_policies.policy_data
  depends_on = [
    module.bigquery
  ]
}