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
  type    = list(string)
  default = []
}

variable "allowed_rdp_cidrs" {
  type    = list(string)
  default = []
}
