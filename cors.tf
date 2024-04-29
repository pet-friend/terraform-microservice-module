resource "azapi_update_resource" "set_cors" {
  type        = "Microsoft.App/containerApps@2023-05-01"
  resource_id = azurerm_container_app.app.id

  body = jsonencode({
    properties = {
      configuration = {
        ingress = {
          corsPolicy = var.env == "prd" ? {
            allowOrigins   = [local.admin_dashoard_url]
            allowedMethods = ["*"]
            allowHeaders   = ["*"]
            } : {
            allowOrigins   = ["*"]
            allowedMethods = ["*"]
            allowHeaders   = ["*"]
          }
        }
      }
    }
  })
}
