locals {
  suffix      = "${var.env}-${var.region_short}-${var.tier}"
  rg_name     = "rg-${local.suffix}"
  vnet_name   = "vnet-${local.suffix}"
  subnet_name = "subnet-${local.suffix}"
  nsg_name    = "nsg-${local.suffix}"
  pip_name    = "pip-${local.suffix}"
  nic_name    = "nic-${local.suffix}"
  vm_name     = "vm-${local.suffix}"
  vnet_cidr   = "10.60.0.0/16"
  subnet_cidr = "10.60.1.0/24"
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source              = "./modules/vnet"
  name                = local.vnet_name
  cidr                = local.vnet_cidr
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

module "subnet" {
  source              = "./modules/subnet"
  name                = local.subnet_name
  cidr                = local.subnet_cidr
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = module.vnet.vnet_name
}

module "nsg" {
  source              = "./modules/nsg"
  name                = local.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

module "pip" {
  source              = "./modules/public_ip"
  name                = local.pip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

module "nic" {
  source              = "./modules/nic"
  name                = local.nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.subnet.subnet_id
  public_ip_id        = module.pip.public_ip_id
  tags                = var.tags
}

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
