# Operations, Lifecycle Management & Technical Governance

| Field | Value |
| --- | --- |
| **Topic area** | **A8** — Operations, lifecycle management, technical governance |
| Status | Draft 0.3 · **Owner** `AG-E-04` SecDevOps |

## Framing — CAF and WAF

Operations of the showcase align with:

- The **Manage**, **Govern**, and **Secure** methodologies of the
  [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/overview).
- The **Operational Excellence** and **Reliability** pillars of the
  [Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/pillars).

Full framework-to-artefact mapping in
[MICROSOFT-FRAMEWORKS.md](./MICROSOFT-FRAMEWORKS.md).

## Temporary GitHub Actions pause

On 2026-11-05 the repository owner requested a temporary pause of all GitHub
workflows while the Caldova foundation is finished, committed and pushed.
Repository-wide Actions execution is disabled. Workflow definitions remain in
source, including PROD promotion; pushing a new definition does not enable it.
No workflows were running or queued when the pause was verified.

This is a user-authorized bootstrap exception, not successful CI evidence.
Local validation continues. Main branch protection, required `gate1`,
environment approval policies, secret scanning and push protection are not
weakened. Do not merge around missing checks or deploy while Actions is paused.

Check the current state:

```powershell
gh api repos/urruegg/caldova-crm-frontier/actions/permissions
```

After an explicit decision to resume, restore the previous Actions policy:

```powershell
gh api --method PUT repos/urruegg/caldova-crm-frontier/actions/permissions `
  -F enabled=true -f allowed_actions=all
```

Re-enabling does not retroactively validate commits pushed during the pause.
Run CI on the exact intended source revision, resolve failures, and retain the
normal main-branch and environment approval gates before any release.

## What the customer asks

Transparency on lifecycle management for configurations, extensions and
integrations — **version control, deployment processes, test automation, and
rollback** — how responsibilities split between customer, implementation
partner and vendor long term, what operating and governance effort is
realistically expected, and **how complexity is reduced or controlled over
time so the platform stays manageable after several release cycles.**

## The answer

[ADR-0017](./adr/ADR-0017-alm-everything-through-the-pipeline.md): **nothing
reaches an environment except through the pipeline.**

```
change request
  → ADR (docs/adr/)
  → solution change + test (solution/)
  → PR — required reviewers via CODEOWNERS
  → CI: build · solution checker · regression · policy-as-code · security gates
  → protected environment approval
  → deploy
  → rollback available as a pipeline action
```

At the end of a review the pipeline history is the evidence: the morning's
change is sitting in it. The topic becomes a review of something the customer
saw, not a claim they have to believe.

## Environments

| Environment | Purpose | Data |
| --- | --- | --- |
| DEV | Unmanaged authoring | Synthetic |
| TEST | Managed-solution regression and integration | Synthetic |
| PROD | Controlled managed demo release | Synthetic |

Details on the three existing Caldova environments and their private configuration:
[ENVIRONMENTS.md](./ENVIRONMENTS.md).

## Rollback

**Rollback must be demonstrable, not described.** If we cannot roll a live
change back in front of the customer, we do not make the claim. Rehearse it.

## Realistic effort — answer honestly

Customers often ask what operating and governance effort is *realistically*
expected. An understated answer is the fastest way to lose credibility with an
operations audience, and it will be tested in year two.

`[TBD — model the effort with the delivery team: platform ops, release
management, test maintenance, integration monitoring, agent evaluation upkeep.]`

## Local pac CLI setup

To work with the six Power Platform solutions locally (`solution/manifest.json`),
install the Power Platform CLI once:

```powershell
# One-off install (a specific stable version — the auto-selected 1.44.x had a
# broken NuGet package at the time of writing)
dotnet tool install --global Microsoft.PowerApps.CLI.Tool --version 1.43.6

# Read verified targets from ignored local configuration.
. .\infra\scripts\Get-PlatformConfiguration.ps1
$platform = Get-PlatformConfiguration
foreach ($slot in @('dev', 'test', 'prod')) {
  pac auth create --name "caldova-crm-$slot" `
    --environment $platform.environments[$slot].url --tenant $platform.tenantId --deviceCode
}

# Switch between them
pac auth select --name caldova-crm-dev
pac auth select --name caldova-crm-test

# Verify the active connection
pac org who
```

The auth session is cached in `%LOCALAPPDATA%\.PowerAppsCli` and is separate
from `az` — the `az login` context is NOT reused by `pac`, and vice-versa.

`--url` is deprecated in newer pac releases; `--environment <env-id-or-url>` is
the future-proof form. Both work on 1.43.x.

## How complexity stays controllable

- Every change traceable to an ADR — the estate is self-documenting.
- Extensions carry declared upgrade impact, so technical debt is visible before
  it accrues.
- Standard-first tiering ([EXTENSIBILITY.md](./EXTENSIBILITY.md)) keeps pro-code
  a deliberate, reviewed minority.
- No per-GA forks ([ADR-0013](./adr/ADR-0013-ga-ownership-and-territory.md)).
- **This requires discipline from the customer and the partner too, not only
  from us.** Say that out loud — it is the honest answer and it sets up the
  shared-responsibility conversation.
