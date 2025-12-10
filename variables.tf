variable "env" {
  type = string
}

variable "region_short" {
  type = string
}

variable "tier" {
  type = string
}

variable "location" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_ssh_public_key" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "iam_principal_id" {
  description = "Object ID of principal (user/group/service principal) to assign a role."
  type        = string
  default     = ""
}

variable "iam_role_definition_name" {
  description = "Built-in role name to assign to principal."
  type        = string
  default     = "Reader"
}

variable "databricks_enabled" {
  type    = bool
  default = false
}

variable "databricks_sku" {
  type    = string
  default = "premium"
}

variable "adf_enabled" {
  type    = bool
  default = false
}

variable "databricks_cluster_enabled" {
  type    = bool
  default = false
}

variable "databricks_cluster_size" {
  type    = number
  default = 1
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "Allowed source CIDRs for SSH inbound rules"
  default     = [] # You can override in tfvars
}