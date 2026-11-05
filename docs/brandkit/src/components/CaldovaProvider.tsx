import * as React from 'react';
import { FluentProvider, type Theme } from '@fluentui/react-components';
import { caldovaLightTheme, caldovaDarkTheme } from '../theme';

export interface CaldovaProviderProps {
  /** 'light' | 'dark' | 'auto' (follows prefers-color-scheme). Default 'light'. */
  mode?: 'light' | 'dark' | 'auto';
  /**
   * Host-supplied theme to merge over the Caldova theme. Used by the PCF
   * bridge to inherit the Power Apps environment theme — see pcf/.
   */
  overrides?: Partial<Theme>;
  /** Render into a specific document (PCF/iframe scenarios). */
  targetDocument?: Document;
  className?: string;
  children?: React.ReactNode;
}

function usePrefersDark(enabled: boolean): boolean {
  const [dark, setDark] = React.useState(false);
  React.useEffect(() => {
    if (!enabled || typeof window === 'undefined' || !window.matchMedia) return;
    const mq = window.matchMedia('(prefers-color-scheme: dark)');
    const apply = () => setDark(mq.matches);
    apply();
    mq.addEventListener('change', apply);
    return () => mq.removeEventListener('change', apply);
  }, [enabled]);
  return dark;
}

/**
 * Root provider for any Caldova React surface.
 *
 * Wrap the app once. Every Fluent component below it picks up the brand ramp,
 * the warm surfaces, the font stack and the flat shape language.
 */
export const CaldovaProvider: React.FC<CaldovaProviderProps> = ({
  mode = 'light',
  overrides,
  targetDocument,
  className,
  children,
}) => {
  const prefersDark = usePrefersDark(mode === 'auto');
  const isDark = mode === 'dark' || (mode === 'auto' && prefersDark);

  const theme = React.useMemo<Theme>(() => {
    const base = isDark ? caldovaDarkTheme : caldovaLightTheme;
    return overrides ? { ...base, ...overrides } : base;
  }, [isDark, overrides]);

  return (
    <FluentProvider
      theme={theme}
      targetDocument={targetDocument}
      className={className}
    >
      {children}
    </FluentProvider>
  );
};
