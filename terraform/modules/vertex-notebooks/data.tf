data "google_compute_network" "my_network" {
  project = var.host_project_id
  name    = var.network
}

data "google_compute_subnetwork" "my_subnetwork" {
  project = var.host_project_id
  name    = var.subnet
  region  = var.region
}

#data "google_service_account" "mlops_sa" {
#  project    = var.project_id
#  account_id = substr(local.mlops_sa, 0, 30)
#}

data "google_project" "project" {
  project_id = var.project_id
}



