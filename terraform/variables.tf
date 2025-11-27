variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "gaggar-dev"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "api-service"
}

variable "app_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "demo-app"
}

variable "image_url" {
  description = "Docker image URL in Artifact Registry"
  type        = string
  default     = "us-east1-docker.pkg.dev/gaggar-dev/cloud-bootcamp/api"
}

variable "image_url_app" {
  description = "Docker image URL in Artifact Registry"
  type        = string
  default     = "us-east1-docker.pkg.dev/gaggar-dev/cloud-bootcamp/app"
}

variable "container_port" {
  description = "Container port your app listens on"
  type        = number
  default     = 8080
}

variable "slack_webhook_url" {
  type        = string
  description = "The Slack webhook URL for notifications"
  sensitive   = true
}