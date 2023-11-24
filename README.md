# Terraform microservice module

This terraform module creates a Container App for Azure that runs a microservice,
and a second Container App for a database with PostgreSQL.

### Additional features

- The database uses a Storage Account to persist data.
- CNAME DNS records are created for the microservice and the database:

  - `<subdomain>` for the app
  - `<subdomain>-db` for the database (only if `db_allow_external` is true)

  Additionally, the environment will be appended unless it's `prd`.

- Environment variables are set for the microservice to connect to the database:

  - `DATABASE_URL`: Async connection string for the PostgreSQL database.
  - `ENVIRONMENT`: The environment name (`PRODUCTION` or `DEVELOPMENT`).

- GitHub Action to automatically deploy the microservice in the. This action also
  adds a Managed Certificate to the app. Location: `.github/workflows/deploy.yml`.
  This pipeline requires the following output variables to be defined in the terraform
  module of the repo that uses it:

  - `container_app_name`: Name of the container app.
  - `container_app_url`: URL of the container app.
  - `resource_group_name`: Name of the resource group that contains
    the container app and the container app environment.
  - `container_app_environment_name`: Name of the environment.
  - `client_id`: Client ID of the service principal used to deploy the app.
  - `tenant_id`: Tenant ID of the service principal used to deploy the app.
  - `subscription_id`: Subscription ID where the app is deployed.
