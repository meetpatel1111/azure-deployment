resource "azurerm_subnet" "this" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.cidr]

  private_endpoint_network_policies             = var.private_endpoint_network_policies
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = var.delegation == null ? [] : [var.delegation]

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}
