data "template_file" "concourse_web_init" {
  template = "${file(format("%s/%s", path.module, "concourse-web.tpl"))}"
  vars {
    database_username   = "concourse"
    database_password   = "concourse"
    database_identifier = "${google_sql_database_instance.concourse.name}"
    database_replica    = "${google_sql_database_instance.concourse_replica.name}"
    database_name       = "${google_sql_database.concourse.name}"
    keys_bucket         = "${google_storage_bucket.keys-bucket.name}"
    project_id          = "${var.project_id}"
    region              = "${var.region}"
    external-url        = "https://${google_compute_address.concourse.address}"
    concourse_version   = "${var.concourse_version}"
  }
}
resource "google_service_account" "cloud-proxy" {
  depends_on = ["google_sql_database_instance.concourse"]
  account_id   = "concourse-proxy"
  display_name = "concourse-proxy"
}

resource "google_project_iam_binding" "cloud-proxy" {
  project = "${var.project_id}"
  role    = "roles/cloudsql.client"
  members = [
    "serviceAccount:${google_service_account.cloud-proxy.email}",
  ]
}

resource "google_compute_address" "concourse" {
  name = "concourse"
}

resource "google_compute_instance" "concourse-web" {
  depends_on = ["google_sql_database_instance.concourse", "google_compute_instance.bastion-host", "google_project_iam_binding.cloud-proxy"]

  name         = "concourse-web"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  metadata_startup_script = "${data.template_file.concourse_web_init.rendered}"

  tags = ["internal", "concourse-web"]

  boot_disk {
    initialize_params {
      image = "${var.latest_ubuntu}"
    }
  }

  allow_stopping_for_update = true

  network_interface {
    subnetwork         = "${google_compute_subnetwork.concourse-subnet.name}"
    subnetwork_project = "${var.network_project_id}"

    access_config {
      nat_ip = "${google_compute_address.concourse.address}"
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
