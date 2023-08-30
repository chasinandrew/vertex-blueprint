

locals {
  # Create a list of bucket names to use for iterating through bucket creations
  names_set = toset(var.bucket_name)

  # Create list of objects that contain all of the buckets and users to be created to assign the objectadmin admin role to
  storage_objectadmin_list = flatten([
    for u in var.storage_objectadmins : [
      for b in local.names_set : {
        bucket_admin_user = u
        bucket_instance   = b
      }
    ]
  ])

  # Create list of objects that contain all of the buckets and users to be created to assign the creator role to
  bucket_creators_list = flatten([
    for u in var.bucket_creators : [
      for b in local.names_set : {
        bucket_creator_user = u
        bucket_instance     = b
      }
    ]
  ])

  # Create list of objects that contain all of the buckets and users to be created to assign the viewer role to
  bucket_viewers_list = flatten([
    for u in var.bucket_viewers : [
      for b in local.names_set : {
        bucket_viewer_user = u
        bucket_instance    = b
      }
    ]
  ])
  # Create list of objects that contain all of the buckets and users to be created to assign the hmackeyadmin role to
  storage_hmackeyadmin_list = flatten([
    for u in var.storage_hmackeyadmins : [
      for b in local.names_set : {
        bucket_viewer_user = u
        bucket_instance    = b
      }
    ]
  ])
  # Create list of objects that contain all of the buckets and users to be created to assign the storage admin role to
  storage_admin_list = flatten([
    for u in var.bucket_admins : [
      for b in local.names_set : {
        bucket_admin_user = u
        bucket_instance   = b
      }
    ]
  ])

  # Converts the input variable into a flattened list of bucket-folder pairs
  folder_list = flatten([
    for bucket, folders in var.folders : [
      for folder in folders : {
        bucket = bucket,
        folder = folder
      }
    ]
  ])
}
resource "google_storage_bucket" "buckets" {
  for_each = local.names_set
  # Name of the bucket
  name = each.value
  # HCA Project ID
  project = var.gcp_project_id

  # Flag to enable multi-region or single-region.  Default is multi-region
  location = var.enable_data_protection ? "US" : var.bucket_location

  # The default storage class is STANDARD
  storage_class = var.bucket_storage_class

  # Set bucket labels
  labels = var.bucket_labels

  # Prevents public access to a bucket. Acceptable values are "inherited" or "enforced"
  public_access_prevention = var.public_access_prevention

  # Flag to delete all objects inside a bucket when the bucket is destroyed
  force_destroy = var.enable_data_protection ? "false" : var.force_destroy

  # Enables Uniform bucket-level access access to a bucket.
  uniform_bucket_level_access = lookup(
    var.bucket_policy_only,
    lower(each.value),
    true,
  )

  # enables or disables versioning based on the configuration deafult is "true"
  versioning {
    enabled = lookup(
      var.versioning,
      lower(each.value),
      true,
    )
  }

  # automatically apply an eventBasedHold to new objects added to the bucket.
  default_event_based_hold = lookup(
    var.default_event_based_hold,
    lower(each.value),
    false,
  )

  # creates an encryption block based on the provided encryption key names, enabling encryption with the corresponding KMS key if a non-empty key name is specified.
  dynamic "encryption" {
    for_each = trimspace(lookup(var.encryption_key_names, lower(each.value), "")) != "" ? [true] : []
    content {
      default_kms_key_name = trimspace(
        lookup(
          var.encryption_key_names,
          lower(each.value),
          "Error retrieving kms key name",
        )
      )
    }
  }

  #dynamically creates CORS configurations with specified origin, method, response header, and max age seconds for each element in the var.cors variable.
  dynamic "cors" {
    for_each = var.cors
    content {
      origin          = lookup(cors.value, "origin", null)
      method          = lookup(cors.value, "method", null)
      response_header = lookup(cors.value, "response_header", null)
      max_age_seconds = lookup(cors.value, "max_age_seconds", null)
    }
  }


  # creates a website block with the specified main_page_suffix and not_found_page values based on the presence of keys
  dynamic "website" {
    for_each = length(keys(var.website)) == 0 ? toset([]) : toset([var.website])
    content {
      main_page_suffix = lookup(website.value, "main_page_suffix", null)
      not_found_page   = lookup(website.value, "not_found_page", null)
    }
  }

  # generates a dynamic retention_policy  with the specified is_locked and retention_period values if a retention policy exists
  dynamic "retention_policy" {
    for_each = lookup(var.retention_policy, each.value, {}) != {} ? [var.retention_policy[each.value]] : []
    content {
      is_locked        = lookup(retention_policy.value, "is_locked", null)
      retention_period = lookup(retention_policy.value, "retention_period", null)
    }
  }

  # conditionally creates a custom_placement_config block with data location configurations
  dynamic "custom_placement_config" {
    for_each = var.enable_data_protection ? [""] : []
    content {
      data_locations = var.data_locations
    }
  }

  # dynamically creates lifecycle rules for a bucket 
  dynamic "lifecycle_rule" {
    for_each = setunion(var.lifecycle_rules, lookup(var.bucket_lifecycle_rules, each.value, toset([])))
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                        = lookup(lifecycle_rule.value.condition, "age", null)
        created_before             = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state                 = lookup(lifecycle_rule.value.condition, "with_state", lookup(lifecycle_rule.value.condition, "is_live", false) ? "LIVE" : null)
        matches_storage_class      = contains(keys(lifecycle_rule.value.condition), "matches_storage_class") ? split(",", lifecycle_rule.value.condition["matches_storage_class"]) : null
        matches_prefix             = contains(keys(lifecycle_rule.value.condition), "matches_prefix") ? split(",", lifecycle_rule.value.condition["matches_prefix"]) : null
        matches_suffix             = contains(keys(lifecycle_rule.value.condition), "matches_suffix") ? split(",", lifecycle_rule.value.condition["matches_suffix"]) : null
        num_newer_versions         = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
        custom_time_before         = lookup(lifecycle_rule.value.condition, "custom_time_before", null)
        days_since_custom_time     = lookup(lifecycle_rule.value.condition, "days_since_custom_time", null)
        days_since_noncurrent_time = lookup(lifecycle_rule.value.condition, "days_since_noncurrent_time", null)
        noncurrent_time_before     = lookup(lifecycle_rule.value.condition, "noncurrent_time_before", null)
      }
    }
  }

  # dynamically creates logging configurations
  dynamic "logging" {
    for_each = lookup(var.logging, each.value, {}) != {} ? { v = lookup(var.logging, each.value) } : {}
    content {
      log_bucket        = lookup(logging.value, "log_bucket", null)
      log_object_prefix = lookup(logging.value, "log_object_prefix", null)
    }
  }

  # Enables storage auto-tiering
  dynamic "autoclass" {
    for_each = var.enable_autoclass ? [""] : []

    content {
      enabled = var.enable_autoclass
    }
  }

}

# Declaring an object with a trailing '/' creates a directory
# Note that the content string isn't actually used, but is only there since the resource requires it
resource "google_storage_bucket_object" "folders" {
  for_each = { for obj in local.folder_list : format("%s_%s", obj.bucket, obj.folder) => obj }
  bucket   = google_storage_bucket.buckets[each.value.bucket].name
  name     = format("%s/", each.value.folder)
  content  = "foo"
}

#creates gcs HMAC keys for the specified service account emails
resource "google_storage_hmac_key" "hmac_keys" {
  project               = var.gcp_project_id
  for_each              = var.set_hmac_access ? var.hmac_service_accounts : {}
  service_account_email = each.key
  state                 = each.value
}