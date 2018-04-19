data "template_file" "bastion_host_init" {
  template = "${file("bastion-host.tpl")}"

  vars {
    concourse_version = "${var.concourse_version}"
    keys_bucket       = "${google_storage_bucket.keys-bucket.name}"
  }
}

resource "google_compute_instance" "bastion-host" {
  name         = "${var.prefix}bastion-host"
  machine_type = "f1-micro"
  zone         = "${var.zone}"

  tags = ["bastion-host", "internal"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "${var.latest_ubuntu}"
    }
  }

  network_interface {
    subnetwork         = "${google_compute_subnetwork.concourse-subnet.name}"
    subnetwork_project = "${var.network_project_id}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = "${data.template_file.bastion_host_init.rendered}"

  depends_on = ["google_storage_bucket.keys-bucket"]
}
