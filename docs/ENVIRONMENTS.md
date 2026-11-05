# Environments - Caldova CRM Frontier

Trace: [US-007](./BACKLOG.md) / [ADR-0041](./adr/ADR-0041-caldova-platform-foundation.md).

## Private configuration

This public repository contains no real tenant IDs, organisation/environment IDs,
admin accounts, application IDs or target URLs. The verified values live in
ignored `.platform.local.json`; copy the shape from
[`infra/platform.example.json`](../infra/platform.example.json) for another checkout.
Never commit the admin UPN or a password. Human access uses interactive Entra
sign-in; automation uses environment-scoped workload identity federation.

The supplied tenant also hosts Caldova HR. CRM must not own or change shared
tenant policy by default. `manage_tenant_settings` defaults to `false`.

## Three existing slots

| Slot | Purpose | Solution mode | Identity and approval |
| --- | --- | --- | --- |
| DEV | Authoring and synthetic-data validation | Unmanaged | Dedicated DEV CI identity; protected main |
| TEST | Integration and deployment validation | Managed | Dedicated TEST identity; reviewer approval retained |
| PROD | Controlled demo release | Exact managed packages from a successful TEST run | Dedicated PROD identity; independent approval; no admin bypass |

All three existing environments were discovered in the supplied tenant and
passed authenticated Dataverse `WhoAmI` on 2026-11-05. This proves human
connectivity, not that CRM solutions, licensing, languages or CI deployment have
already been validated. Environment display names, region, type, currency and
languages must be read from existing metadata before any Terraform plan.

PROD is a release slot for this synthetic-data reference platform. Real business
data requires a separate architecture/compliance decision; the name is not
permission to process customer records.

## Local connectivity verification

Live metadata additionally confirmed Switzerland hosting, CHF base currency,
Sandbox DEV/TEST and Production PROD. Only EN (`1033`) is provisioned currently.
DE/FR/IT remain deployment prerequisites, reconciled by the existing language
workflow; they are not claimed active by this foundation.

The three scoped CI applications, environment-only federations, Dataverse
application users/roles, and five variables per GitHub Environment have been
created and read back. PROD's independent-review/no-bypass policy is configured.
This is not yet a new-source CI run or a managed-solution deployment.

The existing scoped identities and GitHub controls were adopted into isolated
Caldova Terraform state (31 resources). The verified plan has zero creates,
deletes or replacements; ten in-place metadata/DEV self-review differences
remain unapplied. No environment metadata, security groups or shared tenant
policy were changed. The previous tenant's state was not copied.

```powershell
.\infra\scripts\Test-PlatformConnection.ps1
```

The verifier acquires a tenant-scoped token in memory, checks its tenant claim,
calls `WhoAmI`, and rejects a different organisation. No token is persisted.
The loader rejects missing slots, invalid IDs, duplicate targets and unsafe URLs.
The active Azure/PAC profile is never silently switched.

## Deployment configuration

GitHub Actions execution is temporarily paused by the repository owner while
the foundation is published. The configuration below is retained for later
activation, not a claim that deployments currently run. See
[Operations](./OPERATIONS.md#temporary-github-actions-pause).

Each protected GitHub Environment (`dev`, `test`, `prod`) supplies:

- `AZURE_TENANT_ID`
- `AZURE_CLIENT_ID`
- `POWER_PLATFORM_ENV_ID`
- `POWER_PLATFORM_ENV_URL`
- `POWER_PLATFORM_ORG_ID`

Deployments verify tenant and organisation identity before mutation. OIDC
federation must match the repository's actual immutable subject prefix and
environment name after the GitHub rename. Pull requests receive no cloud trust.
PROD promotion accepts only a successful main-branch TEST deployment, verifies
source SHA and package hashes, and checks deployed managed versions. Staged
holding solutions cannot be promoted as active releases.

## Bootstrap and rollback

See the [infrastructure runbook](../infra/README.md) for private configuration,
safe application-user bootstrap and isolated Terraform state. Existing
`CRMShowcase` publisher, `crmshow_` schema identifiers, solution unique names and
security-role names remain stable. Renaming published schema is not branding.

Do not delete environments to roll back. Stop deployment, retain the previous
known-good managed artifacts, and use the reviewed Dataverse backup/restore or
solution-upgrade recovery path. Managed package downgrades are not a general
rollback mechanism. Shared tenant settings and HR resources are outside scope.
