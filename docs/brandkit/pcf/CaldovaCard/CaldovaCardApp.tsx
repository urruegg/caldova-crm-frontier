import * as React from 'react';
import { Button, makeStyles, tokens } from '@fluentui/react-components';
import { CaldovaPcfProvider } from '../CaldovaPcfProvider';
import { CaldovaSurface } from '../../src/components/CaldovaSurface';
import { StatusBadge, type CaldovaStatus } from '../../src/components/StatusBadge';

const useStyles = makeStyles({
  head:  { display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px' },
  value: { fontSize: '28px', lineHeight: '34px', fontWeight: 700,
           color: tokens.colorNeutralForeground1, display: 'block', marginBlockStart: '8px' },
  caption: { fontSize: '12px', lineHeight: '16px',
             color: tokens.colorNeutralForeground3, display: 'block', marginBlockStart: '4px' },
  actions: { marginBlockStart: '14px' },
});

export interface CaldovaCardAppProps {
  context: any;
  title: string;
  value: string;
  caption?: string;
  status: CaldovaStatus;
  acknowledged: boolean;
  onAcknowledge: () => void;
}

export const CaldovaCardApp: React.FC<CaldovaCardAppProps> = (p) => {
  const s = useStyles();
  return (
    <CaldovaPcfProvider
      context={p.context}
      targetDocument={
        // PCF gives no direct document handle; derive it from the host window.
        typeof window !== 'undefined' ? window.document : undefined
      }
    >
      <CaldovaSurface kicker={p.title} rule="top" tone="paper">
        <div className={s.head}>
          <span className={s.value}>{p.value}</span>
          <StatusBadge status={p.status}>{p.status}</StatusBadge>
        </div>
        {p.caption && <span className={s.caption}>{p.caption}</span>}
        <div className={s.actions}>
          <Button
            appearance={p.acknowledged ? 'secondary' : 'primary'}
            onClick={p.onAcknowledge}
          >
            {p.acknowledged ? 'Zur Kenntnis genommen' : 'Zur Kenntnis nehmen'}
          </Button>
        </div>
      </CaldovaSurface>
    </CaldovaPcfProvider>
  );
};
