import * as React from 'react';
import type { Theme } from '@fluentui/react-components';
import { caldovaLightTheme, caldovaDarkTheme } from '../src/theme';

/**
 * Bridge the Power Apps host theme into the Caldova Fluent theme.
 *
 * Model-driven apps expose the maker-configured theme on
 * `context.fluentDesignLanguage` (Fluent v9 shape) when the control opts in
 * via `<feature-usage><uses-feature name="Utility" required="true" /></feature-usage>`
 * and the app is running a version that supports it. It is NOT guaranteed to
 * be present — canvas apps, older hosts, and the test harness all omit it.
 * Treat it as optional every single time.
 *
 * Precedence we apply, deliberately:
 *   Caldova brand  >  host theme  >  Fluent defaults
 *
 * Rationale: the CRM surfaces are Caldova-branded product surfaces, so the
 * brand ramp and warm paper must win. We inherit only what is genuinely
 * host-owned and must not be overridden — dark/light mode and the host's
 * font size scaling for accessibility.
 */

export interface PowerAppsThemeContext {
  fluentDesignLanguage?: {
    tokenTheme?: Partial<Theme> & { colorNeutralBackground1?: string };
    isDarkTheme?: boolean;
  };
  // Present on all PCF contexts
  userSettings?: {
    // 1 = default. Users can scale text in personalization settings.
    [k: string]: unknown;
  };
}

function hostPrefersDark(ctx?: PowerAppsThemeContext): boolean {
  const dl = ctx?.fluentDesignLanguage;
  if (!dl) return false;
  if (typeof dl.isDarkTheme === 'boolean') return dl.isDarkTheme;
  // Fallback: infer from the host's base surface luminance.
  const bg = dl.tokenTheme?.colorNeutralBackground1;
  if (typeof bg === 'string' && /^#[0-9a-f]{6}$/i.test(bg)) {
    const r = parseInt(bg.slice(1, 3), 16);
    const g = parseInt(bg.slice(3, 5), 16);
    const b = parseInt(bg.slice(5, 7), 16);
    return (0.2126 * r + 0.7152 * g + 0.0722 * b) < 128;
  }
  return false;
}

export function useCaldovaPcfTheme(ctx?: PowerAppsThemeContext): Theme {
  return React.useMemo(() => {
    const dark = hostPrefersDark(ctx);
    const base = dark ? caldovaDarkTheme : caldovaLightTheme;
    const host = ctx?.fluentDesignLanguage?.tokenTheme;
    if (!host) return base;

    // Inherit ONLY host-owned accessibility concerns. Everything visual stays
    // Caldova — otherwise a maker's theme silently unbrands the control.
    const inherited: Partial<Theme> = {};
    const passthrough: (keyof Theme)[] = [
      'fontSizeBase100', 'fontSizeBase200', 'fontSizeBase300',
      'fontSizeBase400', 'fontSizeBase500', 'fontSizeBase600',
      'lineHeightBase100', 'lineHeightBase200', 'lineHeightBase300',
      'lineHeightBase400', 'lineHeightBase500', 'lineHeightBase600',
    ];
    for (const k of passthrough) {
      const v = (host as Record<string, unknown>)[k as string];
      if (typeof v === 'string') (inherited as Record<string, unknown>)[k as string] = v;
    }
    return { ...base, ...inherited };
  }, [ctx?.fluentDesignLanguage]);
}
