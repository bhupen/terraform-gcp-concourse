resource "google_sql_database_instance" "concourse" {
  name             = "concourse-${random_id.database-name-postfix.hex}"
  region           = "${var.region}"
  database_version = "POSTGRES_9_6"
  project          = "${var.project_id}"

  settings {
    tier = "db-f1-micro"

    availability_type = "REGIONAL"

    ip_configuration {
      ipv4_enabled = "true"
    }

    location_preference {
      zone = "${var.zone}"
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
