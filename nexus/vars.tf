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

variable "baseip" {
  description = "base private IP"
  type        = "string"
  default     = "10.1.0.0"
}

