resource "google_pubsub_topic" "mytopic" {
  name = "StackDriverTopic"
}

resource "google_service_account" "cloud-logging" {
  account_id   = "logstash-pubsub-subscriber"
  display_name = "logstash-pubsub-subscriber"
}

resource "google_project_iam_member" "cloud-logging" {
  project = "${var.project_id}"	
  role    = "roles/pubsub.admin"
  member  = "serviceAccount:${google_service_account.cloud-logging.email}"
}

resource "google_service_account_key" "cloud-logging" {
  service_account_id = "${google_service_account.cloud-logging.name}"
}

resource "google_logging_project_sink" "PubSubSink" {
    name = "StackDriverSink"
    destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/StackDriverTopic"
    filter = "${var.filter}"
    unique_writer_identity = false
}
