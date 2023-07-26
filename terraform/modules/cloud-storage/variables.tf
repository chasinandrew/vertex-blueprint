# -------------------
# Google Project
variable "project_id" {
  type        = string
  description = "The project id where the service needs to be implemented"
}

# -------------------
# Service Account
variable "sa_display_name" {
  type        = string
  description = "Display name for Service Account."
}

variable "sa_name" {
  type        = string
  description = "Name of Service Account"
  validation {
    condition     = length(var.sa_name) <= 29 && can(regex("^[a-z]([-a-z0-9]*[a-z0-9])", var.sa_name))
    error_message = "Service Account name must be less than 30 characters and alphanumerics only."
  }
}


# -------------------
# Storage Buckets
variable "bucket_name" {
  type        = list(string)
  description = "Name of GCS bucket"
  validation {
    condition = length([
      for name in var.bucket_name : true
      if length(name) <= 63 && can(regex("^[a-z0-9]+[-37hoco][-a-z0-9]+[a-z0-9]$", name))

    ]) == length(var.bucket_name)
    error_message = "Bucket name must be less than 64 characters and alphanumerics only, in the format of {rand()}-{37hoco}-{classification}-{data_source}-{app_code}-{location}-{env}."
  }
}

# variable "bucket_location" {
#   type        = string
#   description = "Location of bucket"
# If Storage Classes OTHER than MULTIREGIONAL will be supported in the future, then this will need to made a user input.  Until then, it is being set to `us` statically. 
# }


# TODO: Ensure that bucket users have the appropriate string designations "type:<email>" types: 'domain', 'group', 'serviceAccount', or 'user'
variable "bucket_admins" {
  type        = list(string)
  description = "IAM-style members who will be granted roles/storage.objectAdmin on all buckets."

  validation {
    condition     = alltrue([for v in var.bucket_admins : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Bucket Admins must not be allUsers or allAuthenticatedUsers."
  }
}

variable "bucket_creators" {
  type        = list(string)
  description = "IAM-style members who will be granted roles/storage.objectCreators on all buckets."

  validation {
    condition     = alltrue([for v in var.bucket_creators : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Bucket Creators must not be allUsers or allAuthenticatedUsers."
  }
}

variable "bucket_viewers" {
  type        = list(string)
  description = "IAM-style members who will be granted roles/storage.objectViewer on all buckets."

  validation {
    condition     = alltrue([for v in var.bucket_viewers : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Bucket Viewers must not be allUsers or allAuthenticatedUsers."
  }
}

variable "bucket_labels" {
  type        = map(string)
  description = "Map of GCS Bucket labels. A Data Classification level must be attached to each bucket using established resource labels.  The business owner must choose the highest data classification level of that data that the bucket may eventually contain."
}

# -------------------
# Storage Lifecycle Settings
variable "num_newer_versions" {
  type        = string
  description = "Number of new versions per object. Relevant only for versioned objects. The number of newer versions of an object to satisfy the delete condition."
  default     = "1"
}

variable "force_destroy" {
  description = "Option to enable force Destroy, default is false"
  type        = bool
  default     = false
}