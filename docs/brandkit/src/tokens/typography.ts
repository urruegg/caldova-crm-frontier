/**
 * Type ramp.
 *
 * Illustrative system-font stack, not approved corporate identity.
 * No Caldova typeface or licensed legacy font is supplied. Any future
 * webfont requires verified embedding rights and explicit design approval.
 */
export const CALDOVA_FONT_STACK =
  "Arial, 'Helvetica Neue', Helvetica, 'Segoe UI', system-ui, sans-serif";

export const CALDOVA_FONT_STACK_MONO =
  "'Cascadia Mono', 'SF Mono', Consolas, 'Liberation Mono', monospace";

/**
 * Scale adapted from legacy design inputs (measured pt sizes in the
 * deck: 34/32/28 display, 16 statement, 12–13 subline, 10 body, 9 small,
 * 8 caption) and mapped onto Fluent's v9 ramp at 16px base.
 */
export const caldovaTypography = {
  display:   { fontSize: '46px', lineHeight: '52px', fontWeight: 700 },
  hero:      { fontSize: '36px', lineHeight: '42px', fontWeight: 700 },
  title1:    { fontSize: '28px', lineHeight: '34px', fontWeight: 700 },
  title2:    { fontSize: '22px', lineHeight: '28px', fontWeight: 700 },
  title3:    { fontSize: '18px', lineHeight: '24px', fontWeight: 600 },
  statement: { fontSize: '16px', lineHeight: '22px', fontWeight: 600 },
  body1:     { fontSize: '14px', lineHeight: '20px', fontWeight: 400 },
  body2:     { fontSize: '13px', lineHeight: '18px', fontWeight: 400 },
  caption1:  { fontSize: '12px', lineHeight: '16px', fontWeight: 400 },
  caption2:  { fontSize: '11px', lineHeight: '14px', fontWeight: 400 },
  /** Illustrative letter-spaced uppercase eyebrow adapted from legacy inputs. */
  kicker:    { fontSize: '11px', lineHeight: '14px', fontWeight: 700,
               letterSpacing: '0.09em', textTransform: 'uppercase' as const },
} as const;
