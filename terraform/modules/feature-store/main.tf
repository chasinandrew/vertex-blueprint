#resource "random_id" "random_suffix" {
#  byte_length = 3
#}

locals {
  fs_instance_name = format("%s_%s_%s_%s_%s",
    "gcp",
    replace(var.region, "-", "_"),
    replace(var.app_code, "-", "_"),
    "fs",
    var.app_environment,
  )
}

resource "google_vertex_ai_featurestore" "featurestore" {
  provider      = google-beta
  project       = var.project_id
  name          = local.fs_instance_name
  labels        = var.labels
  region        = var.region
  force_destroy = var.force_destroy
  online_serving_config {
    fixed_node_count = var.node_count
  }
}