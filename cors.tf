resource "azapi_update_resource" "set_cors" {
  type        = "Microsoft.App/containerApps@2023-11-02-preview"
  resource_id = azurerm_container_app.app.id

  body = jsonencode({
    properties = {
      configuration = {
        ingress = {
          corsPolicy = var.env == "prd" ? {
            allowedOrigins = [local.admin_dashoard_url]
            allowedMethods = ["*"]
            allowedHeaders = ["*"]
            } : {
            allowedOrigins = ["*"]
            allowedMethods = ["*"]
            allowedHeaders = ["*"]
          }
        }
      }
    }
  })
}
