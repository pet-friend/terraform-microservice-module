output "container-app-default-url" {
  description = "Default URL for the main Container App"
  value       = azurerm_container_app.app.ingress[0].fqdn
}

output "container-app-url" {
  description = "Custom URL for the main Container App"
  value       = "${azurerm_dns_cname_record.cname_record_app.name}.${data.azurerm_dns_zone.dns.name}"
}

output "container-app-name" {
  description = "Name of the main Container App"
  value       = azurerm_container_app.app.name
}

output "db-connection-details" {
  description = "Database connection details"
  sensitive   = true
  value = {
    default-url = azurerm_dns_cname_record.cname_record_db.record
    url         = "${azurerm_dns_cname_record.cname_record_db.name}.${data.azurerm_dns_zone.dns.name}"
    port        = local.db_port
    username    = local.db_username
    password    = local.db_password
    database    = local.db_name
  }
}
