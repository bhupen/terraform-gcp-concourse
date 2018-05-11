variable "network_project_id" {
  type = "string"
}

variable "region" {
  description = "Region to deploy in"
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
  default     = "10.0.0.0"
}