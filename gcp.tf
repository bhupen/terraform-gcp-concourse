provider "google" {
  project = "${var.project_id}"
  region  = "${var.region}"

  credentials = "${file(var.credentials)}"
}

terraform {
  backend "gcs" {
    bucket  = "terraform-state-123"
    prefix  = "concourse-web"
    project = "project-1-201418"
  }
}
