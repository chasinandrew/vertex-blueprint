
#---------------------------------------------------------------------------------------------
# GCP Testing Variables
#---------------------------------------------------------------------------------------------

variable "gcp_project_id" {
  type        = string
  description = "The project to run tests against"
}

variable "gcp_region" {
  type        = string
  description = "Location for GCP Resource Deployment"
}