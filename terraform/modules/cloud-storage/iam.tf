# Assign storage.objectCAdmin to the list of accounts provided if the set_creator_roles flag is true
resource "google_storage_bucket_iam_member" "admins" {
  for_each = var.set_storage_objectadmin_roles ? { for i, v in local.storage_objectadmin_list : i => v } : {}
  bucket   = google_storage_bucket.buckets[each.value.bucket_instance].name
  role     = "roles/storage.objectAdmin"
  member   = each.value.bucket_admin_user
}

# Assign storage.objectCreator to the list of accounts provided if the set_creator_roles flag is true
resource "google_storage_bucket_iam_member" "creators" {
  for_each = var.set_creator_roles ? { for i, v in local.bucket_creators_list : i => v } : {}
  bucket   = google_storage_bucket.buckets[each.value.bucket_instance].name
  role     = "roles/storage.objectCreator"
  member   = each.value.bucket_creator_user
}

# Assign storage.objectViewer to the list of accounts provided if the set_viewer_roles flag is true
resource "google_storage_bucket_iam_member" "viewers" {
  for_each = var.set_viewer_roles ? { for i, v in local.bucket_viewers_list : i => v } : {}
  bucket   = google_storage_bucket.buckets[each.value.bucket_instance].name
  role     = "roles/storage.objectViewer"
  member   = each.value.bucket_viewer_user
}


# Assign storage.hmacKeyAdmin to the list of accounts provided if the set_hmacKeyAdmin_roles flag is true
resource "google_storage_bucket_iam_member" "hmac_key_admins" {
  for_each = var.set_hmackeyadmin_roles ? { for i, v in local.storage_hmackeyadmin_list : i => v } : {}
  bucket   = google_storage_bucket.buckets[each.value.bucket_instance].name
  role     = "roles/storage.hmacKeyAdmin"
  member   = each.value.bucket_admin_user
}

# Assign storage.admin to the list of accounts provided if the set_storage_admin_roles flag is true
resource "google_storage_bucket_iam_member" "storage_admins" {
  for_each = var.set_storage_admin_roles ? { for i, v in local.storage_admin_list : i => v } : {}
  bucket   = google_storage_bucket.buckets[each.value.bucket_instance].name
  role     = "roles/storage.admin"
  member   = each.value.bucket_admin_user
}


