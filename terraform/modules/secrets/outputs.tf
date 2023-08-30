output "pub_sub_topic" {
  value       = data.google_pubsub_topic.topic.*
  description = "Please add a description."
}

output "pub_sub_topic_id" {
  value       = data.google_pubsub_topic.topic.id
  description = "Please add a description."
}

output "pub_sub_topic_retention" {
  value       = data.google_pubsub_topic.topic.message_retention_duration
  description = "Please add a description."
}

output "pub_sub_topic_storage_policy" {
  value       = data.google_pubsub_topic.topic.message_storage_policy
  description = "Please add a description."
}

output "id" {
  value       = google_secret_manager_secret.secret_basic.id
  description = "An identifier for the resource with format `projects/{{project}}/secrets/{{secret_id}}`"
}

output "secret_id" {
  value       = google_secret_manager_secret.secret_basic.secret_id
  description = "Secret ID"
}
output "secret_expire_time" {
  value       = google_secret_manager_secret.secret_basic.expire_time
  description = "Please add a description."
}

output "secret_next_rotation" {
  value       = google_secret_manager_secret.secret_basic.rotation[0].*
  description = "Please add a description."
}

output "secret_version" {
  value       = google_secret_manager_secret_version.secret_version_basic.*.id
  description = "Version of the secret."
}

output "secret" {
  value       = google_secret_manager_secret.secret_basic.*
  description = "Please add a description."
}