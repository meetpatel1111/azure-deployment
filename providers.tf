terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.40.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  host = module.databricks_workspace[0].workspace_url
}
