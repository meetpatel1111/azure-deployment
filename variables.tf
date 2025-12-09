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
