# IAM-REQ-23
# Create Service Account
module "service_account_admin" {
  source          = "terraform-google-modules/service-accounts/google"
  description     = "Service account for ${var.sa_display_name}"
  project_id      = var.project_id
  display_name    = var.sa_display_name
  names           = [var.sa_name]
  grant_xpn_roles = false
  project_roles = [
    "${var.project_id}=>roles/storage.objectAdmin"
  ]
}
