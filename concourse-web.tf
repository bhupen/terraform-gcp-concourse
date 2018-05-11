data "template_file" "concourse_web_init" {
  template = "${file("concourse-web.tpl")}"

  vars {
    database_username   = "concourse"
    database_password   = "concourse"
    database_identifier = "${google_sql_database_instance.concourse.name}"
    database_replica    = "${google_sql_database_instance.concourse_replica.name}"
    database_name       = "${google_sql_database.concourse.name}"
    keys_bucket         = "${google_storage_bucket.keys-bucket.name}"
    project_id          = "${var.project_id}"
    region              = "${var.region}"

    external-url      = "https://localhost/"
    concourse_version = "${var.concourse_version}"
  }
}

resource "google_service_account" "cloud-proxy" {
  account_id   = "concourse-proxy"
  display_name = "concourse-proxy"

  depends_on = ["google_sql_database_instance.concourse"]
}

resource "google_project_iam_binding" "cloud-proxy" {
  project = "${var.project_id}"
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:concourse-proxy@${var.project_id}.iam.gserviceaccount.com",
  ]

  depends_on = ["google_service_account.cloud-proxy"]
}

resource "google_compute_instance" "concourse-web" {
  name         = "concourse-web"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  provisioner "local-exec" {
    command = <<EOT
      openssl genrsa -out concourse-web.key 2048
      openssl req -new -key concourse-web.key -out concourse-web.csr <<EOF
US
Illinois
Chicago
CNA
CNAX
xpteam
CNAXDevTeam@cnahardy.com
T1t2t3t4

EOF
      openssl x509 -req -days 365 -in concourse-web.csr -signkey concourse-web.key -out concourse-web.crt
      gsutil cp concourse-web.crt concourse-web.csr concourse-web.key gs://${google_storage_bucket.keys-bucket.name}/keys/web
    EOT
  }

  metadata_startup_script = "${data.template_file.concourse_web_init.rendered}"

  tags = ["concourse-web", "internal"]

  boot_disk {
    initialize_params {
      image = "${var.latest_ubuntu}"
    }
  }

  allow_stopping_for_update = true

  network_interface {
    subnetwork         = "${module.vpc.concourse-subnet-name}"
    subnetwork_project = "${var.network_project_id}"

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  depends_on = ["google_sql_database_instance.concourse", "google_compute_instance.bastion-host", "google_project_iam_binding.cloud-proxy"]
}
