terraform {
  required_version = "~>1.1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.9.0, < 5.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.9.0, < 5.0.0"
    }
  }
}