import * as React from 'react';
import { makeStyles, tokens } from '@fluentui/react-components';
import { CaldovaSurface } from './CaldovaSurface';
import { caldovaTypography } from '../tokens/typography';

const useStyles = makeStyles({
  value: {
    fontSize: caldovaTypography.title1.fontSize,
    lineHeight: caldovaTypography.title1.lineHeight,
    fontWeight: 700,
    color: tokens.colorNeutralForeground1,
    display: 'block',
  },
  caption: {
    fontSize: '12px', lineHeight: '16px',
    color: tokens.colorNeutralForeground3,
    display: 'block', marginBlockStart: '4px',
  },
  delta: { fontSize: '12px', fontWeight: 700, marginInlineStart: '8px' },
});

export interface KpiTileProps {
  label: string;
  value: string | number;
  caption?: string;
  /** Signed change; rendered green when positive, danger red when negative. */
  delta?: number;
  deltaSuffix?: string;
}

export const KpiTile: React.FC<KpiTileProps> = ({
  label, value, caption, delta, deltaSuffix = '%',
}) => {
  const s = useStyles();
  return (
    <CaldovaSurface kicker={label} rule="top" tone="paper">
      <span className={s.value}>
        {value}
        {typeof delta === 'number' && (
          <span
            className={s.delta}
            style={{ color: delta >= 0 ? '#0E6C41' : '#A4262C' }}
          >
            {delta >= 0 ? '▲' : '▼'} {Math.abs(delta)}{deltaSuffix}
          </span>
        )}
      </span>
      {caption && <span className={s.caption}>{caption}</span>}
    </CaldovaSurface>
  );
};
