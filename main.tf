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
