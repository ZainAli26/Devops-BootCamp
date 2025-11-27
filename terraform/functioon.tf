# -------------------------------
# 1. Secret for Slack Webhook
# -------------------------------
resource "google_secret_manager_secret" "slack_webhook" {
  secret_id = "slack-webhook"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "slack_webhook_version" {
  secret      = google_secret_manager_secret.slack_webhook.id
  secret_data = var.slack_webhook_url
}

locals {
    repo_path = "${path.root}/.."
    package_name = "cloud-bootcamp"
}

data "archive_file" "function_zip" {
    type = "zip"
    source_dir = "${local.repo_path}/cloud_function"
    output_path = "${local.repo_path}/packages/${local.package_name}.zip"
}

# -------------------------------
# 2. Pub/Sub Topic
# -------------------------------
resource "google_pubsub_topic" "stock_check_topic" {
  name = "stock-check-topic"
}

# -------------------------------
# 4. Storage bucket for function source
# -------------------------------
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-functions"
  location = var.region
}

resource "google_storage_bucket_object" "function_archive" {
  name   = "notify_low_stock.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_zip.output_path
}

# -------------------------------
# 3. Cloud Function
# -------------------------------
resource "google_cloudfunctions_function" "notify_low_stock" {
  name                  = "notify-low-stock"
  runtime               = "python311"
  region                = var.region
  entry_point           = "notify_low_stock"
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name
  event_trigger {
      event_type = "google.pubsub.topic.publish"
      resource   = google_pubsub_topic.stock_check_topic.id 
  }
  timeout               = 60

  secret_environment_variables {
    key    = "SLACK_WEBHOOK_URL"                         # environment variable name
    project_id = var.project_id                           # GCP project ID
    secret  = google_secret_manager_secret.slack_webhook.secret_id
    version = "latest"
  }
  depends_on = [
      google_storage_bucket_object.function_archive
  ]
}

# -------------------------------
# 5. Cloud Scheduler Job
# -------------------------------
resource "google_cloud_scheduler_job" "stock_check_job" {
  name      = "stock-check-job"
  schedule  = "*/5 * * * *" # Every 5 minutes
  time_zone = "Etc/UTC"

  pubsub_target {
    topic_name = google_pubsub_topic.stock_check_topic.id
    data       = base64encode("{}") # empty payload
  }
}
