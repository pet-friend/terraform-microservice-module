# Terraform microservice module

This terraform module creates a Container App for Azure that runs a microservice,
and a second Container App for a database with PostgreSQL.

### Additional features

- The database uses a Storage Account to persist data.
- CNAME DNS records are created for the microservice and the database:

  - `<subdomain>` for the app
  - `<subdomain>-db` for the database

  Additionally, the environment will be appended unless it's `prd`.

- Environment variables are set for the microservice to connect to the database:

  - `DATABASE_URL`: Async connection string for the PostgreSQL database.
  - `ENVIRONMENT`: The environment name (`PRODUCTION` or `DEVELOPMENT`).

- GitHub Action to automatically deploy the microservice in the. This action also
  adds a Managed Certificate to the app. Location: `.github/workflows/deploy.yml`
