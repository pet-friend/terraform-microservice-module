terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.81.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.10.0"
    }
  }
}

data "azurerm_container_app_environment" "app_env" {
  name                = var.cae_name
  resource_group_name = var.cae_resource_group
}

data "azurerm_resource_group" "rg" {
  name = data.azurerm_container_app_environment.app_env.resource_group_name
}

resource "azurerm_container_app" "app" {
  name                         = local.app_container_name
  container_app_environment_id = data.azurerm_container_app_environment.app_env.id
  resource_group_name          = data.azurerm_container_app_environment.app_env.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = local.app_container_name
      image  = var.container_image
      cpu    = var.resources_app.cpu
      memory = var.resources_app.memory

      env {
        name  = "DATABASE_URL"
        value = local.db_connection_string
      }

      env {
        name  = "ENVIRONMENT"
        value = var.env == "prd" ? "PRODUCTION" : "DEVELOPMENT"
      }
    }

    min_replicas = 0
    max_replicas = 1
  }

  ingress {
    transport                  = "http"
    target_port                = var.container_port
    external_enabled           = true
    allow_insecure_connections = false
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  lifecycle {
    ignore_changes = [
      # Required to keep the custom domain created in dns.tf (binded in CICD pipeline)
      ingress.0.custom_domain,
    ]
  }
}


# Can't use azurerm_container_app because I can't set the mountOptions nor the subPath
resource "azapi_resource" "db" {
  type      = "Microsoft.App/containerApps@2023-05-01"
  name      = local.db_container_name
  location  = data.azurerm_resource_group.rg.location
  parent_id = data.azurerm_resource_group.rg.id

  body = jsonencode({
    properties = {
      environmentId = data.azurerm_container_app_environment.app_env.id
      configuration = {
        activeRevisionsMode = "Single"
        ingress = {
          # See https://github.com/microsoft/azure-container-apps/issues/375
          transport  = "tcp"
          targetPort = local.db_port # where the app is listening
          external   = var.db_allow_external
          traffic = [
            {
              weight         = 100
              latestRevision = true
            }
          ]
        }
      }
      template = {

        containers = [
          {
            name      = local.db_container_name
            image     = "postgres:latest"
            args      = ["-p ${local.db_port}"]
            resources = var.resources_db
            env = [
              {
                name  = "POSTGRES_PASSWORD"
                value = local.db_password
              },
              {
                name  = "POSTGRES_USER"
                value = local.db_username
              },
              {
                name  = "POSTGRES_DB"
                value = local.db_name
              },
              {
                name  = "PGDATA"
                value = "${local.db_mount_path}/data"
              }
            ]
            volumeMounts = [
              {
                volumeName = local.db_volume_name
                mountPath  = local.db_mount_path
                subPath    = "data"
              }
            ]
          }
        ]

        scale = {
          minReplicas = 0
          maxReplicas = 1
        }

        volumes = [
          {
            # Required mount options for PostgreSQL to work
            mountOptions = "dir_mode=0750,file_mode=0750,uid=999,gid=999,mfsymlinks,nobrl"
            name         = local.db_volume_name
            storageName  = azurerm_container_app_environment_storage.container_storage.name
            storageType  = "AzureFile"
          }
        ]
      }
    }
  })

  response_export_values  = ["properties.configuration.ingress.fqdn"]
  ignore_missing_property = true
  ignore_casing           = true
}

