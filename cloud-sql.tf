locals {
  name_prefix = "${format("%s-%s-%s-%s", "concourse", var.env, var.region, random_id.database-name-postfix.hex)}"
}

resource "google_sql_database_instance" "concourse" {
  name             = "${format("%s-master", local.name_prefix)}"
  region           = "${var.region}"
  database_version = "POSTGRES_9_6"
  project          = "${var.project_id}"

  settings {
    tier = "db-f1-micro"

    availability_type = "REGIONAL"

    location_preference {
      zone = "${format("%s-%s", var.region, "a")}"
    }

    ip_configuration {
      ipv4_enabled = "true"
    }

    backup_configuration {
      binary_log_enabled = "true"
      enabled            = "true"
      start_time         = "21:59"
    }

    maintenance_window {
      day          = "7"
      hour         = "22"
      update_track = "stable"
    }
  }
}

resource "google_sql_database_instance" "concourse_replica" {
  name                 = "${format("%s-replica", local.name_prefix)}"
  region               = "${var.region}"
  database_version     = "${google_sql_database_instance.concourse.database_version}"
  project              = "${var.project_id}"
  master_instance_name = "${google_sql_database_instance.concourse.name}"

  settings {
    tier                   = "db-f1-micro"
    crash_safe_replication = "true"

    location_preference {
      zone = "${format("%s-%s", var.region, "c")}"
    }

    ip_configuration {
      ipv4_enabled = "true"
    }

    maintenance_window {
      day          = "6"
      hour         = "22"
      update_track = "stable"
    }
  }
}

resource "google_sql_database" "concourse" {
  name     = "concourse"
  instance = "${google_sql_database_instance.concourse.name}"
  project  = "${var.project_id}"

  depends_on = ["google_sql_database_instance.concourse"]
}

resource "google_sql_user" "users" {
  name       = "concourse"
  instance   = "${google_sql_database_instance.concourse.name}"
  password   = "concourse"
  host       = "cloudsqlproxy~%"
  project    = "${var.project_id}"
  depends_on = ["google_sql_database.concourse"]
}
