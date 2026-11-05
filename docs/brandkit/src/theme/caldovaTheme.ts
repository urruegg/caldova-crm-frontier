import {
  createLightTheme,
  createDarkTheme,
  type Theme,
} from '@fluentui/react-components';
import { caldovaBrandRamp } from '../tokens/brandRamp';
import { caldovaNeutrals, caldovaPaper } from '../tokens/neutrals';
import { CALDOVA_FONT_STACK, CALDOVA_FONT_STACK_MONO } from '../tokens/typography';
import { caldovaShape } from '../tokens/shape';

/**
 * Caldova Fluent UI v9 themes.
 *
 * `createLightTheme` / `createDarkTheme` give us a complete, correct Fluent
 * token set from the brand ramp. We then override the parts where Caldova's
 * corporate design genuinely differs from Fluent's defaults:
 *
 *   1. Surfaces — warm paper tones instead of Fluent's cool greys.
 *   2. Typography — the Caldova font stack on every font token.
 *   3. Shape — near-square corners; Fluent's default radii are too soft.
 *
 * Everything else is left as Fluent generated it. Overriding more than this
 * is how a themed app slowly stops behaving like Fluent.
 */

const base = createLightTheme(caldovaBrandRamp);
const baseDark = createDarkTheme(caldovaBrandRamp);

const fontOverrides = (t: Theme): Partial<Theme> => ({
  fontFamilyBase: CALDOVA_FONT_STACK,
  fontFamilyMonospace: CALDOVA_FONT_STACK_MONO,
  fontFamilyNumeric: CALDOVA_FONT_STACK,
});

const shapeOverrides: Partial<Theme> = {
  borderRadiusNone:   caldovaShape.radiusNone,
  borderRadiusSmall:  caldovaShape.radiusSmall,
  borderRadiusMedium: caldovaShape.radiusMedium,
  borderRadiusLarge:  caldovaShape.radiusLarge,
  borderRadiusXLarge: caldovaShape.radiusLarge,
  borderRadiusCircular: caldovaShape.radiusPill,
};

export const caldovaLightTheme: Theme = {
  ...base,
  ...fontOverrides(base),
  ...shapeOverrides,

  // --- warm surfaces (this is what makes it read as Caldova) -------------
  colorNeutralBackground1: caldovaPaper.paper0,
  colorNeutralBackground2: caldovaPaper.paper1,
  colorNeutralBackground3: caldovaPaper.paper2,
  colorNeutralBackground4: caldovaPaper.paper4,
  colorNeutralBackground5: caldovaPaper.sand1,
  colorNeutralBackground6: caldovaPaper.sand2,
  colorNeutralBackgroundStatic: caldovaPaper.inkPanel,

  colorSubtleBackgroundHover:  caldovaPaper.paper2,
  colorSubtleBackgroundPressed: caldovaPaper.paper4,

  // --- ink & rules --------------------------------------------------------
  colorNeutralForeground1: caldovaPaper.ink,
  colorNeutralForeground2: caldovaNeutrals.n32,
  colorNeutralForeground3: caldovaNeutrals.n44,
  colorNeutralForeground4: caldovaNeutrals.n52,

  colorNeutralStroke1: caldovaPaper.rule,
  colorNeutralStroke2: caldovaPaper.hairline,
  colorNeutralStroke3: caldovaNeutrals.n92,
  colorNeutralStrokeAccessible: caldovaNeutrals.n44,
};

export const caldovaDarkTheme: Theme = {
  ...baseDark,
  ...fontOverrides(baseDark),
  ...shapeOverrides,

  colorNeutralBackground1: caldovaNeutrals.n8,
  colorNeutralBackground2: caldovaNeutrals.n12,
  colorNeutralBackground3: caldovaNeutrals.n16,
  colorNeutralBackground4: caldovaNeutrals.n20,

  colorNeutralForeground1: caldovaNeutrals.n96,
  colorNeutralForeground2: caldovaNeutrals.n88,
  colorNeutralForeground3: caldovaNeutrals.n76,

  colorNeutralStroke1: caldovaNeutrals.n28,
  colorNeutralStroke2: caldovaNeutrals.n24,

  /**
   * On dark, brand stop 80 only reaches 3.65:1 against ink — not enough for
   * body text. Fluent's dark theme already promotes the brand foreground up
   * the ramp; we pin it explicitly so nobody "fixes" it back to 80 later.
   */
  colorBrandForeground1: caldovaBrandRamp[100],
  colorBrandForeground2: caldovaBrandRamp[110],
  colorCompoundBrandForeground1: caldovaBrandRamp[100],
};

export const caldovaThemes = {
  light: caldovaLightTheme,
  dark: caldovaDarkTheme,
} as const;

export type CaldovaThemeName = keyof typeof caldovaThemes;
