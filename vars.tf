variable "latest_ubuntu" {
  type    = "string"
  default = "ubuntu-1404-trusty-v20180308"
}

variable "project_id" {
  type = "string"
}

variable "network_project_id" {
  type = "string"
}

variable "region" {
  description = "Region to deploy in"
  type        = "string"
}

variable "zone" {
  description = "Zone to deploy in"
  type        = "string"
}

variable "prefix" {
  description = "Environment entity prefix"
  type        = "string"
  default     = ""
}

variable "service_account_email" {
  description = "service account email"
  type        = "string"
  default     = ""
}

resource "random_id" "database-name-postfix" {
  byte_length = 8
}

resource "random_id" "cloud-storage-bucket" {
  byte_length = 8
}

variable "concourse_version" {
  description = "The version on concourse to deploy"
}

variable "env" {
  description = "Environment"
  type        = "string"
}
