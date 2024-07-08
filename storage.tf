resource "azurerm_storage_account" "storage_account" {
  name                     = "${lower(var.env)}petfriend${replace(lower(var.app_name), "-", "")}sa"
  resource_group_name      = data.azurerm_container_app_environment.app_env.resource_group_name
  location                 = data.azurerm_container_app_environment.app_env.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_share" "file_share" {
  name                 = "${lower(var.env)}-${lower(var.app_name)}-fs"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 3
}

resource "azurerm_container_app_environment_storage" "container_storage" {
  name                         = "${lower(var.env)}-${lower(var.app_name)}-db-storage"
  container_app_environment_id = data.azurerm_container_app_environment.app_env.id
  account_name                 = azurerm_storage_account.storage_account.name
  share_name                   = azurerm_storage_share.file_share.name
  access_key                   = azurerm_storage_account.storage_account.primary_access_key
  access_mode                  = "ReadWrite"
}
