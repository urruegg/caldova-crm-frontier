import { caldovaPaper } from './neutrals';
import { CALDOVA_RED } from './brandRamp';

/**
 * Semantic colours.
 *
 * Deliberate rule: Caldova red is the ONLY accent. Danger therefore cannot
 * also be red — an error state that looks identical to a brand accent is not
 * a signal. Danger uses a darker, desaturated red so it separates from brand;
 * success/warning/info are muted so they never out-shout the brand.
 */
export const caldovaSemantic = {
  brand:        CALDOVA_RED,   // #DB2323 — accent, never status
  danger:       '#A4262C',
  dangerBg:     '#FDF3F4',
  warning:      '#8A6100',
  warningBg:    '#FDF6E3',
  success:      '#0E6C41',
  successBg:    '#EFF7F1',
  info:         '#2B5B8C',
  infoBg:       '#F0F5FA',
  // insurance-domain states used across the CRM surfaces
  policyActive:   '#0E6C41',
  policyPending:  '#8A6100',
  policyLapsed:   '#A4262C',
  claimOpen:      '#2B5B8C',
  claimClosed:    caldovaPaper.brandNeutral,
} as const;
