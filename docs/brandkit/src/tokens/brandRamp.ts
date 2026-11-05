import type { BrandVariants } from '@fluentui/react-components';

/**
 * Illustrative Caldova ramp — 16 stops, Fluent UI v9 `BrandVariants`.
 *
 * Seed #DB2323 is retained from sanitized legacy design inputs whose source
 * notes describe sampling a source-customer logo. It is not a Caldova logo
 * measurement or approved corporate colour; no source logo is included.
 *
 * The ramp is generated in CIE L*C*h° so the steps are perceptually even.
 * Chroma is damped toward both ends and the hue swings ~11° off orange in the
 * tints, which keeps 130–160 reading as brand red rather than salmon.
 * The legacy comparison of stop 120 (#FF8C83) with #FF8484 is historical
 * reference context, not validation of Caldova corporate identity.
 *
 * `brandColorPrimary` is stop 80.
 */
export const caldovaBrandRamp: BrandVariants = {
  10: '#550000',
  20: '#6A0000',
  30: '#7E0000',
  40: '#920000',
  50: '#A50008',
  60: '#B80010',
  70: '#CA1019',
  80: '#DB2323',
  90: '#E7413A',
  100: '#F25B52',
  110: '#FC746A',
  120: '#FF8C83',
  130: '#FFA49D',
  140: '#FFBCB7',
  150: '#FFD5D1',
  160: '#FFEDEB',
};

/** Stop 80 — the retained illustrative accent, not an approved brand colour. */
export const CALDOVA_RED = '#DB2323';

/**
 * Accessibility note — measured, not assumed:
 *   #DB2323 on #FFFFFF = 4.91:1  → passes WCAG 2.1 AA for normal text.
 *   #CA1019 (stop 70)  = 5.83:1  → use when you need margin on tinted paper.
 *   #DB2323 on #171717 = 3.65:1  → NOT sufficient for body text on dark.
 * On dark surfaces use stop 100 (#F25B52, 5.46:1 on ink) or lighter.
 */
export const BRAND_CONTRAST = {
  onWhite: { 70: 5.83, 80: 4.91, 90: 4.03, 100: 3.28 },
  onInk:   { 80: 3.65, 90: 4.45, 100: 5.46, 110: 6.70 },
} as const;
