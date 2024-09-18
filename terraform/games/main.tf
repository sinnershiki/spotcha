terraform {
  required_version = "1.9.5"

  backend "gcs" {
    bucket = "<tf state bucket name>"
    prefix = "games"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.2.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "6.2.0"
    }
  }
}
