variable "tenant_id" {
  type        = string
  description = "Entra ID tenant ID of the demo tenant. Real value lives in terraform.tfvars (git-ignored)."
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", var.tenant_id)) && var.tenant_id != "00000000-0000-0000-0000-000000000000"
    error_message = "Use the verified Caldova tenant ID from private configuration."
  }
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID for Azure resources (Key Vault, App Insights). Empty string if the demo tenant has no linked subscription yet."
  default     = ""
}

variable "github_owner" {
  type        = string
  description = "GitHub owner (user or organisation) for the repo."
}

variable "github_repository" {
  type        = string
  description = "GitHub repository name (without owner)."
}

variable "environments" {
  type = map(object({
    id                 = string
    display_name       = string
    domain             = string
    url                = string
    location           = string
    env_type           = string
    currency           = string
    language           = string
    required_languages = optional(set(string), ["1033", "1031", "1036", "1040"])
    cadence            = optional(string, "Moderate")
    security_group_id  = optional(string, "")
  }))
  description = <<-EOT
    Map of Power Platform environment slots. Keys are the slot names (e.g. "dev", "test").
    The id is the existing environment GUID in the tenant, imported declaratively.
    This foundation onboards existing environments only; it never creates duplicates.
  EOT

  validation {
    condition     = toset(keys(var.environments)) == toset(["dev", "test", "prod"])
    error_message = "Configure exactly dev, test and prod; import the existing environments before applying."
  }

  validation {
    condition = alltrue([
      for env in values(var.environments) :
      can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", env.id)) &&
      env.id != "00000000-0000-0000-0000-000000000000" &&
      can(regex("^https://[a-zA-Z0-9-]+\\.crm[0-9]*\\.dynamics\\.com/?$", env.url)) &&
      length(trimspace(env.domain)) > 0 && length(trimspace(env.location)) > 0 && length(trimspace(env.currency)) > 0
    ])
    error_message = "Existing environments require verified IDs, full regional URL, domain, region and currency. Do not apply the example."
  }

  validation {
    condition = alltrue([
      for env in values(var.environments) :
      contains(env.required_languages, env.language) &&
      alltrue([
        for lcid in env.required_languages :
        contains(["1033", "1031", "1036", "1040"], lcid)
      ])
    ])
    error_message = "Each environment must include its base language and may use only 1033, 1031, 1036 and 1040."
  }
}

variable "tenant_settings" {
  type = object({
    disable_share_with_everyone         = bool
    disable_connection_sharing_everyone = bool
    enable_canvas_app_insights          = bool
    disable_copilot                     = bool
    enable_openai_bot_publishing        = bool
    storage_capacity_warning_threshold  = number
    disable_new_env_creation_non_admins = bool
  })
  description = "Shared tenant settings. Used only when manage_tenant_settings is explicitly true."
  default     = null
}

variable "manage_tenant_settings" {
  type        = bool
  description = "Opt in only after joint CRM/HR tenant-policy ownership review. Never enable during CRM onboarding."
  default     = false
}

variable "manage_environments" {
  type        = bool
  description = "Existing environments are reference-only by default. Opt-in management requires a reviewed security group and import plan."
  default     = false
}

variable "ci_client_ids" {
  type        = map(string)
  description = "Verified existing CI application IDs. Explicit inputs keep incremental state adoption independent of partially imported Entra outputs."
  validation {
    condition = toset(keys(var.ci_client_ids)) == toset(["dev", "test", "prod"]) && length(toset(values(var.ci_client_ids))) == 3 && alltrue([
      for id in values(var.ci_client_ids) :
      can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", id)) && id != "00000000-0000-0000-0000-000000000000"
    ])
    error_message = "Provide three distinct verified existing CI application IDs."
  }
}

variable "organization_ids" {
  type        = map(string)
  description = "Verified Dataverse organisation IDs for dev, test and prod; kept in private tfvars."
  validation {
    condition = toset(keys(var.organization_ids)) == toset(["dev", "test", "prod"]) && alltrue([
      for id in values(var.organization_ids) :
      can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", id)) && id != "00000000-0000-0000-0000-000000000000"
    ])
    error_message = "Provide verified organisation GUIDs for dev, test and prod."
  }
}
