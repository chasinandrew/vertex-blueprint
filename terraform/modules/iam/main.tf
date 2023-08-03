
locals {

  authoritative = var.mode == "authoritative"
  additive      = var.mode == "additive"

  aliased_entities = length(var.entities) == 1 ? ["default"] : var.entities

  bindings_by_role = distinct(flatten([
    for name in var.entities
    : [
      for role, members in var.bindings
      : { name = name, role = role, members = members, condition = { title = "", description = "", expression = "" } }
    ]
  ]))

  bindings_by_principal = distinct(flatten([
    for name in var.entities
    : [
      for member, roles in var.bindings_by_principal
      : [
        for role in roles
        : { name = name, role = role, members = [member], condition = { title = "", description = "", expression = "" } }
      ]
    ]
  ]))

  bindings_by_member = distinct(flatten([
    for binding in local.all_bindings
    : [
      for member in binding["members"]
      : { name = binding["name"], role = binding["role"], member = member, condition = binding["condition"] }
    ]
  ]))

  bindings_by_conditions = distinct(flatten([
    for name in var.entities
    : [
      for binding in var.conditional_bindings
      : { name = name, role = binding.role, members = binding.members, condition = { title = binding.title, description = binding.description, expression = binding.expression } }
    ]
  ]))

  all_bindings = concat(local.bindings_by_role, local.bindings_by_principal, local.bindings_by_conditions)

  keys_authoritative = distinct(flatten([
    for alias in local.aliased_entities
    : [
      for role in keys(var.bindings)
      : "${alias}--${role}"
    ]
  ]))

  keys_authoritative_conditional = distinct(flatten([
    for alias in local.aliased_entities
    : [
      for binding in var.conditional_bindings
      : "${alias}--${binding.role}--${binding.title}"
    ]
  ]))

  keys_additive = distinct(flatten([
    for alias in local.aliased_entities
    : [
      for role, members in var.bindings
      : [
        for member in members
        : "${alias}--${role}--${member}"
      ]
    ]
  ]))

  keys_additive_bindings_by_principal = distinct(flatten([
    for alias in local.aliased_entities
    : [
      for member, roles in var.bindings_by_principal
      : [
        for role in roles
        : "${alias}--${role}--${member}"
      ]
    ]
  ]))

  keys_additive_conditional = distinct(flatten([
    for alias in local.aliased_entities
    : [
      for binding in var.conditional_bindings
      : [
        for member in binding.members
        : "${alias}--${binding.role}--${binding.title}--${member}"
      ]
    ]
  ]))

  all_keys_authoritative = concat(local.keys_authoritative, local.keys_authoritative_conditional)

  all_keys_additive = concat(local.keys_additive, local.keys_additive_bindings_by_principal, local.keys_additive_conditional)

  set_authoritative = (
    local.authoritative
    ? toset(local.all_keys_authoritative)
    : []
  )

  set_additive = (
    local.additive
    ? toset(local.all_keys_additive)
    : []
  )

  bindings_authoritative = (
    local.authoritative
    ? zipmap(local.all_keys_authoritative, local.all_bindings)
    : {}
  )

  bindings_additive = (
    local.additive
    ? zipmap(local.all_keys_additive, local.bindings_by_member)
    : {}
  )
}
resource "google_project_iam_binding" "authoritative" {
  for_each = alltrue([var.entity_type == "project", var.mode == "authoritative"]) ? local.set_authoritative : []
  project  = local.bindings_authoritative[each.key].name
  role     = local.bindings_authoritative[each.key].role
  members  = local.bindings_authoritative[each.key].members
  dynamic "condition" {
    for_each = local.bindings_authoritative[each.key].condition.title == "" ? [] : [local.bindings_authoritative[each.key].condition]
    content {
      title       = local.bindings_authoritative[each.key].condition.title
      description = local.bindings_authoritative[each.key].condition.description
      expression  = local.bindings_authoritative[each.key].condition.expression
    }
  }
}

resource "google_project_iam_member" "additive" {
  for_each = alltrue([var.entity_type == "project", var.mode == "additive"]) ? local.set_additive : []
  project  = local.bindings_additive[each.key].name
  role     = local.bindings_additive[each.key].role
  member   = local.bindings_additive[each.key].member
  dynamic "condition" {
    for_each = local.bindings_additive[each.key].condition.title == "" ? [] : [local.bindings_additive[each.key].condition]
    content {
      title       = local.bindings_additive[each.key].condition.title
      description = local.bindings_additive[each.key].condition.description
      expression  = local.bindings_additive[each.key].condition.expression
    }
  }
}