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

