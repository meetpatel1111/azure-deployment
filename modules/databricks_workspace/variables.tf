variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type = string
}

variable "managed_resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

# Existing flag (if not present, add)
variable "no_public_ip" {
  type        = bool
  default     = true
  description = "Whether to disable public IP for workspace"
}

# NEW: VNet injection inputs
variable "virtual_network_id" {
  type        = string
  description = "ID of VNet for Databricks VNet injection"
}

variable "public_subnet_name" {
  type        = string
  description = "Public subnet name for Databricks"
}

variable "private_subnet_name" {
  type        = string
  description = "Private subnet name for Databricks"
}
