locals {

  # if terraform.workspace is not default then the environment is terraform cloud else it's terraform open-source (local)
  terraform_runtime = terraform.workspace != "default" ? "terraform-cld" : "terraform-os"

  # if we have optional labels then get them else set it to null
  optional_labels = var.optional != null ? var.optional : null

  # set the required labels based on user input and calculated values
  required_labels = {
    app_code        = var.app_code
    app_environment = var.app_environment
    classification  = var.classification
    cost_id         = var.cost_id
    creation_source = local.terraform_runtime
    department_id   = var.department_id
    project_id      = var.project_id
    tco_id          = var.tco_id
  }

  # merge required labels with the optional labels  
  metadata = try(
    merge(local.optional_labels, local.required_labels),
    local.required_labels
  )
}

# Use the Assert module to validate that the app code is found in mnemonics.json. This is required because variable validation does not permit ref-
# ernce to values other than the variable. As a result, ${path.module} causes the validation to be invalid. Naive reference by relative path also
# fails when the module is called by another root module. Another alternative would include the full list of mnemonics in the validation. At 1000
# entries, this hinders readability. Eventually this may be replaced by native raise functionality: https://github.com/hashicorp/terraform/pull/25088
data "assert_test" "app_code" {
  test  = contains(jsondecode(file("${path.module}/mnemonics.json")), upper(var.app_code))
  throw = "Invalid app_code specified. ${var.app_code} not found."
}
