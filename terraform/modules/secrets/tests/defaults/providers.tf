terraform {
  required_version = ">= 0.13.0"
  required_providers {
    google = {
      version = ">= 3.9.0, < 5.0.0"
    }

    google-beta = {
      version = ">= 3.9.0, < 5.0.0"
    }
  }

  cloud {}
}

#---------------------------------------------------------------------------------------------
# GCP Configuration
#---------------------------------------------------------------------------------------------

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
}