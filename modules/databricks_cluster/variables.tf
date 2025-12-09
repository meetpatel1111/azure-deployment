variable "cluster_name" {
  type = string
}

variable "spark_version" {
  type    = string
  default = "13.3.x-scala2.12"
}

variable "node_type_id" {
  type    = string
  default = "Standard_D4_v3"
}

variable "num_workers" {
  type    = number
  default = 1
}

variable "auto_termination_minutes" {
  type    = number
  default = 30
}
