terraform {
  required_version = ">= 0.13.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.9.0, < 5.0.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.9.0, < 5.0.0"
    }
  }
  # cloud {

  # }
}
  provider "google" {
    project = var.gcp_project_id
    region  = var.gcp_region
  }

  provider "google-beta" {
    project = var.gcp_project_id
    region  = var.gcp_region
  }
