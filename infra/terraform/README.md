# Caldova Terraform foundation

Trace: US-007 / [ADR-0042](../../docs/adr/ADR-0042-caldova-platform-foundation.md).

## State and ownership boundary

The backend is local `.terraform-caldova/terraform.tfstate` under this directory.
Use a separate ignored `TF_DATA_DIR`; never migrate the previous tenant's backend
or reuse its state. Keep encrypted, restore-tested private state backups outside
Git. Remote state requires a separately reviewed Azure subscription/storage target.

All three Power Platform environments already exist and are **reference-only**
by default (`manage_environments = false`); verified IDs/URLs wire deployment
without changing environment metadata or access policy. Empty/placeholder IDs
are rejected. On explicit opt-in, root `import` blocks adopt the verified IDs
and `prevent_destroy = true` blocks environment replacement/deletion.
The plan must show **no environment creation, deletion, rename or replacement**.
Never remove destruction protection to make a plan pass.

Shared `powerplatform_tenant_settings` is not owned here by default:
`manage_tenant_settings = false`, `tenant_settings = null`. HR shares this tenant.
Never import shared policy or carry the previous tenant's policy into this state.

## Private inputs

Create `.terraform-caldova/caldova.tfvars.json` locally from the shape of
`terraform.tfvars.example`, including the exact existing display name, region,
type, currency, domain, LCIDs and security group. No guessed defaults are
deployment inputs. Supply every root input explicitly so an older ignored
`terraform.tfvars` cannot supply a value accidentally.

The current checkout's ignored JSON var-file was populated from live discovery.
Full regional URLs are explicit inputs; never reconstruct a `.crm` suffix.

```powershell
# Run from infra\terraform in a shell already signed into the intended tenant.
$env:TF_DATA_DIR = Join-Path $PWD '.terraform-caldova\providers'
$env:GH_TOKEN = (gh auth token)
$env:GITHUB_TOKEN = $env:GH_TOKEN
terraform init -reconfigure
terraform validate
terraform plan -var-file='.terraform-caldova/caldova.tfvars.json'
```

If initialization finds the previous tenant's local state and asks to copy it,
answer **no**. The new backend must start empty, never inherit the old state.

No `apply` is automated. Inspect the complete plan, including existing GitHub
and Entra resources, before a human-approved apply. The credentials above stay
in the current process only.

## Import existing identity and GitHub controls

Import existing app registrations, service principals and federated credentials
before applying to avoid duplicate identities. Use IDs from private discovery.
For GitHub, inspect the current environment and deployment-policy IDs with `gh`;
never reuse policy IDs captured for the old tenant/repository.

Private `ci_client_ids` pins the discovered existing applications while imports
are incremental; verify these match `ci_client_ids` outputs after adoption.
For AzureAD provider v3, the federated-credential import ID is
`<application-object-id>/federatedIdentityCredential/<credential-id>`, not a
Microsoft Graph URL. Application and service-principal imports use their
documented `/applications/<id>` and `/servicePrincipals/<id>` resource IDs.

Representative resource addresses and import-ID shapes:

```text
module.github.github_repository_environment.envs["dev"]    caldova-crm-frontier:dev
module.github.github_repository_environment.envs["test"]   caldova-crm-frontier:test
module.github.github_repository_environment.envs["prod"]   caldova-crm-frontier:prod
module.github.github_repository_environment_deployment_policy.allowed_branches["dev:main"]
module.github.github_repository_environment_deployment_policy.allowed_branches["test:main"]
module.github.github_repository_environment_deployment_policy.allowed_branches["prod:main"]
module.github.github_branch_protection.main                caldova-crm-frontier:main
```

The optional `infra/scripts/bootstrap-import.ps1` accepts an approved private
JSON var-file with `manage_environments = true`, verifies tenant/environment IDs
against `.platform.local.json`, and imports Power Platform resources only.
It never creates or applies resources. Reference-only mode needs no such import.
The provider requires a security group for managed non-Developer environments.
The existing environments have no security group; do not invent one, change
their type or alter access policy merely to satisfy Terraform. Management
opt-in requires a separately reviewed group/access design.

## Plan invariants

- **No reviewer removal.** TEST retains its existing reviewer and
  `prevent_self_review = false`; PROD requires a reviewer and
  `prevent_self_review = true`. `can_admins_bypass = false` for all slots.
- All three environment deployment policies allow only `main`.
- Preserve `required_linear_history = true`, `dismiss_stale_reviews = true`,
  required `gate1`, and no force-push/deletion bypass on main.
- No PR federation on a deployment identity.
- Environment variables include verified tenant/client/environment/organisation IDs.
- No shared tenant-setting resource and no HR resources.
- If an existing reviewed-ref object is recreated, re-check the current live
  policy ID before re-importing. Historical evidence is not current identity.

The existing environment lifecycle intentionally preserves its provisioned
type and security group. This foundation does not change subscription/trial
licensing or claim that a PROD-labelled environment has a production SKU.
