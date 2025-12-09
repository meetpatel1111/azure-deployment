variable "scope" {
  description = "Scope for the role assignment (e.g. resource group or resource ID)."
  type        = string
}

variable "role_definition_name" {
  description = "Built-in role definition name (e.g. Reader, Contributor)."
  type        = string
}

variable "principal_id" {
  description = "Object ID of the principal (user, group, or service principal)."
  type        = string
}
