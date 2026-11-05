# Caldova CRM Frontier foundation

Date: 2026-11-05. Trace: US-007 / ADR-0041.

The user directed autonomous implementation of the staged in-place refactor.
GitHub remains source/PR authority and existing workflow definitions are retained.
The owner subsequently requested a repository-wide Actions pause while finishing
and publishing the foundation; see [Operations](../../OPERATIONS.md#temporary-github-actions-pause).
The supplied
Azure DevOps organisation is a future integration target, not authorization to
replace the delivery plane or copy source history.

## Boundaries

- Caldova CRM Frontier is the product identity. Adapt legacy customer-labelled
  reference material without claiming ownership of third-party assets.
- Preserve `CRMShowcase`, `crmshow_`, solution unique names and security-role
  identities; changing them is a separate schema migration.
- Use the three existing DEV, TEST and PROD Dataverse environments. Discovery
  and authenticated WhoAmI succeeded for all three on 2026-11-05.
- Tenant, environment, organisation and application IDs live only in ignored
  configuration or protected deployment variables, never in this specification.
- Synthetic data only. PROD means the final demo-release slot, not permission
  to ingest real customer data or enable autonomous customer-facing acts.
- Do not apply shared tenant settings: HR uses the same tenant.

## Delivery

DEV authors unmanaged solutions. TEST imports managed artifacts. PROD consumes
the exact artifact of a successful reviewed TEST run, never a new DEV export.
Identity verification must reject the wrong tenant or organisation before
deployment. Environment-scoped federation and protected-main deployment rules
separate identities. TEST/PROD deployment approval remains explicit.

Terraform has a new tenant-specific local state directory and references existing
environments without managing their access policy. An explicitly approved
management opt-in uses imports and destruction protection. No automatic apply or environment
creation is part of this migration.

## Verification and release gates

Offline tests cover invalid/missing/duplicate targets, tenant and organisation
mismatch, bootstrap safety, and three-slot wiring. Terraform validates without
accessing the old state. Branding references/imports are tested after renaming.
Live checks are read-only unless explicitly bootstrapping scoped CI identities.
Do not import CRM solutions or alter shared policy as a connectivity test.

The retained insurance scenario and Smith household remain synthetic reference
content, not evidence about Caldova's actual business. Existing AI safety and
licensing requirements are unchanged.

## Implementation evidence

- Three existing targets passed tenant-scoped discovery and authenticated
  WhoAmI. Region/currency and existing environment SKUs were read, not guessed.
- Three secretless CI apps, environment-only federations and environment-local
  application users/roles were created and verified. GitHub has the matching
  target variables and protected PROD approval policy.
- Azure DevOps organisation access was verified without changing projects.
- Thirty-one existing identity/GitHub resources were adopted into separate
  local state. The final plan contains no creates, deletes or replacements;
  ten in-place metadata/DEV self-review updates were not applied.
- 434 solution/platform tests passed outside the existing convergence subprocess
  suite. The final focused platform/reviewed-ref suite passed 64 tests.
  Brandkit typecheck, Terraform fmt/validate, workflow YAML and embedded
  PowerShell syntax checks passed. Publishable text contains no supplied private
  deployment values.
- The initial full run still exposed five existing convergence subprocess
  failures: a test CLI shim returns valid JSON but leaves its exit code empty.
  The Ready case also failed using the HEAD test source; production convergence
  code is unchanged. This is not a claim of green full CI.
- The owner requested a scoped foundation commit and feature-branch push after
  pausing Actions. Existing unrelated edits and private configuration stay out
  of the commit. No CRM solution was imported into TEST/PROD; source integration
  and an actual release remain governed actions.
