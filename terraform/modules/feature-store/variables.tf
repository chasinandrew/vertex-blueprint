#---------------------------------------------------------------------------------------------
# Base GCP Variables
#---------------------------------------------------------------------------------------------
variable "project_id" {
  type        = string
  description = "The ID of the project in which the resource belongs."
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Map of GCP labels"
}

variable "region" {
  type        = string
  description = "GCP region which the feature store belongs."
  default     = "us-east4"
}

variable "app_code" {
  type        = string
  description = "code or abbreviation of the application, eg. dsa"
  default     = ""
}

variable "app_environment" {
  type        = string
  description = "code or abbreviation of the application environment, eg. train,stage,prod"
  default     = ""
}

variable "force_destroy" {
  type        = bool
  description = "any EntityTypes and Features for this Featurestore will also be deleted."
  default     = true
}

variable "node_count" {
  type        = number
  description = "The number of nodes for each cluster."
  default     = 1
}