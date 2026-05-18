/******************************************
	Scheduled Function Definition
 *****************************************/

resource "google_cloud_scheduler_job" "job" {
  count = var.scheduler_job == null ? 1 : 0

  name        = var.job_name
  project     = var.project_id
  region      = var.region
  description = var.job_description
  schedule    = var.job_schedule
  time_zone   = var.time_zone

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "PATCH"
    uri         = var.target_uri
    oauth_token {
      service_account_email = var.service_account
    }
    body        = base64encode("{\"settings\":{\"activationPolicy\":\"${var.operation}\"}}")
  }
}