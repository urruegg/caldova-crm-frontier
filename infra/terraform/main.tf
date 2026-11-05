import {
  for_each = var.manage_environments ? var.environments : {}
  to       = module.powerplatform.powerplatform_environment.this[each.key]
  id       = each.value.id
}

module "powerplatform" {
  source = "./modules/powerplatform"

  environments           = var.environments
  tenant_settings        = var.tenant_settings
  manage_tenant_settings = var.manage_tenant_settings
  manage_environments    = var.manage_environments
}

data "github_repository" "self" {
  full_name = "${var.github_owner}/${var.github_repository}"
}

data "github_user" "owner" {
  username = var.github_owner
}

module "entra" {
  source = "./modules/entra"

  github_owner         = var.github_owner
  github_owner_id      = tostring(data.github_user.owner.id)
  github_repository    = var.github_repository
  github_repository_id = tostring(data.github_repository.self.repo_id)

  app_registrations = {
    dev = {
      display_name       = "caldova-crm-frontier-ci-dev"
      github_environment = "dev"
      description        = "Caldova CRM Frontier CI (dev). OIDC federation only."
    }
    test = {
      display_name       = "caldova-crm-frontier-ci-test"
      github_environment = "test"
      description        = "Caldova CRM Frontier CI (test). OIDC federation only."
    }
    prod = {
      display_name       = "caldova-crm-frontier-ci-prod"
      github_environment = "prod"
      description        = "Caldova CRM Frontier CI (prod). OIDC federation only."
    }
  }
}

module "github" {
  source = "./modules/github"

  repository = var.github_repository

  environments = {
    dev = {
      ci_client_id            = var.ci_client_ids["dev"]
      ci_tenant_id            = var.tenant_id
      powerplatform_env_id    = module.powerplatform.environment_ids["dev"]
      powerplatform_env_url   = module.powerplatform.environment_urls["dev"]
      powerplatform_org_id    = var.organization_ids["dev"]
      allowed_branch_patterns = ["main"]
    }
    test = {
      ci_client_id            = var.ci_client_ids["test"]
      ci_tenant_id            = var.tenant_id
      powerplatform_env_id    = module.powerplatform.environment_ids["test"]
      powerplatform_env_url   = module.powerplatform.environment_urls["test"]
      powerplatform_org_id    = var.organization_ids["test"]
      allowed_branch_patterns = ["main"]
      reviewer_user_ids       = [data.github_user.owner.id]
      prevent_self_review     = false
    }
    prod = {
      ci_client_id            = var.ci_client_ids["prod"]
      ci_tenant_id            = var.tenant_id
      powerplatform_env_id    = module.powerplatform.environment_ids["prod"]
      powerplatform_env_url   = module.powerplatform.environment_urls["prod"]
      powerplatform_org_id    = var.organization_ids["prod"]
      allowed_branch_patterns = ["main"]
      reviewer_user_ids       = [data.github_user.owner.id]
      prevent_self_review     = true
    }
  }
}
