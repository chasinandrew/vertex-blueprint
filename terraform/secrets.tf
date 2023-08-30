//
// Copyright 2023 Google. This software is provided as-is, without warranty or representation for any use or purpose. Your use of it is subject to your agreement with Google.
//

#  Inputs:
#   - gcp_project_id
#   - region
#   - labels
#   - notebooks
#    - dsa_services
# required to rotate secrets

locals {
  vertex_sas = [for s in module.vertex-ai-workbench : format("%s:",
    "serviceAccount",
    s.sa_notebooks
  )]
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
  next_rotation_time                   = each.value.rotation_period == "" ? "" : timeadd(timestamp(), each.value.rotation_period)
  rotation_period                      = each.value.rotation_period
  expire_time                          = try(each.value.expire_time, "")
  secret_data                          = ""
  secret_accessor_group                = each.value.secret_accessor_group
  pub_sub_topic                        = resource.google_pubsub_topic.secret_rotation.name
  secret_manager_admin_group           = each.value.secret_manager_admin_group
  secret_manager_accessor_group        = each.value.grant_vertex_workbench_access ? merge(local.vertex_sas, each.value.secret_accessor_group) : each.value.secret_accessor_group
  secret_manager_viewer_group          = each.value.secret_manager_viewer_group
  secret_manager_version_manager_group = each.value.secret_manager_admin_group
  secret_manager_version_adder_group   = each.value.secret_manager_admin_group
  ignore_secret_change                 = true
  depends_on = [
    module.vertex-ai-workbench
  ]
}

