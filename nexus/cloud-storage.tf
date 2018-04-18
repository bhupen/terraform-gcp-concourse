resource "google_storage_bucket" "keys-bucket" {
  name          = "nexus-${random_id.cloud-storage-bucket.hex}"
  force_destroy = true
}
