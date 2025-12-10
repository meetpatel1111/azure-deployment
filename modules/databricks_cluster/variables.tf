variable "cluster_name" {
  type = string
}

variable "spark_version" {
  type    = string
  default = "13.3.x-scala2.12"
}

variable "node_type_id" {
  type    = string
  default = "Standard_F4"
}

variable "num_workers" {
  type    = number
  default = 1
}

variable "auto_termination_minutes" {
  type    = number
  default = 30
}

variable "policy_id" {
  type        = string
  description = "Cluster policy ID to enforce on this cluster"
}