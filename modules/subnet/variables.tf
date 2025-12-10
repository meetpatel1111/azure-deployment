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

variable "private_endpoint_network_policies" {
  type    = string
  default = null
}

variable "private_link_service_network_policies_enabled" {
  type    = bool
  default = null
}
