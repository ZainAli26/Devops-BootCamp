terraform {

  backend "gcs" {
    bucket = "bootcamp-deployments"
    prefix = "terraform/state" # Path inside the bucket
  }


  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Cloud Run service
resource "google_cloud_run_service" "api_service" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.image_url
        ports {
          container_port = var.container_port
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Allow unauthenticated access
resource "google_cloud_run_service_iam_member" "api_noauth" {
  location = google_cloud_run_service.api_service.location
  project  = var.project_id
  service  = google_cloud_run_service.api_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "api_service_url" {
  value = google_cloud_run_service.api_service.status[0].url
}
