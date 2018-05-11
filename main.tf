module "vpc" {
  source = "vpc"

  network_project_id= "${var.network_project_id}"
  region = "${var.region}"
  prefix = "${var.prefix}"

}