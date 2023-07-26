#---------------------------------------------------------------------------------------------
# Base GCP Variables
#---------------------------------------------------------------------------------------------

variable "project_id" {
  type        = string
  description = "The ID of the project in which the resource belongs."
}

variable "labels" {
  type        = map(string)
  description = "Map of GCP labels. A Data classification level must be attached to each resourcet using established resource labels. The business owner must choose the highest data classification level of that data that the bucket may eventually contain."
  validation {
    condition = (
      can(var.labels["classification"]) &&
      contains(["restricted", "sensitive", "internal-only", "public"], var.labels["classification"])
    )
    error_message = "Classification label must be one of the following: restricted, sensitive, internal-only, or public."
  }

  validation {
    condition = (
      can(var.labels["env"]) &&
      contains(["prod", "qa", "stage", "poc", "dev", "dr"], var.labels["env"])
    )
    error_message = "Environment label must be one of the following: prod, qa, stage, poc, dev, dr."
  }

  validation {
    condition = (
      can(var.labels["app_code"]) &&
      length(var.labels["app_code"]) == 3 &&
      can(regex("[a-z]", var.labels["app_code"]))
    )
    error_message = "Label app_code must be present, and must be 3 lowercase letters."
  }
}

#---------------------------------------------------------------------------------------------
# BigQuery Role Variables
#---------------------------------------------------------------------------------------------

variable "user_group" {
  type        = list(string)
  default     = []
  description = "List of group name to assign roles/bigquery.dataViewer and roles/bigquery.jobUserroles"
}

variable "admin_group" {
  type        = list(string)
  default     = []
  description = "List of groups to assign roles/bigquery.admin roles"
}

variable "ml_group" {
  type        = list(string)
  default     = []
  description = "List of groups to assign roles/bigquery.dataEditor and roles/bigquery.jobUser role"
}

#---------------------------------------------------------------------------------------------
# Dataset Variables
#---------------------------------------------------------------------------------------------

variable "dataset_id" {
  type        = string
  description = "ID of BigQuery Dataset"

  validation {
    condition     = length(var.dataset_id) < 1024 && can(regex("[\\w]*", var.dataset_id))
    error_message = "Dataset IDs can only contain letters, numbers, and underscores with a maximum length of 1024 characters."
  }
}

variable "dataset_name" {
  type        = string
  default     = null
  description = "Name of BigQuery Dataset."
}

variable "tables" {
  default = []
  type = list(object({
    table_id   = string,
    schema     = string,
    clustering = list(string),
    time_partitioning = object({
      expiration_ms            = string,
      field                    = string,
      type                     = string,
      require_partition_filter = bool,
    }),
    range_partitioning = object({
      field = string,
      range = object({
        start    = string,
        end      = string,
        interval = string,
      }),
    }),
    expiration_time = string,
    labels          = map(string),
  }))
  description = "A list of objects which include table_id, schema, clustering, time_partitioning, range_partitioning, expiration_time and labels."
}

variable "views" {
  description = "A list of objects which include table_id, which is view id, and view query"
  default     = []
  type = list(object({
    view_id        = string,
    query          = string,
    use_legacy_sql = bool,
    labels         = map(string),
  }))
}

# Format: list(objects)
# domain: A domain to grant access to.
# group_by_email: An email address of a Google Group to grant access to.
# user_by_email:  An email address of a user to grant access to.
# special_group: A special group to grant access to.
variable "access" {
  description = "An array of objects that define dataset access for one or more entities."
  type        = any

  # At least one owner access is required.
  default = [{
    role          = "roles/bigquery.dataOwner"
    special_group = "projectOwners"
  }]
}

variable "routines" {
  description = "A list of objects which include routine_id, routine_type, routine_language, definition_body, return_type, routine_description and arguments."
  default     = []
  type = list(object({
    routine_id      = string,
    routine_type    = string,
    language        = string,
    definition_body = string,
    return_type     = string,
    description     = string,
    arguments = list(object({
      name          = string,
      data_type     = string,
      argument_kind = string,
      mode          = string,
    })),
  }))
}

variable "protect_from_delete" {
  description = "Protects the dataset from deletion by Terraform apply or destroy operations. When true, a dataset requires two terraform executions to delete. On the first pass, the flag is altered. On the second, the dataset may be removed."
  default     = false
  type        = bool
}