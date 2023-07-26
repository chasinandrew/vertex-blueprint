#---------------------------------------------------------------------------------------------
# Base GCP Variables
#---------------------------------------------------------------------------------------------

variable "project_id" {
  type        = string
  description = "ID of the project where resources will be deployed"
}

variable "labels" {
  type        = map(string)
  description = "A map of key/value label pairs to assign to the resource."
}

#---------------------------------------------------------------------------------------------
# IAM Variables
#---------------------------------------------------------------------------------------------

variable "artifact_registry_reader_group" {
  type        = list(string)
  description = "List of users to assign roles/artifactregistry.reader role"
}

variable "artifact_registry_writer_group" {
  type        = list(string)
  description = "List of users to assign roles/artifactregistry.writer role"
}

variable "artifact_registry_repo_admin_group" {
  type        = list(string)
  description = "List of users to assign roles/artifactregistry.repoAdmin role"
}

variable "artifact_registry_admin_group" {
  type        = list(string)
  description = "List of users to assign roles/artifactregistry.admin role"
}


#---------------------------------------------------------------------------------------------
# Artifact Registry Variables
#---------------------------------------------------------------------------------------------

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for artifact registry repository.  Possible values contain alphanumeric, dash, and underscore."
  validation {
    condition     = can(regex("^[-_a-zA-Z0-9]", var.naming_prefix))
    error_message = "The value of naming_prefix must only contain alphanumeric, dash, and underscore."
  }
}

variable "format" {
  type        = string
  description = "The format of packages that are stored in the repository. Possible values are DOCKER, MAVEN (preview), NPM (preview), PYTHON (preview), APT (alpha), HELM (alpha), YUM (alpha)"
  default     = "DOCKER"
  validation {
    condition     = contains(["DOCKER", "MAVEN", "NPM", "PYTHON", "APT", "HELM", "YUM"], var.format)
    error_message = "The value of format must be one of DOCKER, MAVEN, NPM, PYTHON, APT, HELM, or YUM."
  }
}

variable "location" {
  type        = string
  description = "The name of the location this repository is located in."
  default     = "us"
  validation {
    condition     = contains(["us", "us-central1", "us-east1", "us-east4", "us-west1", "us-west2", "us-west3", "us-west4"], var.location)
    error_message = "The value of location must be one of us, us-central1, us-east1, us-east4, us-west1, us-west2, us-west3, us-west4."
  }
}

variable "description" {
  type        = string
  description = "The user-provided description of the repository."
}

#---------------------------------------------------------------------------------------------
# Artifact Registry MAVEN Variables
#---------------------------------------------------------------------------------------------

variable "version_policy" {
  type        = string
  description = "Defines the versions that the registry will accept. Possible values are VERSION_POLICY_UNSPECIFIED, RELEASE, and SNAPSHOT"
  default     = "VERSION_POLICY_UNSPECIFIED"
  validation {
    condition     = contains(["VERSION_POLICY_UNSPECIFIED", "RELEASE", "SNAPSHOT"], var.version_policy)
    error_message = "The value of version_policy must be one of VERSION_POLICY_UNSPECIFIED, RELEASE, or SNAPSHOT."
  }
}

variable "allow_snapshot_overwrites" {
  type        = bool
  description = "The repository with this flag will allow publishing the same snapshot versions."
  default     = false
  validation {
    condition     = contains([true, false], var.allow_snapshot_overwrites)
    error_message = "The value of allow_snapshot_overwrites must be one of true or false."
  }
}