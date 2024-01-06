terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
  }
}

resource "kubernetes_namespace" "client_namespace" {
  metadata {
    name = var.client_namespace
  }
}

module "mysql" {
  source = "./mysql"
  providers = {
    google = google
  }

  # Variables
  client_name                = var.client_name
  mysql_server_instance_name = var.mysql_server_instance_name
  db_password                = var.db_password
}

module "object-storage" {
  source = "./object-storage"
  providers = {
    google = google
  }

  # Variables
  client_name = var.client_name
  location    = var.region
}

module "secret_inject" {
  source = "./secret-inject"
  providers = {
    vault = vault
  }

  depends_on = [module.mysql, module.object-storage]

  # Variables
  client_namespace                   = var.client_namespace
  client_backend_env_secret          = var.client_backend_env_secret
  client_backend_env_secret_version  = var.client_backend_env_secret_version
  client_frontend_env_secret         = var.client_frontend_env_secret
  client_frontend_env_secret_version = var.client_frontend_env_secret_version
  vault_address                      = var.vault_address
  vault_terraform_token              = var.vault_terraform_token
  backend_env_params                 = var.backend_env_params
  frontend_env_params                = var.frontend_env_params
  bucket_config = {
    name        = module.object-storage.storage_sa_credentials.bucket_name
    private_key = module.object-storage.storage_sa_credentials.private_key
    secret_key  = module.object-storage.storage_sa_credentials.secret_key
  }
  mysql_config = {
    database_url = module.mysql.database_connection_url
  }
}

module "external-secret-operator" {
  source = "./external-secret-operator"
  providers = {
    kubernetes = kubernetes
    vault      = vault
  }

  depends_on = [module.secret_inject, kubernetes_namespace.client_namespace]

  # Variables
  vault_address                  = var.vault_address
  client_name                    = var.client_name
  client_namespace               = var.client_namespace
  secret_store_server            = var.secret_store_server
  secret_store_path              = var.secret_store_path
  secret_store_version           = var.secret_store_version
  secret_store_token_secret_name = var.secret_store_token_secret_name
}
