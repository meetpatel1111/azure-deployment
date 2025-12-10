terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_databricks_workspace" "this" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  sku                         = var.sku
  managed_resource_group_name = var.managed_resource_group_name
  tags                        = var.tags

  custom_parameters {
    no_public_ip = var.no_public_ip

    # VNet injection
    virtual_network_id  = var.virtual_network_id
    public_subnet_name  = var.public_subnet_name
    private_subnet_name = var.private_subnet_name
  }
}