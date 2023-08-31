//
// Copyright 2023 Google. This software is provided as-is, without warranty or representation for any use or purpose. Your use of it is subject to your agreement with Google.
//

# This module is used to create secrets for Data Scientist blueprint usage. 

locals {
  vertex_sas = flatten([for s in module.vertex-ai-workbench : format("%s:%s",
    "serviceAccount",
    s.sa_notebooks
  ) if try(s.sa_notebooks != null) || module.tagging.metadata.app_environment == "train" || module.tagging.metadata.app_environment == "dev"])
}
resource "google_pubsub_topic" "secret_rotation" {
  name = "secret-topic"

  labels = module.tagging.metadata

  message_retention_duration = "86600s"
}

module "secrets" {
  source                               = "./modules/secrets"
  for_each                             = { for obj in var.secrets : obj.secret_id => obj }
  project_id                           = var.gcp_project_id
  labels                               = merge(module.tagging.metadata, (each.value.labels))
  secret_id                            = each.value.secret_id
  location                             = var.gcp_region
  next_rotation_time                   = timeadd(timestamp(), each.value.rotation_period)
  rotation_period                      = try(each.value.rotation_period)
  expire_time                          = try(each.value.expire_time, "")
  secret_data                          = "replace-me"
  pub_sub_topic                        = resource.google_pubsub_topic.secret_rotation.name
  secret_accessor_group                = each.value.notebook_secret_accessor ? concat(local.vertex_sas, each.value.secret_accessor_group) : each.value.secret_accessor_group
  secret_manager_admin_group           = each.value.secret_manager_admin_group
  secret_manager_accessor_group        = each.value.secret_manager_accessor_group
  secret_manager_viewer_group          = each.value.secret_manager_viewer_group
  secret_manager_version_manager_group = each.value.secret_manager_admin_group
  secret_manager_version_adder_group   = each.value.secret_manager_admin_group
  ignore_secret_change                 = true
  depends_on = [
    module.vertex-ai-workbench, resource.google_pubsub_topic.secret_rotation, time_sleep.wait_60_seconds
  ]
}

