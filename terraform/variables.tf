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

#TODO: include more options for vars
variable "buckets" {
  type = list(object({
    bucket_name          = string
    bucket_labels        = optional(map(string), {})
    sa_display_name      = optional(string, "")
    sa_name              = optional(string, "")
    bucket_viewers       = optional(list(string), [])
    bucket_admins        = optional(list(string), [])
    bucket_creators      = optional(list(string), [])
    num_newer_versions   = optional(number, 1)
    notebook_obj_admin   = optional(bool, false)
    notebook_obj_creator = optional(bool, false)
    notebook_obj_viewer  = optional(bool, false)
  }))
  description = "List of buckets."

  default = []
}

variable "datasets" {
  type = list(object({
    user_group              = list(string)
    admin_group             = list(string)
    ml_group                = list(string)
    dataset_id              = string
    notebook_dataset_viewer = optional(bool, false)
    notebook_dataset_editor = optional(bool, false)
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


variable "secrets" {
  type = list(object({
    labels                        = optional(map(string), {})
    secret_id                     = string
    rotation_period               = optional(string, "31536000s")
    expire_time                   = optional(string, "")
    secret_manager_admin_group    = optional(list(string), [])
    secret_accessor_group         = optional(list(string), [])
    secret_manager_accessor_group = optional(list(string), [])
    notebook_secret_accessor      = optional(bool, false)
    secret_manager_viewer_group   = optional(list(string), [])
  }))
  default     = []
  description = "List of secrets to access."
}

variable "project_services" {

  type = list(string)

  description = "List of required project services in the blueprint"
  default     = ["pubsub.googleapis.com", "compute.googleapis.com", "monitoring.googleapis.com", "logging.googleapis.com", "aiplatform.googleapis.com", "containerfilesystem.googleapis.com", "dns.googleapis.com", "iamcredentials.googleapis.com", "iam.googleapis.com", "sts.googleapis.com", "cloudresourcemanager.googleapis.com", "autoscaling.googleapis.com", "notebooks.googleapis.com", "artifactregistry.googleapis.com", "ml.googleapis.com", "dataform.googleapis.com", "serviceusage.googleapis.com", "secretmanager.googleapis.com"]
}