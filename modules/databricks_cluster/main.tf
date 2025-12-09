resource "databricks_cluster" "this" {
  cluster_name            = var.cluster_name
  spark_version           = var.spark_version
  node_type_id            = var.node_type_id
  autotermination_minutes = var.auto_termination_minutes

  num_workers = var.num_workers

  tags = var.tags

  lifecycle {
    ignore_changes = [
      autoscale, # if manual scaling happens
      cluster_id
    ]
  }
}
