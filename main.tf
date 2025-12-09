# ------------------------------
# LOCALS
# ------------------------------
locals {
  suffix           = "${var.env}-${var.region_short}-${var.tier}"
  rg_name          = "rg-${local.suffix}"
  vnet_name        = "vnet-${local.suffix}"
  subnet_name      = "subnet-${local.suffix}"
  nsg_name         = "nsg-${local.suffix}"
  pip_name         = "pip-${local.suffix}"
  nic_name         = "nic-${local.suffix}"
  vm_name          = "vm-${local.suffix}"
  databricks_name  = "dbr-${local.suffix}"
  databricks_mrg   = "dbr-mrg-${local.suffix}"
  datafactory_name = "adf-${local.suffix}-01"
  uami_name        = "id-${local.suffix}"

  # Storage account naming (no hyphens allowed)
  storage_account_name = "st${replace(local.suffix, "-", "")}"

  vnet_cidr   = "10.60.0.0/16"
  subnet_cidr = "10.60.1.0/24"
}

# ------------------------------
# RESOURCE GROUP (must be above all modules)
# ------------------------------
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

# ------------------------------
# STORAGE ACCOUNT
# ------------------------------
module "storage_account" {
  source                   = "./modules/storage_account"
  name                     = local.storage_account_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# ------------------------------
# IAM ROLE ASSIGNMENT
# ------------------------------
module "iam_rg" {
  source               = "./modules/iam"
  count                = var.iam_principal_id == "" ? 0 : 1
  scope                = azurerm_resource_group.rg.id
  role_definition_name = var.iam_role_definition_name
  principal_id         = var.iam_principal_id
}

# ------------------------------
# VNET
# ------------------------------
module "vnet" {
  source              = "./modules/vnet"
  name                = local.vnet_name
  cidr                = local.vnet_cidr
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# ------------------------------
# SUBNET
# ------------------------------
module "subnet" {
  source              = "./modules/subnet"
  name                = local.subnet_name
  cidr                = local.subnet_cidr
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = module.vnet.vnet_name
}

# ------------------------------
# NSG
# ------------------------------
module "nsg" {
  source              = "./modules/nsg"
  name                = local.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# ------------------------------
# PUBLIC IP
# ------------------------------
module "pip" {
  source              = "./modules/public_ip"
  name                = local.pip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# ------------------------------
# NIC
# ------------------------------
module "nic" {
  source              = "./modules/nic"
  name                = local.nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.subnet.subnet_id
  public_ip_id        = module.pip.public_ip_id
  tags                = var.tags
}

module "uami" {
  source              = "./modules/user_assigned_identity"
  name                = local.uami_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# ------------------------------
# VM
# ------------------------------
module "vm" {
  source               = "./modules/vm"
  name                 = local.vm_name
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  nic_id               = module.nic.nic_id
  admin_username       = var.admin_username
  admin_ssh_public_key = var.admin_ssh_public_key
  vm_size              = var.vm_size
  tags                 = var.tags
}

module "databricks_workspace" {
  count  = var.databricks_enabled ? 1 : 0
  source = "./modules/databricks_workspace"

  name                        = local.databricks_name
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  sku                         = var.databricks_sku
  managed_resource_group_name = local.databricks_mrg
  tags                        = var.tags
}

module "data_factory" {
  count  = var.adf_enabled ? 1 : 0
  source = "./modules/data_factory"

  name                = local.datafactory_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

module "databricks_cluster" {
  count = var.databricks_enabled && var.databricks_cluster_enabled ? 1 : 0

  source = "./modules/databricks_cluster"

  cluster_name  = "cluster-${local.suffix}"
  spark_version = "13.3.x-scala2.12"
  node_type_id  = "Standard_DS3_v2"
  num_workers   = var.databricks_cluster_size

  depends_on = [
    module.databricks_workspace
  ]
}

resource "azurerm_role_assignment" "uami_to_workspace" {
  scope                = module.databricks_workspace[0].workspace_id
  role_definition_name = "Contributor"
  principal_id         = module.uami.principal_id

  depends_on = [module.databricks_workspace]
}

resource "azurerm_role_assignment" "uami_to_storage" {
  scope                = module.storage_account.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.uami.principal_id
}

resource "azurerm_role_assignment" "uami_to_vnet" {
  scope                = module.vnet.vnet_id
  role_definition_name = "Contributor"
  principal_id         = module.uami.principal_id
}
