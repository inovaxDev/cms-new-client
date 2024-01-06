# GCP Config
variable "project" {
  description = "ID do projeto no GCP"
}

variable "region" {
  description = "Região do GCP onde o cluster será criado"
}

variable "credentials_file" {
  description = "Caminho para o arquivo de credenciais do GCP"
}

variable "dns_zone_name" {
  description = "Nome da Cloud DNS zone"
}

variable "svc_account_email" {
  description = "E-mail que será referenciado"
}

# Cluster Config
variable "cluster_name" {
  description = "Nome do cluster"
}

# Let's Encrypt Config
variable "letsencrypt_email" {
  description = "LetsEncrypt Email"
}

# SecretStore
variable "secret_store_server" {
  description = "Server link for the secret store backend"
}

variable "secret_store_path" {
  description = "Path of the secret denied"
}

variable "secret_store_version" {
  description = "Version of the secret"
}

variable "secret_store_token_secret_name" {
  description = "Name of the secret with the access token"
}

# Vault Config
variable "vault_address" {
  description = "Vault Url Address"
}

variable "vault_terraform_token" {
  description = "Vault Token for Terraform"
}

variable "vault_server_domain" {
  description = "Vault Server Domain"
}

# Vault Env Secrets Config
variable "client_backend_env_secret" {
  description = "Path of the secret denied"
}

variable "client_backend_env_secret_version" {
  description = "Version of the secret"
}

variable "client_frontend_env_secret" {
  description = "Path of the secret denied"
}

variable "client_frontend_env_secret_version" {
  description = "Version of the secret"
}

variable "backend_env_params" {
  description = "Env Variables"
  type = object({
    SALT                          = number
    JWT_SECRET                    = string
    ACCESS_TOKEN_RSA_PRIVATE_KEY  = string
    ACCESS_TOKEN_RSA_PUBLIC_KEY   = string
    REFRESH_TOKEN_RSA_PRIVATE_KEY = string
    REFRESH_TOKEN_RSA_PUBLIC_KEY  = string
  })
}

variable "frontend_env_params" {
  description = "Env Variables"
  type = object({
    VITE_BACKEND_URLBASE           = string
    VITE_BACKEND_UPLOAD_URL        = string
    VITE_BACKEND_APPLICATION_NAME  = string
    VITE_BACKEND_APPLICATION_TOKEN = string
  })
}

# Client Config
variable "client_name" {
  description = "Client Name without spaces"
}

variable "client_namespace" {
  description = "Client Namespace"
}

# MySQL Config
variable "mysql_server_instance_name" {
  description = "Instance Name from the MySQL Server on GCP"
}

variable "db_password" {
  description = "Database Password"
}
