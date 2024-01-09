
variable "ingress_controller_ip" {
  description = "Ingress Controller IP"
  type        = string
}

variable "client_namespace" {
  type = string
}

variable "dns_zone_name" {
  description = "Nome da Cloud DNS zone"
  type        = string
}

variable "cert_manager_email" {
  type = string
}

variable "domain" {
  type = string
}
