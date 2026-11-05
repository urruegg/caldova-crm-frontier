# Usage

Illustrative styles adapted from sanitized legacy inputs, not approved
Caldova corporate identity. See [provenance](../README.md#where-the-values-come-from).

## The three-layer model

```
tokens/     raw values — generated, never hand-edited
theme/      Fluent v9 Theme objects built from tokens
components/ the Caldova design language expressed as React
```

Consume the **highest** layer that solves your problem. Reach for raw tokens
only when a Fluent component genuinely cannot express what you need.

## Choosing a surface

| Component | When |
|---|---|
| `CaldovaSurface` | Any panel, card or grouped region. The base of everything. |
| `KpiTile` | A single metric with optional delta. |
| `StatusBadge` | Policy / claim / case state. |
| Fluent `Card`, `Table`, `Dialog`… | Everything else — they are already themed. |

Do **not** rebuild Fluent components. If `Button` looks wrong, the theme is
wrong; fix the theme, not the button.

## The signature device

The retained reference styling uses a **panel with a
brand rule on its leading edge and a letter-spaced uppercase kicker**. That is
`CaldovaSurface` with `rule` and `kicker`.

```tsx
<CaldovaSurface kicker="Kernbotschaft" rule="start" tone="sand">
  …
</CaldovaSurface>
```

Use it consistently for a coherent demo. No Caldova logo is supplied or implied.

## Tone ladder

`default` (white) → `paper` (`#FBFAF8`) → `sand` (`#EEECE8`) → `ink` (`#111111`)

Step **one** level to separate adjacent regions. Jumping from white to ink
inside a single view reads as two different applications.

## Dark mode

```tsx
<CaldovaProvider mode="auto">   {/* follows prefers-color-scheme */}
```

In PCF, dark mode follows the **host app theme** instead — see `docs/PCF.md`.

## What not to do

- Don't hardcode `#DB2323`. Use `tokens.colorBrandBackground` so dark mode and
  future ramp changes flow through.
- Don't use brand red for status. See the rule in `src/tokens/semantic.ts`.
- Don't add shadows. The illustrative styling is flat; elevation tokens exist
  for dialogs and overlays only.
- Don't override `borderRadius` upward. Soft corners are the fastest way to
  make this look like generic Fluent again.
