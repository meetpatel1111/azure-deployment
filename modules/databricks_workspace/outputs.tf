output "name" {
  value = azurerm_databricks_workspace.this.name
}

output "workspace_id" {
  value = azurerm_databricks_workspace.this.id
}

output "workspace_url" {
  value = azurerm_databricks_workspace.this.workspace_url
}

output "managed_identity_principal_id" {
  value = azurerm_databricks_workspace.this.identity.principal_id
}
