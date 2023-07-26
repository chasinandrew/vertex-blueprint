variable "app_code" {
  type        = string
  description = "HCA CMDB mnemonic for the application"

  validation {
    condition     = can(regex("[a-z]{3,4}", var.app_code))
    error_message = "Variable app_code must be a 3 or 4 character, lowercase alpha string."
  }
}

variable "classification" {
  type        = string
  description = "HCA data classification. Must be one of restricted, sensitive, internal-only, or public. More Info: https://connect.medcity.net/c/document_library/get_file?uuid=d1bcac51-ac4c-4a05-ad1e-110a31a4d447&groupId=64846569"

  validation {
    condition     = contains(["restricted", "sensitive", "internal-only", "public"], var.classification)
    error_message = "Variable classification must be one of restricted, sensitive, internal-only, or public."
  }
}

variable "app_environment" {
  type        = string
  description = "Environment (e.g. dev/qa/prod/uat/poc/test/stage/train); prevents cross-environment communications"

  validation {
    condition     = contains(["dev", "qa", "prod", "uat", "poc", "test","stage","train","dr","devdr"], var.app_environment)
    error_message = "App_environment must be one of: dev/qa/prod/uat/poc/test/stage/train."
  }
}

variable "cost_id" {
  type        = string
  description = "HCA Finance cost ID"

  validation {
    condition     = can(regex("[0-9]{5}", var.cost_id))
    error_message = "Variable cost_id must be a 5-digit number."
  }
}
variable "department_id" {
  type        = string
  description = "HCA department ID of the business unit"

  validation {
    condition     = can(regex("[0-9]{5}", var.department_id))
    error_message = "Variable department_id must be a 5-digit number."
  }
}
variable "project_id" {
  type        = string
  description = "HCA project ID"

  validation {
    condition     = can(regex("^it\\-(?:nc\\w+|p\\d+)$", var.project_id))
    error_message = "Variable project_id must be an alphanumeric string prefixed with it-nc or it-p."
  }
}

variable "tco_id" {
  type        = string
  description = "HCA Finance TCO ID"

  validation {
    condition     = can(regex("^(?i)[a-z_]*$", var.tco_id))
    error_message = "Variable tco_id must consist of alpha characters and underscores."
  }
}

variable "optional" {
  type        = map(any)
  description = "Optional user defined labels"
  default     = null
  # validation {
  #   condition     = (
  #     can(var.optional["*"] == null) ||
  #     can(regex("^[0-9a-z_]{1,63}$", var.optional["*"])))
  #   error_message = "Variable optional must be a key-value pair consisting of lowercase alphanumeric characters and underscores."
  # }
}
