resource "random_password" "db_password" {
  length  = 32
  special = false
}

locals {
  db_password        = random_password.db_password.result
  db_username        = "postgres"
  db_name            = lower(var.app_name)
  db_port            = 5432
  db_mount_path      = "/app/db_volume"
  db_volume_name     = "db-volume"
  db_storage_subpath = "db"

  app_container_name = "${lower(var.env)}-${lower(var.app_name)}-app-ca"
  db_container_name  = "${lower(var.env)}-${lower(var.app_name)}-db-ca"

  db_connection_string = "postgresql+asyncpg://${local.db_username}:${local.db_password}@${local.db_container_name}:${local.db_port}/${local.db_name}"

  dns_verification_id  = jsondecode(data.azapi_resource.app_verification_id.output).properties.customDomainConfiguration.customDomainVerificationId
  db_fqdn              = jsondecode(azapi_resource.db.output).properties.configuration.ingress.fqdn
  env_subdomain_suffix = var.env == "prd" ? "" : "-${var.env}"

  admin_dashoard_url = "https://${var.admin_dashboard_subdomain}.${var.dns_zone}"
}
