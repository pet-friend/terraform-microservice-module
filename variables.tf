# App settings

variable "app_name" {
  description = "Application name, used in the resource names"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy for the application"
  default     = "mcr.microsoft.com/k8se/quickstart:latest"
  type        = string
}

variable "container_port" {
  description = "Port of the HTTP server inside the container"
  default     = 80
  type        = number
}

variable "env" {
  description = "Environment, used in the resource names"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables to set in the container"
  default     = {}
  type        = map(string)
}

# Database settings

variable "db_allow_external" {
  type        = bool
  description = "Allow external connections to the database. Requires the CAE to use a VNET"
  default     = false
}

# DNS Settings

variable "dns_zone" {
  description = "DNS Zone name for the DNS records"
  type        = string
}

variable "dns_resource_group" {
  description = "Name of the resource group where the DNS zone is located"
  type        = string
}

variable "subdomain" {
  description = "The subdomain to use for the DNS records"
  type        = string
}


# Container App Environment settings

variable "cae_resource_group" {
  description = "Name of the resource group where the Container App Environment is"
  type        = string
}

variable "cae_name" {
  description = "Name of the Container App Environment"
  default     = "SERVICES-CAE"
  type        = string
}

# Resource settings

variable "resources_app" {
  description = "vCPU and Memory counts for the application"
  default = {
    cpu    = 0.25
    memory = "0.5Gi"
  }
  type = object({
    cpu    = number
    memory = string
  })
}

variable "resources_db" {
  description = "vCPU and Memory counts for the database"
  default = {
    cpu    = 0.25
    memory = "0.75Gi"
  }
  type = object({
    cpu    = number
    memory = string
  })
}
