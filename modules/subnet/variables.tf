variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

# NEW: private endpoint / private link flags
variable "private_endpoint_network_policies" {
  type        = string
  default     = "Enabled"
  description = "Whether private endpoint network policies are enabled ('Enabled' or 'Disabled')"
}

variable "private_link_service_network_policies_enabled" {
  type        = bool
  default     = true
  description = "Whether private link service network policies are enabled"
}

# NEW: optional delegation (used for Databricks subnets)
variable "delegation" {
  type = object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  })
  default = null
}
