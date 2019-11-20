provider "google" {
  project = var.project_id
  region  = var.region

  credentials = var.credentials
}

terraform {
  backend "gcs" {
    credentials = "gcp.json"
    bucket  = "terraform-state-123"
    prefix  = "concourse-web"
  }
}
