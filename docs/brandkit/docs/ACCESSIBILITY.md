# Accessibility — measured, not assumed

All ratios below are computed from the actual token values (WCAG 2.1 relative
luminance). Regenerate with `python tools/neutrals.py`.

## Brand ramp contrast

| Stop | Hex | on `#FFFFFF` | on `#171717` |
|---|---|---|---|
| 60 | `#B80010` | 6.90 | 2.60 |
| 70 | `#CA1019` | **5.83** | 3.07 |
| **80** | **`#DB2323`** | **4.91** | 3.65 |
| 90 | `#E7413A` | 4.03 | 4.45 |
| 100 | `#F25B52` | 3.28 | **5.46** |
| 110 | `#FC746A` | 2.68 | 6.70 |
| 120 | `#FF8C83` | 2.25 | 7.97 |

### What this means in practice

- **`#DB2323` on white = 4.91:1** — passes AA for normal text. The brand red
  is usable for body-size text on white. That is not true of every corporate
  red and is worth knowing.
- **On warm paper** (`#FBFAF8`, `#F6F5F2`) the ratio drops marginally. Use
  **stop 70** (`#CA1019`, 5.83:1) for small text on tinted surfaces to keep
  margin.
- **On dark, stop 80 fails** (3.65:1). The dark theme pins brand foreground to
  **stop 100** (5.46:1). This is enforced in `caldovaDarkTheme` — do not
  override it back.
- **Large text (≥18.66px bold / ≥24px)** needs only 3:1, so stops 80–90 are
  fine for headlines on white.

## Neutral ramp on white

| Stop | Hex | Ratio | Use |
|---|---|---|---|
| n8  | `#1A1717` | 17.81 | ink panels |
| n16 | `#2A2727` | 14.81 | — |
| n32 | `#4D4B4B` | 8.66 | secondary text |
| n44 | `#696868` | 5.55 | tertiary text (AA) |
| n48 | `#737272` | 4.80 | **minimum for body text** |
| n52 | `#7D7C7C` | 4.16 | ✗ decorative only |
| n60 | `#91918F` | 3.16 | ✗ borders / icons only |

**Rule:** `n48` is the lightest neutral permitted for text. Anything lighter
is decoration, borders or disabled state.

## Non-colour requirements

- **Never** carry meaning in colour alone. `StatusBadge` pairs every colour
  with a text label and a dot — that is why it is built the way it is.
- Focus indicators come from Fluent. Do not remove outlines; the flat shape
  language already reduces affordance cues.
- The kit uses near-square corners, so **borders and rules do more work than
  usual**. Keep `colorNeutralStroke1` at or above `#D5D5CF`.

## Open verification items

- [ ] Screen-reader pass on the PCF controls in a real model-driven form
- [ ] 200% zoom and host font-scale pass
- [ ] Confirm the corporate typeface's rendered x-height does not push small
      sizes below legibility once the licensed font replaces Arial
