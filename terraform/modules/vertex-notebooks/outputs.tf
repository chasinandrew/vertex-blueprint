output "sa_notebooks" {
  value       = google_service_account.sa_p_notebook_compute.email
  description = "Notebook Service account email"
}

output "notebook_instance" {
  value       = google_notebooks_instance.instance.id
  description = "Notebook Name"
}

output "userid" {
  value       = local.userid
  description = "Notebook Instance owner 3-4 ID"
}

output "mlops_service_account" {
  #value = data.google_service_account.mlops_sa
  value       = substr(local.mlops_sa, 0, 30)
  description = "Service Account used by Notebook Serivce Accounts to access Vertex AI Suite"
}