terraform {
  required_version = ">= 0.12"

  required_providers {
    google = ">= 4.0, < 4.85"
    google-beta = "< 5.14.0"
  }
}
