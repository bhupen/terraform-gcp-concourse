data "template_file" "concourse_web_init" {
  template = "${file("concourse-web.tpl")}"

  vars {
    database_username   = "concourse"
    database_password   = "concourse"
    database_identifier = "${google_sql_database_instance.concourse.name}"
    database_name       = "${google_sql_database.concourse.name}"
    keys_bucket         = "${google_storage_bucket.keys-bucket.name}"
    project_id          = "${var.project_id}"
    region              = "${var.region}"

    external-url      = "http://localhost/"
    concourse_version = "${var.concourse_version}"
  }
}

resource "google_service_account" "cloud-proxy" {
  account_id   = "concourse-proxy"
  display_name = "concourse-proxy"
}

resource "google_project_iam_binding" "cloud-proxy" {
  project = "${var.project_id}"
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:concourse-proxy@${var.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_compute_instance" "concourse-web" {
  name         = "concourse-web"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  metadata_startup_script = "${data.template_file.concourse_web_init.rendered}"

  tags = ["internal"]
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
      // Ephemeral IP
    }
  }
  service_account {
    scopes = ["cloud-platform"]
  }
}
