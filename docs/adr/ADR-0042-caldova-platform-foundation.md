# ADR-0042 - Caldova CRM Frontier platform foundation

| Field | Value |
| --- | --- |
| Status | Implemented foundation; release deployment remains gated |
| Date | 2026-11-05 |
| Decision mode | User-directed staged refactor |
| Confidence | High for existing-environment connectivity; release evidence separately required |
| Topic area | A4 / A8 - tenant foundation and ALM |
| Story | US-007 |
| Licence | Configuration/own build; existing platform licences and capacity still require verification |
| Upgrade impact | Low for branding; environment wiring changes without published schema renames |
| CAF methodology | Ready, Govern, Secure, Manage |
| WAF pillars | Security, Reliability, Operational Excellence; protected promotion adds review latency |
| Zero Trust | Explicit tenant/organisation checks; slot-specific identities; no PR cloud trust |
| Responsible AI | Existing synthetic-data, human-accountability and advisory boundaries unchanged |

## Context and options

The existing main branch had already assigned ADR-0041 to the Code Apps UX
decision. During integration this new foundation record was assigned ADR-0042;
the existing Code Apps decision retains its identifier.

The existing repository is now `caldova-crm-frontier`. The user supplied a
Caldova tenant shared with HR and three existing Power Platform environment URLs.
Authenticated discovery and WhoAmI confirmed all three on 2026-11-05.

1. **Staged in-place refactor (selected):** preserve CRM assets and technical
   identifiers; replace branding and establish separate environment identities.
2. **HR-style delivery-plane migration:** adds Azure Boards/Pipelines ownership
   decisions beyond the supplied organisation URL. Deferred.
3. **Clean rebuild:** discards useful reviewed contracts and regression coverage.
   Rejected for this foundation slice.

## Decision

Caldova CRM Frontier uses existing DEV, TEST and PROD slots. DEV authors
unmanaged solutions; TEST/PROD receive managed releases. PROD consumes the exact
hash-verified artifact of a successful reviewed-main TEST run. It never exports
DEV again. Post-import checks verify the intended managed solution versions.

Keep actual identifiers and URLs private. Human access is interactive; CI uses
separate environment-scoped Entra applications and federation. Wrong tenant or
organisation blocks writes. TEST retains its review gate; PROD requires
independent approval without admin bypass.

Use isolated tenant-specific Terraform state. Existing environments are
reference-only by default: the provider requires security groups to manage
non-Developer environments, whereas the supplied environments have no group.
Do not alter access policy to satisfy a provider. Explicitly approved management
uses declarative import and destruction protection. Do not manage shared
tenant-wide policy or HR resources. Do not reuse the previous state or identity.

`CRMShowcase` publisher, `crmshow_` schema, solution and security-role identities
remain stable. Brand adaptation does not authorize rewriting raw exports,
changing historical provenance, or claiming third-party trademarks as Caldova.
The insurance scenario remains synthetic reference content.

## Consequences and review triggers

This is configuration-first platform work plus small PowerShell validation
helpers. No AI model, prompt, consent boundary or autonomous action changes.
Actual platform licence/capacity and production SKU must be confirmed, not
inferred from a URL or PROD label. Introducing real customer data, changing
tenant policy, schema naming or delivery authority reopens architecture review.

Release activation requires merged reviewed source, green CI, available
independent PROD approver, verified application users, a successful TEST import,
and protected PROD promotion. Human connectivity alone is not release evidence.
Rollback is a reviewed Dataverse restore/upgrade recovery, never environment
deletion or an assumed managed-solution downgrade.

## Temporary workflow-execution exception

On 2026-11-05 the repository owner explicitly requested disabling all GitHub
workflows while finishing and publishing this foundation. Actions execution is
paused repository-wide; workflow definitions, protected-main checks and
environment approvals remain intact. This does not authorize a merge/deployment
bypass or represent green CI. Local checks and the known convergence-test
limitation remain disclosed. Resume only on an explicit decision, then validate
the exact source revision before release. See
[Operations](../OPERATIONS.md#temporary-github-actions-pause) for the reversible
administrative setting.
