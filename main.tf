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

  vnet_cidr               = "10.60.0.0/16"
  subnet_cidr             = "10.60.1.0/24"
  dbr_private_subnet_cidr = "10.60.10.0/24"
  dbr_public_subnet_cidr  = "10.60.11.0/24"
}

data "azurerm_client_config" "current" {}

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

module "dbr_private_subnet" {
  source              = "./modules/subnet"
  name                = "subnet-${local.suffix}-dbr-private"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = module.vnet.vnet_name
  cidr                = local.dbr_private_subnet_cidr

  # Required for Databricks VNet injection
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true

  delegation = {
    name = "databricks-private-delegation"

    service_delegation = {
      name = "Microsoft.Databricks/workspaces"

      # Official required actions
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }
}

module "dbr_public_subnet" {
  source              = "./modules/subnet"
  name                = "subnet-${local.suffix}-dbr-public"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = module.vnet.vnet_name
  cidr                = local.dbr_public_subnet_cidr

  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true

  delegation = {
    name = "databricks-public-delegation"

    service_delegation = {
      name = "Microsoft.Databricks/workspaces"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }
}

# ------------------------------
# NSG
# ------------------------------
# VM NSG
module "nsg" {
  source = "./modules/nsg"

  name                = local.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  allowed_rdp_cidrs = var.allowed_rdp_cidrs

  tags = var.tags
}

# Databricks PRIVATE subnet NSG
module "nsg_dbr_private" {
  source              = "./modules/nsg"
  name                = "nsg-${local.suffix}-dbr-private"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  # Databricks does NOT allow inbound traffic except internal Azure
  allowed_ssh_cidrs = []
  allowed_rdp_cidrs = []
  tags              = var.tags
}

# Databricks PUBLIC subnet NSG
module "nsg_dbr_public" {
  source              = "./modules/nsg"
  name                = "nsg-${local.suffix}-dbr-public"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  allowed_ssh_cidrs = []
  allowed_rdp_cidrs = []
  tags              = var.tags
}

# VM subnet
resource "azurerm_subnet_network_security_group_association" "vm_subnet" {
  subnet_id                 = module.subnet.subnet_id
  network_security_group_id = module.nsg.nsg_id
}

# Databricks private subnet
resource "azurerm_subnet_network_security_group_association" "dbr_private" {
  subnet_id                 = module.dbr_private_subnet.subnet_id
  network_security_group_id = module.nsg_dbr_private.nsg_id
}

# Databricks public subnet
resource "azurerm_subnet_network_security_group_association" "dbr_public" {
  subnet_id                 = module.dbr_public_subnet.subnet_id
  network_security_group_id = module.nsg_dbr_public.nsg_id
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
  count = var.databricks_enabled ? 1 : 0

  source                      = "./modules/databricks_workspace"
  name                        = local.databricks_name
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  sku                         = "premium"
  managed_resource_group_name = local.databricks_mrg
  tags                        = var.tags

  no_public_ip        = true
  virtual_network_id  = module.vnet.vnet_id
  public_subnet_name  = module.dbr_public_subnet.subnet_name
  private_subnet_name = module.dbr_private_subnet.subnet_name

  public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.dbr_public.id
  private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.dbr_private.id

  depends_on = [
    module.dbr_private_subnet,
    module.dbr_public_subnet,
    azurerm_subnet_network_security_group_association.dbr_private,
    azurerm_subnet_network_security_group_association.dbr_public,
  ]
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

  providers = {
    databricks = databricks.workspace
  }

  cluster_name  = "cluster-${local.suffix}"
  spark_version = "13.3.x-scala2.12"
  node_type_id  = "Standard_F4"
  num_workers   = var.databricks_cluster_size

  policy_id = databricks_cluster_policy.standard.id

  depends_on = [
    module.databricks_workspace
  ]
}

resource "azurerm_role_assignment" "uami_to_workspace" {
  scope                = module.databricks_workspace[0].workspace_id
  role_definition_name = "Contributor"
  principal_id         = module.uami.principal_id

  depends_on = [module.databricks_workspace]
  lifecycle {
    create_before_destroy = true
  }
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

module "key_vault" {
  source              = "./modules/key_vault"
  name                = "kv-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = var.tags
}

resource "azurerm_databricks_access_connector" "this" {
  name                = "ac-${local.suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "dbr_kv" {
  key_vault_id       = module.key_vault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_databricks_access_connector.this.identity[0].principal_id
  secret_permissions = ["Get", "List"]
}

resource "databricks_secret_scope" "kv_scope" {
  name     = "kv-scope"
  provider = databricks.workspace

  keyvault_metadata {
    resource_id = module.key_vault.id
    dns_name    = module.key_vault.vault_uri
  }
}

resource "databricks_cluster_policy" "standard" {
  name        = "standard-cluster-policy"
  description = "Restricts node types, enforces auto-termination, max workers."
  provider    = databricks.workspace

  definition = jsonencode({
    spark_version = {
      type   = "fixed"
      value  = "13.3.x-scala2.12"
      hidden = false
    }
    autotermination_minutes = {
      type    = "range"
      min     = 10
      max     = 120
      default = 30
    }
    num_workers = {
      type    = "range"
      min     = 1
      max     = 4
      default = 1
    }
    node_type_id = {
      type = "allowlist"
      values = [
        "Standard_D", # Balanced compute/memory
        "Standard_DS",
        "Standard_DSv3",
        "Standard_DSv4",
        "Standard_DSv5",

        "Standard_F", # Compute optimized
        "Standard_F4",
        "Standard_FSv2",

        "Standard_E", # Memory optimized
        "Standard_Esv3",
        "Standard_Esv4",
        "Standard_Esv5"
      ]
    }
  })
}
