# Caldova foundation implementation plan

> **For agentic workers:** Execute inline with executing-plans. The independent
> branding slice may run in parallel; do not overlap its files with platform work.

**Goal:** Rebrand and connect the existing repository to three verified Caldova
Dataverse environments without changing published schema identifiers.

**Architecture:** Private validated target configuration, read-only identity
preflight, parameterized bootstrap, isolated Terraform state and managed-artifact
promotion. GitHub remains the current source and delivery authority.

**Tech Stack:** PowerShell/Pester, Terraform, Entra federation, GitHub Actions,
Dataverse and React/TypeScript reference branding.

---

1. Add `infra/scripts/tests/PlatformFoundation.Tests.ps1`; run
   `Invoke-Pester -Path ./infra/scripts/tests/PlatformFoundation.Tests.ps1 -Output Detailed`.
   Expect failure for absent configuration functions and PROD wiring.
2. Implement `Get-PlatformConfiguration.ps1`, `Test-PlatformConnection.ps1`
   and safe configuration-driven `add-ci-app-users.ps1`. Reject missing IDs,
   endpoint aliases and tenant/organisation mismatches before mutation.
3. Extend the root Terraform map to PROD, protect existing environments from
   destruction and make tenant-wide settings opt-in. Validate using an isolated
   `TF_DATA_DIR`; never reuse the previous tenant's state or auto-apply.
4. Wire identity checks and managed artifacts into TEST/PROD workflows.
   PROD downloads the successful TEST run's artifact and requires main and
   environment approval. Keep source commit identity with the artifact.
5. Migrate legacy branding and affected paths/imports, preserve technical names,
   ignored raw imports, existing edits and accurate third-party provenance.
6. Document ADR-0042, US-007, environments, configuration, bootstrap and rollback.
7. Run focused and integrated Pester suites, Terraform fmt/validate and branding
   typecheck. Repeat authenticated discovery/WhoAmI against all three targets.
   Record unperformed solution deployment and any live identity prerequisites.

The owner subsequently requested a scoped commit and feature-branch push with
GitHub Actions temporarily disabled. No merge, solution import or shared-tenant
policy apply is authorized. The working checkout contains unrelated in-progress
edits which must remain uncommitted and preserved.
