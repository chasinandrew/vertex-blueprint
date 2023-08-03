
### Creating Notebook Specific Service Account
resource "google_service_account" "sa_p_notebook_compute" {
  project      = var.project_id
  account_id   = local.service_account_id
  display_name = "Service Account for Notebook ${local.notebook_instance_name}"
}



# ### Bind Custom Role to Notebook Service Account
# resource "google_project_iam_member" "notebook_custom_role" {
#   project = var.project_id
#   role    = "organizations/${var.organization_id}/roles/notebook_restricted_data_viewer"
#   member  = "serviceAccount:${google_service_account.sa_p_notebook_compute.email}"
# }

#### Assign Notebook Service Account Role to impersonate MLOPS service account
#esource "google_service_account_iam_member" "mlops-account-iam" {
# service_account_id = data.google_service_account.mlops_sa.name
# role               = "roles/iam.serviceAccountUser"
# member             = "serviceAccount:${google_service_account.sa_p_notebook_compute.email}"
#
#
### Assign Notebook Service Account Role to impersonate MLOPS service account
#esource "google_service_account_iam_member" "mlops-account-iam2" {
# service_account_id = data.google_service_account.mlops_sa.name
# role               = "roles/iam.serviceAccountTokenCreator"
# member             = "serviceAccount:${google_service_account.sa_p_notebook_compute.email}"
#
