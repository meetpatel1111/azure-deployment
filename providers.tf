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

# Databricks workspace provider using client secret
# NOTE: this is evaluated using existing workspace in state on re-apply
provider "databricks" {
  auth_type           = "azure-client-secret"
  azure_client_id     = var.azure_client_id
  azure_client_secret = var.azure_client_secret
  azure_tenant_id     = var.azure_tenant_id
}

provider "databricks" {
  alias               = "workspace"
  auth_type           = "azure-client-secret"
  azure_client_id     = var.azure_client_id
  azure_client_secret = var.azure_client_secret
  azure_tenant_id     = var.azure_tenant_id

  azure_workspace_resource_id = (
    length(module.databricks_workspace) > 0 ?
    module.databricks_workspace[0].workspace_id :
    data.azurerm_databricks_workspace.existing[0].id
  )

  host = (
    length(module.databricks_workspace) > 0 ?
    module.databricks_workspace[0].workspace_url :
    data.azurerm_databricks_workspace.existing[0].workspace_url
  )
}
