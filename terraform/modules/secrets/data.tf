data "google_pubsub_topic" "topic" {
  name    = var.pub_sub_topic
  project = var.project_id
}
