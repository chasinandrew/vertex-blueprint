//
// Copyright 2022 Google. This software is provided as-is, without warranty or representation for any use or purpose. Your use of it is subject to your agreement with Google.
//

#  Inputs:
#   - gcp_project_id
#   - region
#   - labels
#   - notebooks
#   - dsa_services

resource "random_id" "random_suffix" {
  byte_length = 3
}

locals {
  project_id      = var.gcp_project_id
  region          = var.gcp_region
  app_code        = var.labels.app_code
  classification  = var.labels.classification
  cost_id         = var.labels.cost_id
  department_id   = var.labels.department_id
  tco_id          = var.labels.tco_id
  app_environment = var.labels.app_environment
  hca_project_id  = var.labels.hca_project_id
  user_domain     = var.user_domain #constant

  bucket_name            = format("%s-%s", var.bucket_name, var.dsa_services.bucket_suffix) # TODO: dynamic bucket name
  bucket_sa_name         = format("%s-sa", local.bucket_name)
  bucket_sa_display_name = var.bucket_sa_display_name
  host_project_id        = var.host_project_id #constant
  network                = var.network         #constant
  subnet = format("%s-%s-%s",
    local.project_id,
    "notebooks",
    local.region
  )

  metadata                           = var.metadata
  dataset_dataset_id                 = format("%s_%s", var.dsa_services.dataset_id_prefix, random_id.random_suffix.hex)
  artifact_registry_naming_prefix    = var.dsa_services.artifact_registry_naming_prefix
  artifact_registry_description      = try(var.dsa_services.artifact_registry_description, null)
  artifact_registry_format           = try(var.dsa_services.artifact_registry_format, var.artifact_registry_default_format)
  artifact_registry_reader_group     = var.artifact_registry_reader_group
  artifact_registry_writer_group     = var.artifact_registry_writer_group
  artifact_registry_repo_admin_group = var.artifact_registry_repo_admin_group
  artifact_registry_admin_group      = var.artifact_registry_admin_group
  node_count                         = try(var.dsa_services.feature_store_node_count, 1)
  force_destroy                      = true

  labels = {
    region = local.region
    app_code       = local.app_code
    classification = local.classification
    cost_id        = local.cost_id
    department_id  = local.department_id
    project_id      = local.hca_project_id
    tco_id          = local.tco_id
    app_environment = local.app_environment
  }

  # Iterate over input variable and default any missing optional fields
  notebooks = [
    for nb in var.notebooks : {
      user         = nb.user
      machine_type = try(nb.machine_type, var.default_machine_type)
      zone         = try(nb.zone, var.default_zone)
      image_family = nb.image_family
      accelerator_config = try({
        type       = nb.gpu_type # TODO: validate against a list of valid accelerators
        core_count = tonumber(nb.gpu_count)
      }, null)
      post_startup_script = try(nb.post_startup_script, null)
    }
  ]

  storage = {
    bucket_name        = [local.bucket_name]
    sa_display_name    = local.bucket_sa_display_name
    sa_name            = local.bucket_sa_name
    bucket_viewers     = [""]
    bucket_admins      = [""]
    bucket_creators    = [""]
    num_newer_versions = "1" #TODO: try using '0', verify fuse
    force_destroy      = false
  }
  dataset = {
    user_group  = []
    admin_group = []
    ml_group    = []
    dataset_id  = local.dataset_dataset_id
  }

  artifact_registry = {
    naming_prefix                      = local.artifact_registry_naming_prefix
    description                        = local.artifact_registry_description
    format                             = local.artifact_registry_format
    artifact_registry_reader_group     = local.artifact_registry_reader_group
    artifact_registry_writer_group     = local.artifact_registry_writer_group
    artifact_registry_repo_admin_group = local.artifact_registry_repo_admin_group
    artifact_registry_admin_group      = local.artifact_registry_admin_group
  }

  feature_store = {
    node_count    = local.node_count
    force_destroy = local.force_destroy
  }
}

module "tagging" {
  source          = "./modules/tagging" 
  version         = "0.0.6"
  app_code        = local.labels.app_code
  app_environment = local.labels.app_environment
  classification  = local.labels.classification
  cost_id         = local.labels.cost_id
  department_id   = local.labels.department_id
  project_id      = local.labels.project_id
  tco_id          = local.labels.tco_id

  optional = {
    env    = local.labels.app_environment,
    region = local.labels.region
  }
}

# A single shared bucket for current example
module "storage" {
  source  = "./modules/cloud-storage"  
  version = "1.0.2"

  project_id         = local.project_id
  bucket_name        = local.storage.bucket_name
  bucket_labels      = module.tagging.metadata
  sa_display_name    = local.storage.sa_display_name
  sa_name            = local.storage.sa_name
  bucket_viewers     = local.storage.bucket_viewers
  bucket_admins      = local.storage.bucket_admins
  bucket_creators    = local.storage.bucket_creators
  num_newer_versions = local.storage.num_newer_versions
  force_destroy      = local.storage.force_destroy
}

# A single BigQuery dataset shared with all initiative team members. Each DS will have its own table.
module "dataset" {
  source  = "./modules/bigquery-dataset"
  version = "0.0.7"

  project_id          = local.project_id
  labels              = module.tagging.metadata
  user_group          = local.dataset.user_group
  admin_group         = local.dataset.admin_group
  ml_group            = local.dataset.ml_group
  dataset_id          = local.dataset.dataset_id
  protect_from_delete = true
  # TODO: check if DS tables need to be provisioned
}

module "vertex-ai-workbench" {
  for_each = module.tagging.metadata.app_environment == "train" || module.tagging.metadata.app_environment == "dev" ? (
  { for n in local.notebooks : "${n.user}:${n.image_family}" => n }) : ({})
  source  = "./modules/vertex-notebooks" 
  version = "0.3.0"

  project_id = local.project_id
  labels     = module.tagging.metadata

  instance_owner = format("%s@%s", each.value.user, local.user_domain)
  zone           = each.value.zone
  region         = local.region

  machine_type = each.value.machine_type
  vm_image_config = {
    project      = var.deeplearning_project #constant
    image_family = each.value.image_family
  }

  accelerator_config  = each.value.accelerator_config
  host_project_id     = local.host_project_id
  network             = local.network
  subnet              = local.subnet
  metadata_optional   = local.metadata
  post_startup_script = each.value.post_startup_script
}

# Single repository with all initiative team members
module "artifact-registry" {
  source  = "./modules/artifact-registry" 
  version = "0.0.3"

  project_id = local.project_id
  labels     = module.tagging.metadata

  naming_prefix = local.artifact_registry.naming_prefix
  description   = local.artifact_registry.description
  format        = local.artifact_registry.format # TODO: check if this can be defaulted to DOCKER

  artifact_registry_reader_group     = local.artifact_registry.artifact_registry_reader_group
  artifact_registry_writer_group     = local.artifact_registry.artifact_registry_writer_group
  artifact_registry_repo_admin_group = local.artifact_registry.artifact_registry_repo_admin_group
  artifact_registry_admin_group      = local.artifact_registry.artifact_registry_admin_group
}

module "feature-store" {
  source  = "./modules/feature-store" 
  version = "0.0.1"

  project_id      = local.project_id
  labels          = module.tagging.metadata
  app_code        = module.tagging.metadata.app_code
  app_environment = module.tagging.metadata.app_environment
  node_count      = local.feature_store.node_count
  force_destroy   = local.feature_store.force_destroy
}
