terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
  }
}

resource "vault_mount" "secret_kv" {
  path        = "secret"
  type        = "kv"
  options     = { version = "1" }
  description = "KV Version 1 secret engine mount"
}

resource "vault_kv_secret" "frontend_env_secret" {
  path      = "${vault_mount.secret_kv.path}/${var.client_frontend_env_secret}"
  data_json = jsonencode(var.frontend_env_params)
}

resource "vault_kv_secret" "backend_env_secret" {
  path = "${vault_mount.secret_kv.path}/${var.client_backend_env_secret}"
  data_json = jsonencode({
    SALT                          = var.backend_env_params.SALT
    JWT_SECRET                    = var.backend_env_params.JWT_SECRET
    MINIO_SSL                     = true
    MINIO_HOST                    = "storage.googleapis.com"
    MINIO_ROOT_USER               = ""
    MINIO_ROOT_PASSWORD           = ""
    MINIO_ACCESS_KEY              = var.bucket_config.private_key
    MINIO_SECRET_KEY              = var.bucket_config.secret_key
    MINIO_S3_API_PORT             = "443"
    MINIO_BUCKET_NAME             = var.bucket_config.name
    DATABASE_URL                  = var.mysql_config.database_url
    ACCESS_TOKEN_RSA_PRIVATE_KEY  = var.backend_env_params.ACCESS_TOKEN_RSA_PRIVATE_KEY
    ACCESS_TOKEN_RSA_PUBLIC_KEY   = var.backend_env_params.ACCESS_TOKEN_RSA_PUBLIC_KEY
    REFRESH_TOKEN_RSA_PRIVATE_KEY = var.backend_env_params.REFRESH_TOKEN_RSA_PRIVATE_KEY
    REFRESH_TOKEN_RSA_PUBLIC_KEY  = var.backend_env_params.REFRESH_TOKEN_RSA_PUBLIC_KEY
  })
}
