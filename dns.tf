data "azurerm_dns_zone" "dns" {
  name                = var.dns_zone
  resource_group_name = var.dns_resource_group
}

data "azapi_resource" "app_verification_id" {
  resource_id = data.azurerm_container_app_environment.app_env.id
  type        = "Microsoft.App/managedEnvironments@2023-05-01"

  response_export_values = ["properties.customDomainConfiguration.customDomainVerificationId"]
}

# App DNS records

resource "azurerm_dns_cname_record" "cname_record_app" {
  name                = "${var.subdomain}${local.env_subdomain_suffix}"
  zone_name           = data.azurerm_dns_zone.dns.name
  resource_group_name = data.azurerm_dns_zone.dns.resource_group_name
  ttl                 = 3600
  record              = azurerm_container_app.app.ingress[0].fqdn
}

resource "azurerm_dns_txt_record" "txt_record_app" {
  name                = "asuid.${azurerm_dns_cname_record.cname_record_app.name}"
  zone_name           = data.azurerm_dns_zone.dns.name
  resource_group_name = data.azurerm_dns_zone.dns.resource_group_name
  ttl                 = 3600
  record {
    value = local.dns_verification_id
  }
}

# Database DNS records

resource "azurerm_dns_cname_record" "cname_record_db" {
  name                = "${var.subdomain}-db${local.env_subdomain_suffix}"
  zone_name           = data.azurerm_dns_zone.dns.name
  resource_group_name = data.azurerm_dns_zone.dns.resource_group_name
  ttl                 = 3600
  record              = jsondecode(azapi_resource.db.output).properties.configuration.ingress.fqdn
}

resource "azurerm_dns_txt_record" "txt_record_db" {
  name                = "asuid.${azurerm_dns_cname_record.cname_record_db.name}"
  zone_name           = data.azurerm_dns_zone.dns.name
  resource_group_name = data.azurerm_dns_zone.dns.resource_group_name
  ttl                 = 3600
  record {
    value = local.dns_verification_id
  }
}
