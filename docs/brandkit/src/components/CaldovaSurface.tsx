import * as React from 'react';
import { makeStyles, mergeClasses, tokens } from '@fluentui/react-components';
import { caldovaShape } from '../tokens/shape';
import { caldovaTypography } from '../tokens/typography';

const useStyles = makeStyles({
  root: {
    position: 'relative',
    backgroundColor: tokens.colorNeutralBackground1,
    border: `1px solid ${tokens.colorNeutralStroke2}`,
    borderRadius: tokens.borderRadiusMedium,
    padding: '16px 20px',
  },
  sand:  { backgroundColor: tokens.colorNeutralBackground5 },
  paper: { backgroundColor: tokens.colorNeutralBackground2 },
  ink: {
    backgroundColor: tokens.colorNeutralBackgroundStatic,
    color: tokens.colorNeutralForegroundStaticInverted,
    border: '1px solid transparent',
  },
  /** the signature Caldova device: a brand rule on the leading edge */
  ruleTop: {
    '::before': {
      content: '""', position: 'absolute', insetInlineStart: 0, insetBlockStart: 0,
      inlineSize: '100%', blockSize: caldovaShape.accentRule,
      backgroundColor: tokens.colorBrandBackground,
    },
  },
  ruleStart: {
    '::before': {
      content: '""', position: 'absolute', insetInlineStart: 0, insetBlockStart: 0,
      inlineSize: caldovaShape.accentRule, blockSize: '100%',
      backgroundColor: tokens.colorBrandBackground,
    },
  },
  kicker: {
    ...caldovaTypography.kicker,
    color: tokens.colorBrandForeground1,
    display: 'block',
    marginBlockEnd: '10px',
  },
});

export interface CaldovaSurfaceProps
  extends React.HTMLAttributes<HTMLDivElement> {
  /** Surface tone. Default 'default'. */
  tone?: 'default' | 'paper' | 'sand' | 'ink';
  /** Where the brand accent rule sits. Default 'top'. */
  rule?: 'top' | 'start' | 'none';
  /** Letter-spaced uppercase eyebrow label. */
  kicker?: string;
}

/**
 * The base panel of the Caldova design language: a warm surface, a hairline
 * border, a brand accent rule on the leading edge, and an optional uppercase
 * kicker. Everything in the CRM surfaces is built from this.
 */
export const CaldovaSurface = React.forwardRef<HTMLDivElement, CaldovaSurfaceProps>(
  ({ tone = 'default', rule = 'top', kicker, className, children, ...rest }, ref) => {
    const s = useStyles();
    return (
      <div
        ref={ref}
        className={mergeClasses(
          s.root,
          tone === 'paper' && s.paper,
          tone === 'sand' && s.sand,
          tone === 'ink' && s.ink,
          rule === 'top' && s.ruleTop,
          rule === 'start' && s.ruleStart,
          className,
        )}
        {...rest}
      >
        {kicker && <span className={s.kicker}>{kicker}</span>}
        {children}
      </div>
    );
  },
);
CaldovaSurface.displayName = 'CaldovaSurface';
