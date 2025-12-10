terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.99.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

# Single Databricks provider for workspace operations
provider "databricks" {
  alias               = "workspace"
  auth_type           = "azure-client-secret"
  azure_client_id     = var.azure_client_id
  azure_client_secret = var.azure_client_secret
  azure_tenant_id     = var.azure_tenant_id

  # Simplified - only reference the module output
  azure_workspace_resource_id = (
    var.databricks_enabled && length(module.databricks_workspace) > 0 ?
    module.databricks_workspace[0].workspace_id : null
  )

  host = (
    var.databricks_enabled && length(module.databricks_workspace) > 0 ?
    "https://${module.databricks_workspace[0].workspace_url}" : null
  )
}