resource "google_compute_network" "nexus" {
  name                    = "${var.prefix}nexus"
  project                 = "${var.network_project_id}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "nexus-subnet" {
  name          = "${var.prefix}nexus-${var.region}"
  ip_cidr_range = "${var.baseip}/24"
  network       = "${google_compute_network.nexus.self_link}"
  project       = "${var.network_project_id}"
}

// Allow http to nexus
resource "google_compute_firewall" "nexus" {
  name    = "${var.prefix}nexus"
  network = "${google_compute_network.nexus.name}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["nexus"]
  project     = "${var.network_project_id}"
}
