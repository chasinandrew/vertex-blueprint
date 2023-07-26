output "project_id" {
  value = var.project_id
}

output "bigquery_dataset" {
  value = module.bigquery.bigquery_dataset
}

output "bigquery_tables" {
  value = module.bigquery.bigquery_tables
}

output "bigquery_views" {
  value = module.bigquery.bigquery_views
}

output "bigquery_table_names" {
  value = module.bigquery.table_names
}

output "bigquery_view_names" {
  value = module.bigquery.view_names
}