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
  # These come from GitHub Actions via TF_VAR_*
  auth_type           = "azure-client-secret"
  azure_client_id     = var.azure_client_id
  azure_client_secret = var.azure_client_secret
  azure_tenant_id     = var.azure_tenant_id

  # After first apply, these values are in state & can be used
  azure_workspace_resource_id = module.databricks_workspace[0].workspace_id
  host                        = module.databricks_workspace[0].workspace_url
}
