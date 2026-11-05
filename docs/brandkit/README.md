# Caldova Fluent UI Illustrative Kit

Fluent UI **v9** styling reference for Caldova CRM Frontier — one set of tokens
driving both **React applications** and **Power Apps PCF controls**.

> **Illustrative only — not approved corporate identity.** This kit is adapted
> from sanitized legacy design inputs. Retained colours, measurements and
> layout styles are references, not Caldova brand assets. Renaming does not
> imply Caldova ownership or source-customer endorsement. No logo or licensed
> corporate font is supplied.

| Field | Value |
|---|---|
| Version | 0.1.0 (Draft) |
| Date | 2026-08-11 |
| Fluent | `@fluentui/react-components` v9 |
| Status | Draft — illustrative styling, not an approved brand system |
| Classification | Sanitized demo reference — no customer approval implied |

---

## Why this exists

This kit demonstrates **a colour ramp, warm surfaces and restrained shapes**
without changing Fluent component behaviour. The Caldova names identify the
demo package and its APIs, not a validated corporate design system.

## Where the values come from

The numerical values below are retained from legacy design inputs, not
newly measured or approved for Caldova. Historical source notes describe a
logo-derived red, warm corporate surfaces and deck typography; those source
assets are not redistributed here and their ownership is unchanged.

| Token | Source |
|---|---|
| `#DB2323` accent red | Retained legacy reference seed; not an approved Caldova colour. |
| Brand ramp (16 stops) | Generated from the retained seed in CIE L\*C\*h°; historical comparison with `#FF8484` is not Caldova brand validation. |
| Warm neutrals | Retained legacy neutral anchor `#484445`. |
| Paper tones | Retained reference values: `#FBFAF8`, `#F6F5F2`, `#EFEDE9`, `#EEEAE5`. |
| Type scale | Legacy deck measurements mapped to a 16px web base; uses system fonts only. |
| Shape | Adapted flat panels, hairline rules and warm surface shifts. |

> **Fonts and previews.** `CALDOVA_FONT_STACK` uses Arial and system fallbacks;
> there is no invented Caldova typeface. Any future webfont needs verified
> licensing and design approval. The existing local `docs/palette.png` is an
> untouched legacy-generated preview, not a Caldova asset: do not publish or
> use it as approved identity.

## Install

```bash
npm i @fluentui/react-components
# then reference this package from the monorepo / copy it in
```

## React app

```tsx
import { CaldovaProvider, CaldovaSurface, KpiTile, StatusBadge }
  from '@caldova/fluent-brandkit';

export function App() {
  return (
    <CaldovaProvider mode="light">
      <KpiTile
        label="Offene Schäden"
        value="1 284"
        caption="Generalagentur Bern-Mittelland"
        delta={-6}
      />
      <CaldovaSurface kicker="Vertrag" rule="start" tone="sand">
        <StatusBadge status="active">Aktiv</StatusBadge>
      </CaldovaSurface>
    </CaldovaProvider>
  );
}
```

## PCF control

```tsx
import { CaldovaPcfProvider } from '@caldova/fluent-brandkit/pcf';

<CaldovaPcfProvider context={context} targetDocument={window.document}>
  {/* your control */}
</CaldovaPcfProvider>
```

See [`pcf/CaldovaCard`](pcf/CaldovaCard) for a complete virtual control, and
[`docs/PCF.md`](docs/PCF.md) for the platform gotchas that will otherwise cost
you an afternoon each.

The sample control is scaffolding reference material and is not part of the
package type-check until its generated `ManifestTypes.d.ts` is created by the
Power Platform CLI.

## Non-React surfaces

Import `src/styles/caldova.tokens.css` and use the CSS custom properties.
Both outputs are generated from the same ramp, so they cannot drift.

```html
<div class="caldova-surface">
  <span class="caldova-kicker">Haushalt</span>
  …
</div>
```

## What's in the box

```
src/tokens/     brandRamp · neutrals · semantic · typography · shape
src/theme/      caldovaLightTheme · caldovaDarkTheme
src/components/ CaldovaProvider · CaldovaSurface · KpiTile · StatusBadge
src/styles/     caldova.tokens.css · fonts.css
pcf/            CaldovaPcfProvider · usePowerAppsTheme · sample control
tokens/         design-tokens.json (W3C DTCG / Style Dictionary)
docs/           USAGE · PCF · ACCESSIBILITY · TOKENS
```

## Two rules the kit enforces

**1. Brand red is an accent, never a status.** An error state that looks
identical to a brand accent is not a signal. `danger` is a darker, desaturated
red (`#A4262C`) that separates cleanly from `#DB2323`.

**2. Brand red is not readable on dark.** `#DB2323` on `#171717` measures
3.65:1 — below the 4.5:1 threshold. The dark theme pins brand foreground to
stop 100 (`#F25B52`, 5.46:1). Do not "fix" it back to 80.

## Regenerating

The ramps are generated, not hand-picked:

```bash
python tools/ramp.py       # brand ramp from the seed colour
python tools/neutrals.py   # warm neutrals + contrast report
```

These scripts print reference ramp values and contrast reports; they do not
rewrite the TypeScript, CSS or JSON files. If the illustrative seed changes,
update those sources together and verify consistency.
