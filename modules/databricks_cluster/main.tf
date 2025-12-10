terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.99.0"
    }
  }
}

resource "databricks_cluster" "this" {
  cluster_name            = var.cluster_name
  spark_version           = var.spark_version
  node_type_id            = var.node_type_id
  driver_node_type_id     = var.node_type_id
  num_workers             = var.num_workers
  policy_id               = var.policy_id
  autotermination_minutes = var.auto_termination_minutes

  azure_attributes {
    availability = "ON_DEMAND_AZURE"
  }
}
