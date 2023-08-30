# ----------------------------------------------------------------------------
# Google Project
# ----------------------------------------------------------------------------

variable "gcp_project_id" {
  type        = string
  description = <<EOF
    Number of new versions per object. Relevant only for versioned objects. 
    The number of newer versions of an object to satisfy the delete condition.
  EOF
}

variable "gcp_region" {
  type        = string
  description = <<INFO
    Region of the function. 
    This is the region where you want to deploy the function. Default is 'us-east4'
  INFO
  default     = "us-east4"

  validation {
    condition     = contains(["us-east1", "us-east4", "us-south1", "us-central1"], var.gcp_region)
    error_message = "Invalid region specified. Must be one of us-east1, us-east4, us-south1, or us-central1."
  }
}

# ----------------------------------------------------------------------------
# Service Account
# ----------------------------------------------------------------------------

variable "set_storage_objectadmin_roles" {
  type        = bool
  default     = true
  description = <<EOF
    Flag to set storage_admin roles.
  EOF

}

variable "set_creator_roles" {
  type        = bool
  default     = true
  description = <<EOF
    Flag to set creator roles.
  EOF

}
variable "set_viewer_roles" {
  type        = bool
  default     = true
  description = <<EOF
     Flag to set viewer roles.
  EOF

}

variable "set_hmackeyadmin_roles" {
  type        = bool
  default     = true
  description = <<EOF
     Flag to set viewer roles.
  EOF

}

variable "set_storage_admin_roles" {
  type        = bool
  default     = true
  description = <<EOF
    Flag to set storage_admin roles.
  EOF

}



# ----------------------------------------------------------------------------
# Storage Buckets
# ----------------------------------------------------------------------------
variable "bucket_name" {
  type        = list(string)
  description = <<EOF
    Name of GCS bucket
  EOF
  validation {
    condition = length([
      for name in var.bucket_name : true
      if length(name) <= 63 && can(regex("^[a-z0-9]+[-37hoco][-a-z0-9]+[a-z0-9]$", name))

    ]) == length(var.bucket_name)
    error_message = "Bucket name must be less than 64 characters and alphanumerics only, in the format of {rand()}-{37hoco}-{classification}-{data_source}-{app_code}-{location}-{env}."
  }
}

variable "bucket_location" {
  type        = string
  default     = "US"
  description = <<EOF
    Location of bucket
  EOF
}

variable "bucket_storage_class" {
  type        = string
  default     = "STANDARD"
  description = <<EOF
    (Optional, Default: 'STANDARD') Storage class of the bucket. 
    Must be one of the following: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE
  EOF
  validation {
    condition     = contains(["STANDARD", "MULTI_REGIONAL", "REGIONAL", "NEARLINE", "COLDLINE", "ARCHIVE"], var.bucket_storage_class)
    error_message = "Valid values are: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "bucket_admins" {
  type        = list(string)
  default     = []
  description = <<EOF
     IAM-style members who will be granted roles/storage.objectAdmin on all buckets.
  EOF
  validation {
    condition     = alltrue([for v in var.bucket_admins : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Bucket Admins must not be allUsers or allAuthenticatedUsers."
  }
}

variable "bucket_creators" {
  type        = list(string)
  default     = []
  description = <<EOF
    IAM-style members who will be granted roles/storage.objectCreators on all buckets.
  EOF
  validation {
    condition     = alltrue([for v in var.bucket_creators : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Bucket Creators must not be allUsers or allAuthenticatedUsers."
  }
}

variable "bucket_viewers" {
  type        = list(string)
  default     = []
  description = <<EOF
    IAM-style members who will be granted roles/storage.objectViewer on all buckets.
  EOF


  validation {
    condition     = alltrue([for v in var.bucket_viewers : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Bucket Viewers must not be allUsers or allAuthenticatedUsers."
  }
}

variable "storage_objectadmins" {
  type        = list(string)
  default     = []
  description = <<EOF
    IAM-style members who will be granted roles/storage.objectViewer on all buckets.
  EOF


  validation {
    condition     = alltrue([for v in var.storage_objectadmins : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Bucket Viewers must not be allUsers or allAuthenticatedUsers."
  }
}

variable "storage_hmackeyadmins" {
  type        = list(string)
  default     = []
  description = <<EOF
    IAM-style members who will be granted roles/storage.objectViewer on all buckets.
  EOF


  validation {
    condition     = alltrue([for v in var.storage_hmackeyadmins : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Bucket Viewers must not be allUsers or allAuthenticatedUsers."
  }
}


variable "bucket_labels" {
  type        = map(string)
  description = <<EOF
    Map of GCS Bucket labels. A Data Classification level must be attached to each bucket using established resource labels.  
    The business owner must choose the highest data classification level of that data that the bucket may eventually contain.
  EOF
}

# ----------------------------------------------------------------------------------------------
# Storage Lifecycle Settings
# ----------------------------------------------------------------------------------------------
variable "data_retention" {
  type        = string
  default     = "9"
  description = <<EOF
    Number of days to retain previous versions of an object plus one. 
    The default is 9 which is the equivalent of 8 days worth.
  EOF


  validation {
    condition     = var.data_retention >= 9
    error_message = "The variable data_retention must be greater than or equal to 9."
  }
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = <<EOF
     Option to enable force Destroy, default is false
     (Optional, Default: false) When deleting a bucket, this boolean option will delete all contained objects.
     If you try to delete a bucket that contains objects, Terraform will fail that run.
     Must be used along side enable_data_protection been set to false. 
  EOF

}

variable "enable_data_protection" {
  type        = bool
  default     = true
  description = <<EOF
    "Setting this to false will deploy your storage bucket to a single region. 
     You will not have any data protection and a regional failure will cause a total loss of data that is not recoverable."
  EOF
}

variable "data_locations" {
  type        = list(string)
  default     = ["US-CENTRAL1", "US-EAST4"]
  description = <<EOF
    List of dual-region locations to use.
  EOF
}

variable "enable_autoclass" {
  type        = bool
  default     = false
  description = <<EOF
    (Optional) When set to true, enables auto tiering down to colder tiers of storage over time.
    automatically transitions objects in your bucket to appropriate storage classes based on each object's access pattern.
  EOF

}


variable "public_access_prevention" {
  type        = string
  default     = "inherited"
  description = <<EOF
    Prevents public access to a bucket. Acceptable values are `inherited` or `enforced`.
    If `inherited`, the bucket uses public access prevention, only if the bucket is subject
    to the public access prevention organization policy constraint.
  EOF
  validation {
    condition     = contains(["inherited", "enforced"], var.public_access_prevention)
    error_message = "Acceptable values are \"inherited\" or \"enforced\". If \"inherited\", the bucket uses public access prevention only if the bucket is subject to the public access prevention organization policy constraint. Defaults to \"inherited\"."
  }
}



variable "bucket_policy_only" {
  type        = map(bool)
  default     = {}
  description = <<EOF
      "Disable ad-hoc ACLs on specified buckets. 
      Defaults to true. Map of lowercase unprefixed name => boolean"
  EOF
}

variable "versioning" {
  type        = map(bool)
  default     = {}
  description = <<EOF
   Optional map of lowercase unprefixed name => boolean, defaults to false.
  EOF
}


variable "default_event_based_hold" {
  type        = map(bool)
  default     = {}
  description = <<EOF
   Enable event based hold to new objects added to specific bucket. 
    Defaults to false. Map of lowercase unprefixed name => boolean
  EOF
}


variable "encryption_key_names" {
  type        = map(string)
  default     = {}
  description = <<EOF
   Optional map of lowercase unprefixed name => string, empty strings are ignored.
  EOF
}


variable "cors" {
  type        = set(any)
  default     = []
  description = <<EOF
  Set of maps of mixed type attributes for CORS values. 
  See appropriate attribute types here: https://www.terraform.io/docs/providers/google/r/storage_bucket.html#cors"
  EOF
}


variable "website" {
  type        = map(any)
  default     = {}
  description = <<EOF
    Map of website values. Supported attributes: main_page_suffix, not_found_page
  EOF
}



variable "retention_policy" {
  type        = any
  default     = {}
  description = <<EOF
    Map of retention policy values. Format is the same as described in provider 
    documentation https://www.terraform.io/docs/providers/google/r/storage_bucket#retention_policy
  EOF
}


variable "logging" {
  description = "Map of lowercase unprefixed name => bucket logging config object. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#logging"
  type        = any
  default     = {}
}


variable "folders" {
  description = "Map of lowercase unprefixed name => list of top level folder objects."
  type        = map(list(string))
  default     = {}
}


# ----------------------------------------------------------------------------------------------
# lifecycle_rules Settings
# ----------------------------------------------------------------------------------------------
variable "lifecycle_rules" {
  description = <<EOF
    1.     type - The type of the action of this Lifecycle Rule. Supported values: Delete, SetStorageClass and AbortIncompleteMultipartUpload.
    2.     storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.
    3.     List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches_storage_class should be a comma delimited string."
    4.     age - (Optional) Minimum age of an object in days to satisfy this condition.
    5.     created_before - (Optional) Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.
    6.     with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".
    7.     matches_storage_class - (Optional) Comma delimited string for storage class of objects to satisfy this condition. Supported values include: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY.
    8.     matches_prefix - (Optional) One or more matching name prefixes to satisfy this condition.
    9.     matches_suffix - (Optional) One or more matching name suffixes to satisfy this condition.
    10.    num_newer_versions - (Optional) Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.
    11.    custom_time_before - (Optional) A date in the RFC 3339 format YYYY-MM-DD. This condition is satisfied when the customTime metadata for the object is set to an earlier date than the date used in this lifecycle condition.
    12.    days_since_custom_time - (Optional) The number of days from the Custom-Time metadata attribute after which this condition becomes true.
    13.    days_since_noncurrent_time - (Optional) Relevant only for versioned objects. Number of days elapsed since the noncurrent timestamp of an object.
    14.    noncurrent_time_before - (Optional) Relevant only for versioned objects. The date in RFC 3339 (e.g. 2017-06-13) when the object became nonconcurrent.
  EOF
  type = set(object({
    action    = map(string)
    condition = map(string)
  }))
  default = []
}


variable "bucket_lifecycle_rules" {
  description = <<EOF
    1.     type - The type of the action of this Lifecycle Rule. Supported values: Delete and SetStorageClass.
    2.     storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.
    3.     age - (Optional) Minimum age of an object in days to satisfy this condition.
    4.     created_before - (Optional) Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.
    5.     with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".
    6.     matches_storage_class - (Optional) Comma delimited string for storage class of objects to satisfy this condition. Supported values include: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY.
    7.     num_newer_versions - (Optional) Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.
    8.     custom_time_before - (Optional) A date in the RFC 3339 format YYYY-MM-DD. This condition is satisfied when the customTime metadata for the object is set to an earlier date than the date used in this lifecycle condition.
    9.     days_since_custom_time - (Optional) The number of days from the Custom-Time metadata attribute after which this condition becomes true.
    10.    days_since_noncurrent_time - (Optional) Relevant only for versioned objects. Number of days elapsed since the noncurrent timestamp of an object.
    11.    noncurrent_time_before - (Optional) Relevant only for versioned objects. The date in RFC 3339 (e.g. 2017-06-13) when the object became nonconcurrent.
EOF

  type = map(set(object({
    action    = map(string)
    condition = map(string)
  })))
  default = {}

}

# ----------------------------------------------------------------------------
# Hmac Account settings
# ----------------------------------------------------------------------------

variable "set_hmac_access" {
  type        = bool
  default     = false
  description = <<EOF
    Set S3 compatible access to GCS.
  EOF

}
variable "hmac_service_accounts" {
  type        = map(string)
  default     = {}
  description = <<EOF
    List of HMAC service accounts to grant access to GCS. 
  EOF
}
