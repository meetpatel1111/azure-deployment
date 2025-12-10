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

variable "databricks_sku" {
  type    = string
  default = "premium"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "Allowed source CIDRs for SSH inbound rules"
  default     = [] # You can override in tfvars
}

variable "allowed_rdp_cidrs" {
  type        = list(string)
  description = "Allowed source CIDRs for RDP inbound rules"
  default     = [] # You can override in tfvars
}



variable "azure_client_id" {
  description = "Client ID of the SPN used for Databricks provider (same as ARM_CLIENT_ID)"
  type        = string
}

variable "azure_client_secret" {
  description = "Client secret of the SPN used for Databricks provider"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Tenant ID of the SPN used for Databricks provider"
  type        = string
}

variable "databricks_enabled" {
  type        = bool
  default     = true
  description = "Whether to deploy Databricks workspace"
}

variable "databricks_cluster_enabled" {
  type        = bool
  default     = true
  description = "Whether to deploy Databricks cluster"
}

variable "databricks_cluster_size" {
  type        = number
  default     = 1
  description = "Number of workers in Databricks cluster"
}

variable "adf_enabled" {
  type        = bool
  default     = true
  description = "Whether to deploy Azure Data Factory"
}

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