# Caldova CRM Frontier platform foundation

Trace: US-007 / [ADR-0042](../docs/adr/ADR-0042-caldova-platform-foundation.md).
The three existing environments are defined privately, not provisioned again.

## Local setup

1. Copy `platform.example.json` to the repository root as `.platform.local.json`.
2. Fill verified tenant, DEV/TEST/PROD environment and organisation GUIDs and URLs.
   Never add a password, token or admin UPN.
3. Use your interactive Entra sign-in for the intended tenant.
4. Run `.\infra\scripts\Test-PlatformConnection.ps1` from the repository root.

The migration populated the ignored local file from authenticated discovery.
It is machine-local and must be securely backed up outside Git if needed.
`.env.example` retains equivalent placeholders for tools using environment
variables; it is not automatically synchronized with the platform JSON file.

## CI identity bootstrap

Each slot has a distinct Entra application and service principal named
`caldova-crm-frontier-ci-<slot>`. Federation trusts only that slot's GitHub
Environment using the actual repository OIDC subject, never a PR subject.
No client secret is created.

After setting each private `clientId`, bootstrap explicitly:

```powershell
.\infra\scripts\add-ci-app-users.ps1 -Slot all -WhatIf
# Review the targets and requested roles before confirming:
.\infra\scripts\add-ci-app-users.ps1 -Slot all
```

The script selects service principals by application ID, verifies tenant and
organisation before writing, and assigns the DEV System Customizer role or
TEST/PROD System Administrator role needed for managed import. These are
environment-local deployment identities, not tenant administrators. Runtime
agents must never reuse them. Review a narrower custom deployment role before
moving beyond the synthetic demo.

GitHub environment variables are listed in
[ENVIRONMENTS.md](../docs/ENVIRONMENTS.md). TEST retains its reviewer;
PROD prohibits self-review and admin bypass. An independent authorized reviewer
must be available before a PROD workflow can proceed.

## Infrastructure as code

See [terraform/README.md](./terraform/README.md). Never reuse the previous
tenant's state, `.terraform` working data or private tfvars. Existing
environments are reference-only by default. Opt-in management requires reviewed
security-group ownership, declarative import and destruction protection.
Shared tenant-wide settings are opt-in and remain disabled for CRM/HR coexistence.

## Offline validation

```powershell
Import-Module Pester -MinimumVersion 5.5
Invoke-Pester -Path .\infra\scripts\tests -Output Detailed
terraform -chdir=infra\terraform fmt -check -recursive
terraform -chdir=infra\terraform validate
```

No solutions or tenant policies are changed by these checks.
