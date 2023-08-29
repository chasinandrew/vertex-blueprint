#TODO: remove this variable, domain restricted sharing removes the need for this variable validation
variable "user_domain" {
  type        = string
  description = "3-4 ID Domain Name"
  default     = "hca.corpad.net"
}

variable "bucket_name" { # TODO: derived
  type        = string
  description = "Bucket name for notebooks"
  default     = "gcp-dsa-gcs"
  #TODO: verify validation done by bucket module
}

variable "bucket_sa_display_name" { # TODO: default
  type        = string
  description = "Display name for bucket Service Account"
  default     = "GCS Service Account for DSA"
  #TODO: verify validation done by bucket module
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

variable "artifact_registry_format" {
  type        = string
  description = "Default format for Artifact Registry rep"
  default     = "DOCKER"
}

variable "buckets" {
  type        = list(map(string))
  description = "List of buckets."
}

variable "datasets" {
  type        = list(map(string))
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

variable "dataset_id" {
  type        = string
  description = "Prefix to the dataset ID. "
  validation {
    condition = (
      can(regex("^[0-9A-Za-z_]+$", var.dataset_id_prefix))
    )
    error_message = "A dataset ID prefix is required and it can contain letters (uppercase or lowercase), numbers, and underscores"
  }
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
