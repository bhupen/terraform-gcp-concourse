resource "google_compute_network" "concourse" {
  name                    = "${var.prefix}concourse"
  project                 = "${var.network_project_id}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "concourse-subnet" {
  name          = "${var.prefix}concourse-${var.region}"
  ip_cidr_range = "${var.baseip}/24"
  network       = "${google_compute_network.concourse.self_link}"
  project       = "${var.network_project_id}"
}

// Allow SSH to BOSH bastion
resource "google_compute_firewall" "bastion-host" {
  name    = "${var.prefix}bastion-host"
  network = "${google_compute_network.concourse.name}"
  source_ranges = ["74.125.0.0/16","173.194.0.0/16"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["bastion-host"]
  project     = "${var.network_project_id}"
}

// Allow all traffic within subnet
resource "google_compute_firewall" "intra-subnet-open" {
  name    = "${var.prefix}intra-subnet-open"
  network = "${google_compute_network.concourse.name}"
  project = "${var.network_project_id}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  source_tags = ["internal"]
}

// Allow http to concourse-web
resource "google_compute_firewall" "concourse-web" {
  name    = "${var.prefix}concourse-web"
  network = "${google_compute_network.concourse.name}"
  source_ranges = ["159.10.134.170/32","74.125.0.0/16","173.194.0.0/16"]
  
  allow {
    protocol = "tcp"
    ports    = ["443","22"]
  }

  target_tags = ["concourse-web"]
  project     = "${var.network_project_id}"
}

output "concourse-subnet-name" {
  value = "${google_compute_subnetwork.concourse-subnet.name}"
}
