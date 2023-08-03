#---------------------------------------------------------------------------------------------
# Base GCP Variables
#---------------------------------------------------------------------------------------------
variable "project_id" {
  description = "The project in which the resource belongs."
  type        = string
}

#---------------------------------------------------------------------------------------------
# Base IAM Variables
#---------------------------------------------------------------------------------------------

variable "entity_type" {
  description = "Type of entity or resource to which IAM policies/bindings will be assigned."
  type        = string
  validation {
    condition = contains([
      "artifact_registry_repository",
      "cloud_run",
      "project",
      "bigquery_dataset",
      "bigquery_dataset_legacy",
      "pubsub_subscription",
      "pubsub_topic",
      "secret",
      "service_account",
      "storage_bucket"
    ], var.entity_type)
    error_message = "The value of entity_type must be one project."
  }
}

variable "entity_region" {
  description = <<INFO
    Region of resource targeted for IAM permission assignment. Region is only required for some entity types including:

      `artifact_registry_repository`
      `cloud_run`
      `subnet`
  INFO
  type        = string
  default     = null
}

variable "entities" {
  description = <<INFO
    List of entities or resources on which IAM policies/bindings will be assigned. The value that needs to be provided depends on the entity type.  Most IAM bindings will accept the resource's "name" value and those that don't are listed below.

      bigquery_dataset: requires `dataset_id`
      secret: requires `secret_id`

  INFO
  type        = list(string)
  default     = []
}

variable "bindings" {
  description = "Map of role (key) and list of members (value) to add the IAM policies/bindings"
  type        = map(list(string))
  default     = {}
}

variable "bindings_by_principal" {
  description = <<INFO
    Map of principal (key) and list of roles (value) to add the IAM policies/bindings. This variable is not intended for common use and should only be used with entity_type `project`.
  INFO
  type        = map(list(string))
  default     = {}
}

variable "conditional_bindings" {
  description = "List of maps of role, conditions, and the members to add the IAM policies/bindings."
  type = list(object({
    role        = string
    title       = string
    description = string
    expression  = string
    members     = list(string)
  }))
  default = []
}

variable "mode" {
  description = "Mode for adding the IAM policies/bindings, additive and authoritative"
  type        = string
  default     = "additive"
}

#---------------------------------------------------------------------------------------------
# Service-specific Variables
#---------------------------------------------------------------------------------------------