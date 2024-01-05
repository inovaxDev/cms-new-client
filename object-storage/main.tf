terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}


resource "random_id" "name_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "client_bucket" {
  name          = "${var.client_name}-bucket-${random_id.name_suffix.hex}"
  location      = var.location
  force_destroy = true
}

resource "google_service_account" "storage_sa" {
  account_id   = "${var.client_name}-storage-sa"
  display_name = "${var.client_name} Storage Service Account"
}

resource "google_storage_bucket_iam_binding" "storage_sa_binding" {
  bucket = google_storage_bucket.client_bucket.name
  role   = "roles/storage.objectAdmin"

  depends_on = [google_storage_bucket.client_bucket, google_service_account.storage_sa]

  members = [
    "serviceAccount:${google_service_account.storage_sa.email}",
  ]
}

resource "google_storage_hmac_key" "hmac_key" {
  service_account_email = google_service_account.storage_sa.email

  depends_on = [google_service_account.storage_sa]
}

output "storage_sa_credentials" {
  value = {
    account_id  = google_service_account.storage_sa.account_id
    bucket_name = google_storage_bucket.client_bucket.name
    secret_key  = google_storage_hmac_key.hmac_key.secret
    private_key = google_storage_hmac_key.hmac_key.access_id
  }
}
