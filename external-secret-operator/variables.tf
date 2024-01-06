
variable "vault_address" {
  description = "Vault Url Address"
}

variable "client_name" {
  description = "Client Name"
}

variable "client_namespace" {
  description = "Client Namespace"
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