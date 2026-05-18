# Source code -> https://github.com/terraform-google-modules/terraform-google-lb-http/blob/v11.1.0/modules/serverless_negs/README.md

terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.84"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.84"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.1"
    }
  }
}