variable "client_namespace" {
  type = string
}

variable "frontend_image_config" {
  type = object({
    image = string
    port  = number

    env_secret_name = string

    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
}

variable "backend_image_config" {
  type = object({
    image = string
    port  = number

    env_secret_name = string

    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
}

