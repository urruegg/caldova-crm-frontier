---
title: CI/CD Workflow Specification - Caldova managed promotion
version: 1.0
date_created: 2026-11-05
last_updated: 2026-11-05
owner: SecDevOps
tags: [process, cicd, github-actions, dataverse]
---

## Workflow overview

Trace: US-007 / [ADR-0041](../adr/ADR-0041-caldova-platform-foundation.md).
Scope: `cd-solution-test.yml` and `cd-solution-prod.yml`.
Both are manually dispatched from reviewed main. No PR run receives cloud identity.

## Execution flow

TEST: verify DEV identity -> export managed packages -> record source/hash/version
-> approve TEST -> verify target -> import -> verify actual managed versions.

PROD: validate selected successful TEST run -> approve PROD -> download that
run's artifact -> verify revision/hashes -> verify target -> import identical
packages -> verify actual managed versions.

## Jobs and dependencies

| Job | Depends on | Target |
| --- | --- | --- |
| TEST export | Reviewed main | DEV, read/export |
| TEST import | Exported artifact and TEST approval | TEST |
| PROD validation | Selected TEST run | No cloud access |
| PROD import | Validated TEST run and independent PROD approval | PROD |

## Requirements matrix

| ID | Requirement | Acceptance |
| --- | --- | --- |
| FR-01 | Three isolated deployment identities | Each environment has its own app/user and variables |
| FR-02 | Exact tested artifacts | PROD downloads selected TEST run, never re-exports DEV |
| FR-03 | Source provenance | Successful same-repository TEST workflow, main branch, exact SHA |
| FR-04 | Package integrity | Every release package matches its SHA-256 manifest entry |
| FR-05 | Real smoke evidence | Expected solution is managed and its actual version matches the artifact |
| SR-01 | Explicit identity | Token tenant and WhoAmI organisation match configured target before mutation |
| SR-02 | Restricted trust | Environment-only OIDC federation; no PR deployment federation |
| SR-03 | Human release control | PROD disallows self-review and admin bypass; main-only branch policy |

## Input/output contracts

TEST input `mode`: InstallOrUpdate or StageForUpgrade.
PROD input `test_run_id`: numeric ID of a completed successful TEST workflow.

Protected variables: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`,
`POWER_PLATFORM_ENV_ID`, `POWER_PLATFORM_ENV_URL`, `POWER_PLATFORM_ORG_ID`.
Values never enter source. No long-lived cloud secret is required.

Artifact `managed-solutions` contains four managed solution ZIPs and
`release.json`: `sourceSha`, `mode`, and ordered `solutions` entries with
`name`, `file`, `version`, `sha256`. Staged TEST artifacts are ineligible for PROD.

## Execution constraints

PROD source validation has a ten-minute timeout; import has a sixty-minute
timeout. Concurrency serializes each target environment without cancelling an
in-flight import. GitHub-hosted Ubuntu runs PowerShell and supported PAC tooling.
Network access is limited operationally to GitHub, Entra, package distribution
and the configured Dataverse targets. No deployment-duration SLA is claimed.

## Error handling and quality gates

Invalid run/revision/hash, wrong identity, missing package, authentication
failure or mismatched deployed version fails the run. There is no success-shaped
placeholder, silent fallback to another environment, or automatic retry of writes.
Do not treat a partially imported set as an approved release.

Offline Pester and Terraform validation run before source integration.
Repository main protection and environment approvals remain required.

## Monitoring and evidence

Retain workflow run identity, source SHA, artifact metadata and smoke results.
Do not log tokens or admin accounts. Monitor failed runs through the repository's
workflow notifications; no separate alert destination or retention SLA is invented.
Evidence must distinguish configured identities, human connectivity, OIDC smoke,
and an actual managed-solution release.

## Integration and governance

GitHub remains source/PR authority. Azure DevOps organisation access is a verified
integration prerequisite only; no project, source replication or pipeline is
created by this foundation. Dataverse schema and consent/AI boundaries are unchanged.

## Edge cases and recovery

- Wrong/fork/failed/non-main/expired TEST run: stop without PROD mutation.
- Missing independent approver: remain blocked; never bypass the environment.
- Staged upgrade: verify holding solution version in TEST; cannot promote it.
- Concurrent releases: serialize; no import cancellation.
- Partial import: investigate against the last known-good artifact and environment
  backup. A managed-solution downgrade is not a guaranteed rollback.

## Validation and change management

Pester tests cover source/hash/mode validation, unsafe filenames, wrong tenant/
organisation and actual-version smoke failure. YAML syntax and PowerShell AST
checks cover workflow scripts. Live TEST/PROD solution imports are separate
release actions, not connectivity tests.

Update this specification, ADR and regression tests when changing release
authority, artifact shape, identities, approval policy or rollback semantics.

| Version | Date | Change |
| --- | --- | --- |
| 1.0 | 2026-11-05 | Initial three-slot managed promotion contract |
