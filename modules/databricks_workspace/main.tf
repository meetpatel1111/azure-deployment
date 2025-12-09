resource "azurerm_databricks_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  managed_resource_group_name = "${var.name}-mrg"

  custom_parameters {
    no_public_ip = true
  }
}
