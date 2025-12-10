variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

# List of allowed CIDRs for SSH
variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "Allowed source CIDRs for SSH inbound rules"
  default     = [] # You can override in tfvars
}