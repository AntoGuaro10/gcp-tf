output "bucket" {
  description = "Bucket resource."
  value       = google_storage_bucket.bucket
}

output "name" {
  description = "Bucket name."
  value       = google_storage_bucket.bucket.name
}
output "notification" {
  description = "GCS Notification self link."
  value       = local.notification ? google_storage_notification.notification[0].self_link : null
}
output "topic" {
  description = "Topic ID used by GCS."
  value       = local.notification ? google_pubsub_topic.topic[0].id : null
}
output "url" {
  description = "Bucket URL."
  value       = google_storage_bucket.bucket.url
}
