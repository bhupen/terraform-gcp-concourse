resource "google_storage_bucket" "keys-bucket" {
  name          = "concourse-keys"
  force_destroy = true
}
