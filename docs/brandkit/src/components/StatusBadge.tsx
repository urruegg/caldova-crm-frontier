import * as React from 'react';
import { makeStyles, mergeClasses, tokens } from '@fluentui/react-components';
import { caldovaSemantic } from '../tokens/semantic';

const useStyles = makeStyles({
  root: {
    display: 'inline-flex', alignItems: 'center', gap: '6px',
    paddingInline: '8px', paddingBlock: '3px',
    borderRadius: tokens.borderRadiusSmall,
    fontSize: '11px', fontWeight: 700,
    letterSpacing: '0.04em', textTransform: 'uppercase',
    border: '1px solid transparent',
  },
  dot: { inlineSize: '6px', blockSize: '6px', borderRadius: '50%' },
});

export type CaldovaStatus =
  | 'active' | 'pending' | 'lapsed' | 'open' | 'closed' | 'brand';

const MAP: Record<CaldovaStatus, { fg: string; bg: string }> = {
  active:  { fg: caldovaSemantic.success, bg: caldovaSemantic.successBg },
  pending: { fg: caldovaSemantic.warning, bg: caldovaSemantic.warningBg },
  lapsed:  { fg: caldovaSemantic.danger,  bg: caldovaSemantic.dangerBg },
  open:    { fg: caldovaSemantic.info,    bg: caldovaSemantic.infoBg },
  closed:  { fg: '#484445',                bg: '#F4F3F0' },
  brand:   { fg: '#FFFFFF',                bg: caldovaSemantic.brand },
};

export interface StatusBadgeProps {
  status: CaldovaStatus;
  children: React.ReactNode;
  className?: string;
}

/**
 * Status pill. Note the deliberate separation: brand red is reserved for the
 * `brand` variant only. A "lapsed" policy uses the darker danger red so an
 * error can never be mistaken for an accent.
 */
export const StatusBadge: React.FC<StatusBadgeProps> = ({ status, children, className }) => {
  const s = useStyles();
  const c = MAP[status];
  return (
    <span
      className={mergeClasses(s.root, className)}
      style={{ color: c.fg, backgroundColor: c.bg, borderColor: c.bg }}
    >
      {status !== 'brand' && (
        <span className={s.dot} style={{ backgroundColor: c.fg }} aria-hidden />
      )}
      {children}
    </span>
  );
};
