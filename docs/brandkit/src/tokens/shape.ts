/**
 * Shape and elevation.
 *
 * The adapted legacy styling is flat and rectilinear: panels have square or
 * near-square corners, separation comes from hairline rules and warm surface
 * shifts, not from shadow. The signature device is a 3px accent rule on the
 * leading edge of a panel. These illustrative tokens are not approved
 * Caldova corporate identity.
 */
export const caldovaShape = {
  radiusNone:   '0',
  radiusSmall:  '2px',
  radiusMedium: '3px',
  radiusLarge:  '4px',
  radiusPill:   '999px',
  accentRule:   '3px',   // the brand's leading-edge rule
  hairline:     '1px',
} as const;

export const caldovaElevation = {
  flat:   'none',
  raised: '0 1px 2px rgba(23,23,23,0.08)',
  card:   '0 2px 6px rgba(23,23,23,0.10)',
  dialog: '0 8px 24px rgba(23,23,23,0.16)',
} as const;

export const caldovaSpacing = {
  xxs: '2px', xs: '4px', s: '8px', m: '12px',
  l: '16px', xl: '24px', xxl: '32px', xxxl: '48px',
} as const;
