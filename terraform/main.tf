//
// Copyright 2023 Google. This software is provided as-is, without warranty or representation for any use or purpose. Your use of it is subject to your agreement with Google.
//

#  Inputs:
#   - gcp_project_id
#   - region
#   - labels
#   - notebooks
#    - dsa_services

locals {
  # Iterate over input variable and default any missing optional fields
  notebooks = [
    for nb in var.notebooks : {
      user         = nb.user
      machine_type = try(nb.machine_type, var.default_machine_type)
      zone         = try(nb.zone, var.default_zone)
      image_family = nb.image_family
      accelerator_config = try({
        type       = nb.gpu_type
        core_count = tonumber(nb.gpu_count)
      }, null)
      post_startup_script = try(nb.post_startup_script, null)
    }
  ]
}

# enable required services for this blueprint
resource "google_project_service" "project" {
  for_each = toset(var.project_services)
  project  = var.gcp_project_id
  service  = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
  disable_on_destroy         = false

}

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [google_project_service.project]
  create_duration = "60s"
}


module "tagging" {
  source          = "./modules/tagging"
  app_code        = var.labels.app_code
  app_environment = var.labels.app_environment
  classification  = var.labels.classification
  cost_id         = var.labels.cost_id
  department_id   = var.labels.department_id
  project_id      = var.labels.hca_project_id
  tco_id          = var.labels.tco_id

  optional = {
    env    = var.labels.app_environment,
    region = var.gcp_region
  }
}
resource "random_id" "server" {
  byte_length = 4
}

module "storage" {
  source             = "./modules/cloud-storage"
  for_each           = { for obj in var.buckets : obj.bucket_name => obj }
  project_id         = var.gcp_project_id
  bucket_labels      = module.tagging.metadata
  bucket_name        = [each.value.bucket_name]
  sa_display_name    = each.value.sa_display_name != "" ? each.value.sa_display_name : format("%s Service Account", each.value.bucket_name)
  sa_name            = each.value.sa_display_name != "" ? each.value.sa_name : format("%s-bucket-sa-%s", each.value.bucket_name, index(var.buckets, each.value) + 1)
  bucket_viewers     = each.value.notebook_obj_viewer ? concat(local.vertex_sas, try(each.value.bucket_viewers, [])) : try(each.value.bucket_viewers, [])
  bucket_admins      = each.value.notebook_obj_admin ? concat(local.vertex_sas, try(each.value.bucket_admins, [])) : try(each.value.bucket_admins, [])
  bucket_creators    = each.value.notebook_obj_creator ? concat(local.vertex_sas, try(each.value.bucket_creators, [])) : try(each.value.bucket_creators, [])
  num_newer_versions = try(each.value.num_newer_versions, 1)
  force_destroy      = false

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}




module "dataset" {
  source              = "./modules/bigquery-dataset"
  for_each            = { for obj in var.datasets : obj.dataset_id => obj }
  project_id          = var.gcp_project_id
  labels              = module.tagging.metadata
  user_group          = each.value.notebook_dataset_viewer ? concat(local.vertex_sas, try(each.value.user_group, [])) : try(each.value.user_group, [])
  admin_group         = try(each.value.admin_group, [])
  ml_group            = each.value.notebook_dataset_editor ? concat(local.vertex_sas, try(each.value.ml_group, [])) : try(each.value.ml_group, [])
  dataset_id          = each.value.dataset_id
  protect_from_delete = true

  depends_on = [
    time_sleep.wait_60_seconds,

  ]
}

module "vertex-ai-workbench" {
  for_each = module.tagging.metadata.app_environment == "train" || module.tagging.metadata.app_environment == "dev" ? (
  { for n in local.notebooks : "${n.user}:${n.image_family}" => n }) : ({})
  source = "./modules/vertex-notebooks"

  project_id = var.gcp_project_id
  labels     = merge(module.tagging.metadata, try(each.value.labels, {}))

  instance_owner = format("%s@%s", each.value.user, var.user_domain)
  zone           = each.value.zone
  region         = var.gcp_region

  machine_type = each.value.machine_type
  vm_image_config = {
    project      = var.deeplearning_project
    image_family = each.value.image_family
  }

  accelerator_config  = each.value.accelerator_config
  host_project_id     = var.host_project_id
  network             = var.network
  subnet              = format("%s-%s-%s", var.gcp_project_id, "notebooks", var.gcp_region) #TODO: will they be on different subnets? 
  metadata_optional   = var.metadata
  post_startup_script = each.value.post_startup_script
  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

# Single repository with all initiative team members
module "artifact-registry" {
  source                             = "./modules/artifact-registry"
  project_id                         = var.gcp_project_id
  labels                             = module.tagging.metadata
  description                        = var.artifact_registry_description
  format                             = var.artifact_registry_format
  artifact_registry_reader_group     = var.artifact_registry_reader_group
  artifact_registry_writer_group     = var.artifact_registry_writer_group
  artifact_registry_repo_admin_group = var.artifact_registry_repo_admin_group
  artifact_registry_admin_group      = var.artifact_registry_admin_group
  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

module "feature-store" {
  source          = "./modules/feature-store"
  project_id      = var.gcp_project_id
  labels          = module.tagging.metadata
  app_code        = module.tagging.metadata.app_code
  app_environment = module.tagging.metadata.app_environment
  node_count      = 2
  force_destroy   = false
  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

data "google_project" "project" {
  project_id = var.gcp_project_id
}

resource "google_project_iam_member" "shared_vpc" {
  project = var.host_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-notebooks.iam.gserviceaccount.com"
  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

resource "google_project_iam_member" "image_user" {
  project = var.gcp_project_id
  role    = "roles/compute.imageUser"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-notebooks.iam.gserviceaccount.com"
  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

# module "iam_project_roles" {
#   source = "./modules/iam"
#   for_each = module.tagging.metadata.app_environment == "train" || module.tagging.metadata.app_environment == "dev" ? (
#   { for n in local.notebooks : "${n.user}:${n.image_family}" => n }) : ({})
#   project_id  = var.gcp_project_id
#   entity_type = "project"
#   entities    = [var.gcp_project_id]

#   bindings_by_principal = {
#     module.vertex-ai-workbench["${each.value.user}:${each.value.image_family}"].sa_notebooks = [
#       "roles/storage.admin",
#       "roles/aiplatform.user",
#       "roles/iam.serviceAccountUser",
#       "roles/bigquery.user",
#       "roles/bigquery.dataEditor"
#     ]
#   }
# }