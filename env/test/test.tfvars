env                  = "np"
region_short         = "uks"
tier                 = "test"
location             = "UK South"
admin_username       = "azureuser"
admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWwNO1qQ7zyiAtAFJ+6+/XOzHCAilYJ7WE5C13I1EKb azure_vm"
vm_size              = "Standard_B1s"
tags = {
  environment = "dev",
  owner       = "team-devops"
}
iam_principal_id         = "5f51ed99-836d-4154-90c4-b78e56186431"
iam_role_definition_name = "Contributor"

adf_enabled                = true
databricks_enabled         = false
databricks_cluster_enabled = false
databricks_cluster_size    = 1