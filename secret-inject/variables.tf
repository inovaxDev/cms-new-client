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

variable "vault_address" {
  description = "Vault Url Address"
}

variable "vault_terraform_token" {
  description = "Vault Token for Terraform"
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

# Bucket Config
variable "bucket_config" {
  description = "Configuration of Bucket"
  type = object({
    name        = string
    secret_key  = string
    private_key = string
  })
}

# MySQL Config
variable "mysql_config" {
  description = "Configuration of MySQL"
  type = object({
    database_url = string
  })
}
