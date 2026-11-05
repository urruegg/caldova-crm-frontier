import * as React from 'react';
import { FluentProvider } from '@fluentui/react-components';
import { useCaldovaPcfTheme, type PowerAppsThemeContext } from './usePowerAppsTheme';

export interface CaldovaPcfProviderProps {
  context: PowerAppsThemeContext;
  /**
   * The element the control renders into. PCF controls render inside the host
   * document but Fluent v9 injects styles via Griffel — it MUST be told which
   * document owns the DOM or styles land in the wrong place when the control
   * is hosted in a dialog or a side pane.
   */
  targetDocument?: Document;
  children?: React.ReactNode;
}

/**
 * Root provider for a PCF control.
 *
 * Three things this handles that a bare <FluentProvider> does not:
 *
 * 1. `targetDocument` — required so Griffel injects into the host document.
 *    Without it, styling silently breaks inside dialogs and side panes.
 * 2. Host theme bridging with Caldova precedence (see usePowerAppsTheme).
 * 3. `applyStylesToPortals` — PCF controls that open menus, tooltips or
 *    dropdowns portal OUTSIDE the control's DOM subtree. Left at the default
 *    the portalled content renders unthemed. This is the single most common
 *    "why is my dropdown white and unbranded" bug in PCF + Fluent v9.
 */
export const CaldovaPcfProvider: React.FC<CaldovaPcfProviderProps> = ({
  context,
  targetDocument,
  children,
}) => {
  const theme = useCaldovaPcfTheme(context);
  return (
    <FluentProvider
      theme={theme}
      targetDocument={targetDocument}
      applyStylesToPortals
      style={{ background: 'transparent' }}
    >
      {children}
    </FluentProvider>
  );
};
