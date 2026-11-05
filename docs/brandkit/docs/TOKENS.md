# Token reference

Illustrative values adapted from sanitized legacy inputs, not approved
Caldova corporate identity. The scripts print reference data; source files
must be updated together rather than assuming automatic regeneration.

Generated output. To change anything, edit the generator in `tools/` and
re-run — never hand-edit the token files, or TypeScript and CSS will drift.

## Generation

```bash
python tools/ramp.py       # brand ramp  → ramp.json
python tools/neutrals.py   # neutrals    → neutrals.json + contrast report
```

Both work in CIE L\*C\*h° so steps are perceptually even rather than
mathematically even in RGB — which is why the ramp does not go muddy in the
mid-tones the way a naive `lighten()`/`darken()` ramp does.

## Brand ramp construction

- Seed `#DB2323` → L\*=47.48, C\*=82.61, h=35.48°, pinned at stop 80.
- Lightness interpolates to L\*=12 at stop 10 and L\*=97.5 at stop 160.
- **Chroma is damped toward both ends** (‑80% into the tints, ‑34% into the
  shades) so nothing clips out of sRGB gamut.
- **Hue swings ‑11° across the tints.** Without this, chroma clipping at high
  lightness drags a 35° red toward orange and stops 140–160 read as salmon.
  With it they stay brand red.

Historical comparison: stop 120 (`#FF8C83`) sits within ΔE 2 of the legacy
reference secondary `#FF8484`. This does not validate Caldova brand identity.

## Neutral ramp construction

Fluent's stock neutrals are cool. Retained legacy reference surfaces are warm:

| Measured | L\* | C\* | h° |
|---|---|---|---|
| `#FBFAF8` | 98.30 | 1.07 | 91.0 |
| `#F6F5F2` | 96.54 | 1.57 | 97.0 |
| `#EFEDE9` | 93.80 | 2.17 | 90.8 |
| `#EEEAE5` | 92.87 | 2.94 | 80.7 |
| `#484445` | 29.26 | 1.90 | 360.0 |

So the ramp is built at h≈91° above L\*84 (paper), h≈94° in the mid range, and
h≈20° below L\*55 (warm taupe shadows) — with chroma kept under 3.1 throughout
so it never reads as a colour, only as warmth.

## Files

| File | Consumers |
|---|---|
| `src/tokens/*.ts` | React apps, PCF controls |
| `src/styles/caldova.tokens.css` | plain CSS, canvas apps, email, Power BI visuals |
| `tokens/design-tokens.json` | Style Dictionary, Figma import, other pipelines |

All three are generated from the same source. If they disagree, someone
hand-edited one — regenerate.
