variable "project_id" {
  type = string
}

variable "region" {
  description = "Region to deploy in"
  type        = string
}

variable "concourse_version" {
  description = "The version on concourse to deploy"
}

variable "env" {
  description = "Environment"
  type        = string
}

variable "credentials" {
  description = "Credentials file location"
  type        = string
}

variable "number_of_workers" {
  description = "Number of Concourse workers."
  type        = string
}

provider "google" {
  project     = "${var.project_id}"
  region      = "${var.region}"
  credentials = "${file(var.credentials)}"
}

data "google_compute_zones" "available" {
  region  = "${var.region}"
  status  = "UP"
  project = "${var.project_id}"
}

resource "random_integer" "zone-offset" {
  min = 1
  max = "${length(data.google_compute_zones.available.names)}"
}

module "concourse" {
  source             = ".."
  credentials        = "${var.credentials}"
  project_id         = "${var.project_id}"
  network_project_id = "${var.project_id}"
  region             = "${var.region}"
  zone               = "${data.google_compute_zones.available.names[random_integer.zone-offset.result]}"
  concourse_version  = "${var.concourse_version}"
  env                = "${var.env}"
  number_of_workers = "${var.number_of_workers}"
}
