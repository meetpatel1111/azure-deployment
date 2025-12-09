output "vm_name" {
  value = module.vm.vm_name
}

output "vm_public_ip" {
  value = module.pip.public_ip_address
}

output "storage_account_name" {
  value = module.storage_account.storage_account_name
}

output "storage_account_primary_blob_endpoint" {
  value = module.storage_account.primary_blob_endpoint
}

output "databricks_workspace_id" {
  value = var.databricks_enabled ? module.databricks_workspace[0].workspace_id : null
}

output "databricks_workspace_url" {
  value = var.databricks_enabled ? module.databricks_workspace[0].workspace_url : null
}

output "data_factory_id" {
  value = var.adf_enabled ? module.data_factory[0].data_factory_id : null
}

output "databricks_cluster_id" {
  value = var.databricks_cluster_enabled ? module.databricks_cluster[0].cluster_id : null
}

output "databricks_cluster_name" {
  value = var.databricks_cluster_enabled ? module.databricks_cluster[0].cluster_name : null
}
