variable "name" {
  description = "Storage account name (must be globally unique, 3-24 chars, lowercase)."
  type        = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "account_tier" {
  description = "Storage account tier, e.g. Standard or Premium."
  type        = string
}

variable "account_replication_type" {
  description = "Replication type, e.g. LRS, GRS."
  type        = string
}

variable "tags" {
  type = map(string)
}
