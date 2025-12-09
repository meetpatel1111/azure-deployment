variable "env" {} variable "region_short" {} variable "tier" {} variable "location" {}
variable "admin_username" {} variable "admin_ssh_public_key" {} variable "vm_size" {}
variable "tags" { type=map(string) }