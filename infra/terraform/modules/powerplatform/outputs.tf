output "environment_ids" {
  description = "GUIDs of each Power Platform environment, keyed by slot."
  value       = { for slot, env in var.environments : slot => var.manage_environments ? powerplatform_environment.this[slot].id : env.id }
}

output "environment_urls" {
  description = "Instance URLs of each Power Platform environment, keyed by slot."
  value       = { for slot, env in var.environments : slot => trimsuffix(env.url, "/") }
}

output "environment_display_names" {
  description = "Display names of each Power Platform environment, keyed by slot."
  value       = { for slot, env in var.environments : slot => var.manage_environments ? powerplatform_environment.this[slot].display_name : env.display_name }
}

output "required_languages" {
  description = "Required Dataverse LCIDs keyed by environment slot."
  value       = { for slot, env in var.environments : slot => sort(tolist(env.required_languages)) }
}
