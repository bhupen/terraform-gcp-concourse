resource "google_storage_bucket" "blob-store-bucket" {
  name          = "nexus-${random_id.cloud-storage-bucket.hex}"
  force_destroy = true
}
