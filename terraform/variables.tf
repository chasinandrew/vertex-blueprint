
variable "user_domain" {
  type = string
}

variable "bucket_name" { # TODO: derived
  type        = string
  description = "Bucket name for notebooks"
  default     = "gcp-dsa-gcs"
}

variable "bucket_sa_display_name" {
  type        = string
  description = "Display name for bucket Service Account"
  default     = "GCS Service Account for DSA"
}

variable "gcp_project_id" {
  type        = string
  description = "The project to deploy resources into"
}


variable "gcp_region" {
  type        = string
  description = "Location for GCP Resource Deployment"
}

variable "host_project_id" {
  type        = string
  description = "Shared VPC Host Project for Notebook"
  default     = null
}

variable "network" { # default
  type        = string
  description = "Network to use for Notebook"
}

variable "metadata" {
  type        = map(string)
  description = "Input to Notebook metadata"
  default = {
    startup-script-url        = ""
    notebook-upgrade-schedule = "21 11 * * WED"
  }
}

variable "artifact_registry_reader_group" {
  type        = list(string)
  description = "List of users to assign roles/artifactregistry.reader role"
  default     = []
}

variable "artifact_registry_writer_group" {
  type        = list(string)
  description = "List of users to assign roles/artifactregistry.writer role"
  default     = []
}

variable "artifact_registry_repo_admin_group" {
  type        = list(string)
  description = "List of users to assign roles/artifactregistry.repoAdmin role"
  default     = []
}

variable "artifact_registry_admin_group" {
  type        = list(string)
  description = "List of users to assign roles/artifactregistry.admin role"
  default     = []
}
variable "artifact_registry_description" {
  type        = string
  description = "Artifact Registry for Vertex AI."
  default     = "Artifact Registry for Vertex AI."
}

variable "artifact_registry_format" {
  type        = string
  description = "Default format for Artifact Registry rep"
  default     = "DOCKER"
}

variable "buckets" {
  type = list(object({
    gcp_project_id     = optional(string)
    bucket_name        = optional(string)
    bucket_labels      = optional(map(string))
    bucket_viewers     = optional(list(string))
    bucket_admins      = optional(list(string))
    bucket_creators    = optional(list(string))
    force_destroy      = optional(bool)
  }))
  description = "List of buckets."
}

variable "datasets" {
  type = list(object({
    project_id  = string
    labels      = list(map(string))
    user_group  = optional(list(string))
    admin_group = optional(list(string))
    ml_group    = optional(list(string))
    dataset_id  = string
  }))
  description = "List of datasets."
}

variable "notebooks" {
  type        = list(map(string))
  description = "Input variables for reference architecture - dynamic notebooks"
  validation {
    condition = alltrue([
      for nb in var.notebooks : can(nb["user"]) && nb["user"] == lower(nb["user"])
    ])
    error_message = "A notebook user/owner is required and it must be all-lowercase."
  }
  validation {
    condition = alltrue([
      for nb in var.notebooks : can(nb["image_family"]) && nb["image_family"] == lower(nb["image_family"])
    ])
    error_message = "A notebook image family is required and it must be all-lowercase."
  }
}

variable "labels" {
  type        = map(string)
  description = "Input labels from cloud workspace"
}

variable "deeplearning_project" {
  type        = string
  description = "GCP public project hosting deep learning VM images"
  default     = "deeplearning-platform-release"
}

variable "default_machine_type" {
  type        = string
  description = "Default machine type value to be used for Notebook VMs"
  default     = "n1-standard-4"
}

variable "default_zone" {
  type        = string
  description = "Default location for Workbench Notebooks"
  default     = "us-east4-b"
}
