#---------------------------------------------------------------------------------------------
# Base GCP Variables
#---------------------------------------------------------------------------------------------

variable "project_id" {
  type        = string
  description = "ID of the project where resources will be deployed"
}

variable "ignore_secret_change" {
  type        = bool
  description = "If set to true, we will not change/reset the secret value back to the code"
  default     = false
}

variable "labels" {
  description = "A map of key/value label pairs to assign to the resource."
  type        = map(string)
}

#---------------------------------------------------------------------------------------------
# Secret Manager Variables
#---------------------------------------------------------------------------------------------

variable "secret_id" {
  type        = string
  description = "ID of the secret. This must be unique within the project."
}

variable "location" {
  type        = string
  description = "The location to replicate secret data"
}

variable "next_rotation_time" {
  type        = string
  description = "Timestamp in UTC at which the Secret is scheduled to rotate. Secret Manager will send a Pub/Sub notification to the topics configured on the Secret. If var.rotation_period is set, then var.next_rotation_time must be set."

}

variable "rotation_period" {
  type        = string
  description = "The Duration between rotation notifications. next_rotation_time will be advanced by this period when the service automatically sends rotation notifications. Must be in seconds and at least 3600s (1h) and at most 3153600000s (100 years).  If var.rotation_period is set, then var.next_rotation_time must be set."
  default     = "7776000s"

  validation {
    condition     = can(regex("^[1-9][0-9][0-9][0-9]{0,6}s$", var.rotation_period))
    error_message = "Rotation period does not match the required format. Please change your input to match the following, 7776000s."
  }
}

variable "expire_time" {
  type        = string
  description = "Timestamp in UTC when the Secret is scheduled to expire."
}

variable "secret_data" {
  type        = string
  description = "The secret data. Must be no larger than 64KiB. Note: This property is sensitive and will not be displayed in the plan."
}

variable "secret_accessor_group" {
  type        = list(any)
  description = "List of users/groups with role roles/secretmanager.secretAccessor"

  validation {
    condition     = alltrue([for v in var.secret_accessor_group : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Accessor Group must not be allUsers or allAuthenticatedUsers."
  }
}

variable "pub_sub_topic" {
  type        = string
  description = "Name of pub-sub topic where the secret rotation notifications should be published. Use '../pubsub' module for creating these topics"
  default     = ""
}

variable "secret_manager_admin_group" {
  type        = list(string)
  description = "List of users to assign roles/secretmanager.admin role"

  validation {
    condition     = alltrue([for v in var.secret_manager_admin_group : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Secret Manager Admin Group must not be allUsers or allAuthenticatedUsers."
  }

}

variable "secret_manager_accessor_group" {
  type        = list(string)
  description = "List of users to assign roles/secretmanager.secretAccessor role"

  validation {
    condition     = alltrue([for v in var.secret_manager_accessor_group : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Secret Manager Accessor Group must not be allUsers or allAuthenticatedUsers."
  }

}

variable "secret_manager_viewer_group" {
  type        = list(string)
  description = "List of users to assign roles/secretmanager.viewer role"

  validation {
    condition     = alltrue([for v in var.secret_manager_viewer_group : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Secret Manager Viewer Group must not be allUsers or allAuthenticatedUsers."
  }

}

variable "secret_manager_version_manager_group" {
  type        = list(string)
  description = "List of users to assign roles/secretmanager.secretVersionManager role"

  validation {
    condition     = alltrue([for v in var.secret_manager_version_manager_group : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Secret Manager Version Manager Group must not be allUsers or allAuthenticatedUsers."
  }
}

variable "secret_manager_version_adder_group" {
  type        = list(string)
  description = "List of users to assign roles/secretmanager.secretVersionAdder role"

  validation {
    condition     = alltrue([for v in var.secret_manager_version_adder_group : (!contains(["allUsers", "allAuthenticatedUsers"], v))])
    error_message = "Secret Manager Version Adder Group must not be allUsers or allAuthenticatedUsers."
  }
}