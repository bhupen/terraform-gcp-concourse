data "template_file" "nexus_init" {
  template = "${file("nexus/nexus.tpl")}"
}

resource "google_compute_instance" "nexus" {
  name         = "${var.prefix}nexus"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  tags = ["nexus", "internal"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "${var.latest_ubuntu}"
    }
  }

  network_interface {
    subnetwork         = "${google_compute_subnetwork.nexus-subnet.name}"
    subnetwork_project = "${var.network_project_id}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = "${data.template_file.nexus_init.rendered}"

  service_account {
    scopes = ["cloud-platform"]
  }
}
