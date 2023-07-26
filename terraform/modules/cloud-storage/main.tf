# NS-REQ-19
# Prevent Public Storage Access - managed in GCP Governance at GCP Org level by org.policy

# R-REQ-03
# R-REQ-04
# GCS bucket creation
module "gcs_buckets" {
  source        = "terraform-google-modules/cloud-storage/google"
  project_id    = var.project_id
  names         = var.bucket_name
  location      = "us"
  storage_class = "STANDARD"
  prefix        = ""

  #Add option for Force Destroy
  force_destroy = { "${var.bucket_name[0]}" = var.force_destroy }

  set_admin_roles = true

  # IAM-REQ-23
  # https://github.com/terraform-google-modules/terraform-google-cloud-storage/blob/master/main.tf#L137 - Module 
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#member/members - Resource
  admins           = concat(formatlist("serviceAccount:%s", module.service_account_admin.emails_list), var.bucket_admins)
  set_viewer_roles = true

  # IAM-REQ-04 : A defined subset of groups are used to limit access in GCP, adhering to the principle of least privilege
  viewers = var.bucket_viewers

  set_creator_roles = true
  creators          = var.bucket_creators

  # DS-REQ-03 : Data classification tags needs to be used/enforced in GCP 
  labels = var.bucket_labels

  # R-REQ-03 / R-REQ-04
  versioning = {
    "${var.bucket_name[0]}" = true
  }

  # R-REQ-03 / 
  # R-REQ-04 : Regular automated backups in the cloud are necessary; backup data must also be encrypted using customer managed keys
  lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age                = 9 # Minimum age of an object in days to satisfy this condition.
        num_newer_versions = var.num_newer_versions
      }
    }
  ]
}