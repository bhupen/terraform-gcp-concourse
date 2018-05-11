add terraform module:
```terraform
module "vpc" {
  source = "github.com/dsbreese/concourse-vpc-module"

  network_project_id= "${var.network_project_id}"
  region = "${var.region}"
  prefix = "${var.prefix}"

}
```