- [GCP BigQuery](#gcp-bigquery)
  - [Overview](#overview)
    - [Data Protection Requirements](#data-protection-requirements)
    - [Permissions Required](#permissions-required)
    - [APIs Required](#apis-required)
  - [How to Use this Module](#how-to-use-this-module)
    - [Notes](#notes)
    - [Deploy a Dataset and Table](#deploy-a-dataset-and-table)
    - [Deploy a Dataset, Table, and View simultaneously](#deploy-a-dataset-table-and-view-simultaneously)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

# GCP BigQuery

## Overview

The BigQuery module deploys a Dataset containing one or more Tables, Views, or Routines. This module allows you to create opinionated Google Cloud Platform BigQuery datasets and tables. This will allow the user to programmatically create an empty table schema inside of a dataset, ready for loading. Note that a BigQuery View depends upon a Table. See the Examples below.

Specifically, this module performs the following operations:
- Creates a BigQuery dataset
- Creates project-level IAM bindings for BigQuery roles
- Authoritatively sets table-level IAM

### Data Protection Requirements

### Permissions Required

The following are required by a user or service account when using this module:

|Name|Role|
|-|-|
|[Service Account Admin](https://cloud.google.com/iam/docs/understanding-roles#service-accounts-roles)|```roles/iam.serviceAccountAdmin```|
|[Big Query Admin](https://cloud.google.com/iam/docs/understanding-roles#bigquery-roles)|```roles/bigquery.admin```|
|[Project IAM Admin](https://cloud.google.com/iam/docs/understanding-roles#resource-manager-roles)|```roles/resourcemanager.projectIamAdmin```|

### APIs Required

|Name|Uri|
|-|-|
|Cloud Resource Manager API|cloudresourcemanager.googleapis.com|
|Identity and Access Management API|iam.googleapis.com|
|BigQuery API|bigquery.googleapis.com|

## How to Use this Module

### Notes

- When using Range Partitioning, the Field must be of type INT64.
- When defining a table, a schema file may be specified. For details on creating a properly-formatted schema file, see [the documentation](https://cloud.google.com/bigquery/docs/schemas#creating_a_json_schema_file).

### Deploy a Dataset and Table

```hcl
module "bigquery_table" {
  source            = "app.terraform.io/hca-healthcare/bigquery/gcp"
  project_id        = var.gcp_project_id
  labels            = var.labels
  user_group        = var.user_group
  admin_group       = var.admin_group
  ml_group          = var.ml_group
  dataset_id        = var.dataset_id
  tables            = var.tables
}
```

### Deploy a Dataset, Table, and View simultaneously

```hcl
module "bigquery_table" {
  source            = "app.terraform.io/hca-healthcare/bigquery/gcp"
  project_id        = var.gcp_project_id
  labels            = local.labels
  user_group        = local.bigquery_table.user_group
  admin_group       = local.bigquery_table.admin_group
  ml_group          = local.bigquery_table.ml_group
  dataset_id        = local.bigquery_table.dataset_id
  tables            = local.bigquery_table.tables
}

module "bigquery_view" {
  source            = "app.terraform.io/hca-healthcare/bigquery/gcp"
  project_id        = var.gcp_project_id
  labels            = var.labels
  dataset_id        = module.bigquery_table.bigquery_dataset.dataset_id}_view"
  views             = var.views
}
```

<br /> <!-- How to Use this Module -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.9.0, < 5.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 3.9.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.9.0, < 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bigquery"></a> [bigquery](#module\_bigquery) | terraform-google-modules/bigquery/google | n/a |
| <a name="module_projects_iam_bindings"></a> [projects\_iam\_bindings](#module\_projects\_iam\_bindings) | terraform-google-modules/iam/google//modules/projects_iam | n/a |

## Resources

| Name | Type |
|------|------|
| [google_bigquery_table_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table_iam_policy) | resource |
| [google_bigquery_default_service_account.bq_service_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/bigquery_default_service_account) | data source |
| [google_iam_policy.table_level_policies](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access"></a> [access](#input\_access) | An array of objects that define dataset access for one or more entities. | `any` | <pre>[<br>  {<br>    "role": "roles/bigquery.dataOwner",<br>    "special_group": "projectOwners"<br>  }<br>]</pre> | no |
| <a name="input_admin_group"></a> [admin\_group](#input\_admin\_group) | List of groups to assign roles/bigquery.admin roles | `list(string)` | `[]` | no |
| <a name="input_dataset_id"></a> [dataset\_id](#input\_dataset\_id) | ID of BigQuery Dataset | `string` | n/a | yes |
| <a name="input_dataset_name"></a> [dataset\_name](#input\_dataset\_name) | Name of BigQuery Dataset. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Map of GCP labels. A Data classification level must be attached to each resourcet using established resource labels. The business owner must choose the highest data classification level of that data that the bucket may eventually contain. | `map(string)` | n/a | yes |
| <a name="input_ml_group"></a> [ml\_group](#input\_ml\_group) | List of groups to assign roles/bigquery.dataEditor and roles/bigquery.jobUser role | `list(string)` | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_protect_from_delete"></a> [protect\_from\_delete](#input\_protect\_from\_delete) | Protects the dataset from deletion by Terraform apply or destroy operations. When true, a dataset requires two terraform executions to delete. On the first pass, the flag is altered. On the second, the dataset may be removed. | `bool` | `false` | no |
| <a name="input_routines"></a> [routines](#input\_routines) | A list of objects which include routine\_id, routine\_type, routine\_language, definition\_body, return\_type, routine\_description and arguments. | <pre>list(object({<br>    routine_id      = string,<br>    routine_type    = string,<br>    language        = string,<br>    definition_body = string,<br>    return_type     = string,<br>    description     = string,<br>    arguments = list(object({<br>      name          = string,<br>      data_type     = string,<br>      argument_kind = string,<br>      mode          = string,<br>    })),<br>  }))</pre> | `[]` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | A list of objects which include table\_id, schema, clustering, time\_partitioning, range\_partitioning, expiration\_time and labels. | <pre>list(object({<br>    table_id   = string,<br>    schema     = string,<br>    clustering = list(string),<br>    time_partitioning = object({<br>      expiration_ms            = string,<br>      field                    = string,<br>      type                     = string,<br>      require_partition_filter = bool,<br>    }),<br>    range_partitioning = object({<br>      field = string,<br>      range = object({<br>        start    = string,<br>        end      = string,<br>        interval = string,<br>      }),<br>    }),<br>    expiration_time = string,<br>    labels          = map(string),<br>  }))</pre> | `[]` | no |
| <a name="input_user_group"></a> [user\_group](#input\_user\_group) | List of group name to assign roles/bigquery.dataViewer and roles/bigquery.jobUserroles | `list(string)` | `[]` | no |
| <a name="input_views"></a> [views](#input\_views) | A list of objects which include table\_id, which is view id, and view query | <pre>list(object({<br>    view_id        = string,<br>    query          = string,<br>    use_legacy_sql = bool,<br>    labels         = map(string),<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bigquery_dataset"></a> [bigquery\_dataset](#output\_bigquery\_dataset) | n/a |
| <a name="output_bigquery_table_names"></a> [bigquery\_table\_names](#output\_bigquery\_table\_names) | n/a |
| <a name="output_bigquery_tables"></a> [bigquery\_tables](#output\_bigquery\_tables) | n/a |
| <a name="output_bigquery_view_names"></a> [bigquery\_view\_names](#output\_bigquery\_view\_names) | n/a |
| <a name="output_bigquery_views"></a> [bigquery\_views](#output\_bigquery\_views) | n/a |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | n/a |
