output "project_id" {
  value       = var.gcp_project_id
  description = "The project ID."
}

output "bucket_name" {
  value       = var.bucket_name
  description = "The name of the bucket."
}

output "bucket_admin_groups" {
  value       = var.bucket_admins
  description = "Groups  with administrative privileges for the bucket."
}

output "bucket_creator_groups" {
  value       = var.bucket_creators
  description = "Groups  responsible for creating resources or managing permissions within the bucket."
}

output "bucket_viewer_groups" {
  value       = var.bucket_viewers
  description = "Groups with read-only access to the bucket."
}

output "bucket_labels" {
  value       = var.bucket_labels
  description = "Labels associated with the bucket."
}

output "urls" {
  value       = { for name, bucket in google_storage_bucket.buckets : name => bucket.url }
  description = "Url to access each Bucket."
}
