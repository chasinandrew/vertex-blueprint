#---------------------------------------------------------------------------------------------
# GCP Test Resources
#---------------------------------------------------------------------------------------------

# This creates a pubsub topic which is a pre-requisite for using this module
resource "google_pubsub_topic" "example" {
  name = "example-topic"

  labels = module.tagging.metadata

  message_retention_duration = "86600s"
}

module "tagging" {
  source          = "app.terraform.io/hca-healthcare/tagging/hca"
  version         = "~>0.1.0"
  classification  = "internal-only"
  app_code        = "cpa"
  cost_id         = 14203
  department_id   = 12761
  project_id      = "it-p0064776"
  tco_id          = "google_gcp"
  app_environment = "dev"
}

locals {
  secret_instances = {
    instance1 = {
      project_id = var.gcp_project_id
      # DS-REQ-03
      # Must be one of restricted, phi, internal, public. Follow https://cloud.google.com/compute/docs/labeling-resources#requirements for labeling requirements.
      labels                               = module.tagging.metadata
      secret_id                            = "tst-secret1"
      location                             = "us-east4"
      next_rotation_time                   = timeadd(timestamp(), "31536000s")
      rotation_period                      = "31536000s"
      expire_time                          = ""
      secret_data                          = ""
      ignore_secret_change                 = true
      secret_accessor_group                = []
      pub_sub_topic                        = "example-topic"
      secret_manager_admin_group           = ["group:AZCLD_CORP_Admin_CloudPlatformOperations@hca.corpad.net"]
      secret_manager_accessor_group        = []
      secret_manager_viewer_group          = []
      secret_manager_version_manager_group = []
      secret_manager_version_adder_group   = []
    }
  }
}

#{ module_testing_block }#

module "secret_manager" {
  for_each = local.secret_instances
  source   = "../.."

  # source  = "app.terraform.io/hca-healthcare/secret-manager/gcp"
  # version = "0.2.2"

  project_id = each.value.project_id
  # DS-REQ-03
  # Must be one of restricted, phi, internal, public. Follow https://cloud.google.com/compute/docs/labeling-resources#requirements for labeling requirements.
  labels                               = each.value.labels
  secret_id                            = each.value.secret_id
  location                             = each.value.location
  next_rotation_time                   = each.value.next_rotation_time
  rotation_period                      = each.value.rotation_period
  expire_time                          = each.value.expire_time
  secret_data                          = each.value.secret_data
  secret_accessor_group                = each.value.secret_accessor_group
  pub_sub_topic                        = each.value.pub_sub_topic
  secret_manager_admin_group           = each.value.secret_accessor_group
  secret_manager_accessor_group        = each.value.secret_accessor_group
  secret_manager_viewer_group          = each.value.secret_accessor_group
  secret_manager_version_manager_group = each.value.secret_accessor_group
  secret_manager_version_adder_group   = each.value.secret_accessor_group

  depends_on = [
    google_pubsub_topic.example
  ]
}
