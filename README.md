Project to deploy concourse to GCP using Cloud SQL, GCE and cloud-sql-proxy. We will use GCP native resources to deploy and maintain the concourse resources. We avoid using BOSH. Hence we don’t need to deploy and manage the BOSH VM in the concourse project. We use a GCP native replicated PostgreSQL offering. GCP PostgreSQL is currently BETA. We hope it will be GA soon. 

Create a test.tfvars.
```terraform
project_id = "project_id"
network_project_id = "network_project_id"
region = "region"
zone = "zone"
concourse_version = "v3.10.0"
env = "dev"
```


To Apply
```terraform
terraform apply -var-file="test.tfvars"
```