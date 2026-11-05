/**
 * Illustrative warm neutral ramp adapted from legacy design inputs.
 *
 * Fluent's stock neutrals are cool grey. The retained legacy paper tones sit at
 * h≈91° in L*C*h° (#FBFAF8, #F6F5F2, #EFEDE9, #EEEAE5 all measure C* 1.1–2.9,
 * h 80–97°). This ramp preserves that warm reference styling.
 *
 * Legacy anchor #484445; not approved Caldova corporate identity.
 * Key: L* value (n2 = darkest … n98 = lightest paper).
 */
export const caldovaNeutrals = {
  n2: '#0C0606',
  n4: '#120D0D',
  n6: '#161212',
  n8: '#1A1717',
  n10: '#1E1B1B',
  n12: '#221F1F',
  n16: '#2A2727',
  n20: '#323030',
  n24: '#3B3838',
  n28: '#444242',
  n32: '#4D4B4B',
  n36: '#565454',
  n38: '#5B5959',
  n40: '#605E5E',
  n44: '#696868',
  n48: '#737272',
  n52: '#7D7C7C',
  n56: '#878685',
  n60: '#91918F',
  n68: '#A6A6A4',
  n76: '#BCBBB9',
  n84: '#D2D1D0',
  n88: '#DEDDD9',
  n92: '#EAE8E3',
  n94: '#F0EEE8',
  n96: '#F6F3EE',
  n98: '#FCF9F3',
} as const;

/** Retained legacy reference surfaces, not Caldova corporate assets. */
export const caldovaPaper = {
  paper0: '#FFFFFF',
  paper1: '#FBFAF8',
  paper2: '#F6F5F2',
  paper3: '#F4F3F0',
  paper4: '#EFEDE9',
  sand1:  '#EEECE8',
  sand2:  '#EEEAE5',
  rule:   '#D5D5CF',
  hairline: '#DDDDDD',
  ink:    '#171717',
  inkPanel: '#111111',
  brandNeutral: '#484445',
} as const;
