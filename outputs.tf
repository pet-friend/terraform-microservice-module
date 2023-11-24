output "container_app_default_url" {
  description = "Default URL for the main Container App"
  value       = azurerm_container_app.app.ingress[0].fqdn
}

output "container_app_url" {
  description = "Custom URL for the main Container App"
  value       = "${azurerm_dns_cname_record.cname_record_app.name}.${data.azurerm_dns_zone.dns.name}"
}

output "container_app_name" {
  description = "Name of the main Container App"
  value       = azurerm_container_app.app.name
}

output "db_connection_details" {
  description = "Database connection details"
  sensitive   = true
  value = {
    external_enabled = var.db_allow_external
    default_url      = azurerm_dns_cname_record.cname_record_db.record
    url              = "${azurerm_dns_cname_record.cname_record_db.name}.${data.azurerm_dns_zone.dns.name}"
    port             = local.db_port
    username         = local.db_username
    password         = local.db_password
    database         = local.db_name
  }
}
