variable "env" { type = string }
variable "region_short" { type = string }
variable "tier" { type = string }
variable "location" { type = string }
variable "admin_username" { type = string }
variable "admin_ssh_public_key" { type = string }
variable "vm_size" { type = string }
variable "tags" { type = map(string) }
