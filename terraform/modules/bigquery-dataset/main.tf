# Import schema file and replace within tables object, generate list of table IDs
locals {
  tables    = [for table in var.tables : merge(table, { "schema" = file(table["schema"]) })]
  table_ids = [for table in var.tables : table["table_id"]]
}

# Create BigQuery dataset
module "bigquery" {
  source                     = "terraform-google-modules/bigquery/google"
  version                    = "5.4.0"
  project_id                 = var.project_id
  dataset_id                 = var.dataset_id
  dataset_name               = var.dataset_name
  delete_contents_on_destroy = false
  deletion_protection        = var.protect_from_delete
  location                   = "us"
  # Refer https://github.com/terraform-google-modules/terraform-google-bigquery to create new table(s)
  tables = local.tables
  views  = var.views
  # DS-REQ-03
  dataset_labels = var.labels
  access         = var.access
}