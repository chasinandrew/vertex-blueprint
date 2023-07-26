output "project_id" {
  value = var.project_id
}

output "service_account_admin" {
  value = module.service_account_admin.service_account
}

output "bucket_name" {
  value = module.gcs_buckets.name
}

output "bucket_admin_groups" {
  value = var.bucket_admins
}

output "bucket_creator_groups" {
  value = var.bucket_creators
}

output "bucket_viewer_groups" {
  value = var.bucket_viewers
}

