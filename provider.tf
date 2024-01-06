provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
}

data "google_container_cluster" "gke_cluster" {
  name       = var.cluster_name
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  token = data.google_client_config.provider.access_token
  host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
}

provider "vault" {
  address = var.vault_address
  token = var.vault_terraform_token
}
