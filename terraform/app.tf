data "google_cloud_run_service" "api_lookup" {
  name     = google_cloud_run_service.api_service.name
  location = var.region
  depends_on = [
    google_cloud_run_service.api_service
  ]
}

# Cloud Run service
resource "google_cloud_run_service" "app_service" {
  name     = var.app_name
  location = var.region

  template {
    spec {
      containers {
        image = var.image_url_app
        ports {
          container_port = var.container_port
        }
        env {
          name  = "API_URL"
          value = google_cloud_run_service.api_service.status[0].url
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  depends_on = [
    google_cloud_run_service.api_service
  ]
}

# Allow unauthenticated access
resource "google_cloud_run_service_iam_member" "app_noauth" {
  location = google_cloud_run_service.app_service.location
  project  = var.project_id
  service  = google_cloud_run_service.app_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
  depends_on = [
    google_cloud_run_service.app_service
  ]
}