data "template_file" "concourse_worker_init" {
  template = "${file(format("%s/%s", path.module, "concourse-worker.tpl"))}"

  vars {
    tsa_host              = "${google_compute_instance.concourse-web.network_interface.0.address}"
    tsa_port              = "2222"
    keys_bucket           = "${google_storage_bucket.keys-bucket.name}"
    concourse_version     = "${var.concourse_version}"
    service_account_email = "${google_service_account.cloud-proxy.email}"
    project_id            = "${var.project_id}"
  }
}

resource "google_compute_instance" "concourse-worker" {
  count        = "${var.number_of_workers}"
  name         = "concourse-worker-${count.index+1}"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  metadata_startup_script = "${data.template_file.concourse_worker_init.rendered}"

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
    scopes = ["cloud-platform", "storage-ro", "service-management", "service-control", "datastore"]
  }

  depends_on = ["google_sql_database_instance.concourse", "google_compute_instance.concourse-web"]
}
