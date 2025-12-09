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

# ------------------------------
# SINGLE CORRECT DATABRICKS PROVIDER
# ------------------------------
provider "databricks" {
  azure_workspace_resource_id = module.databricks_workspace[0].workspace_id
  azure_client_id             = module.uami.client_id
}
