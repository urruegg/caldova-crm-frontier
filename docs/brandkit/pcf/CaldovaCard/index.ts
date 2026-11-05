import { IInputs, IOutputs } from './generated/ManifestTypes';
import * as React from 'react';
import { CaldovaCardApp, type CaldovaCardAppProps } from './CaldovaCardApp';

/**
 * Sample PCF control wired to the Caldova brand kit.
 *
 * Uses the VIRTUAL control model (`platform-library` React + Fluent in the
 * manifest). Virtual controls share the host's React and Fluent instances,
 * which keeps the bundle small and — importantly — avoids two copies of
 * Fluent's style engine fighting over the same document.
 */
export class CaldovaCard
  implements ComponentFramework.ReactControl<IInputs, IOutputs>
{
  private notifyOutputChanged!: () => void;
  private acknowledged = false;

  public init(
    context: ComponentFramework.Context<IInputs>,
    notifyOutputChanged: () => void,
  ): void {
    this.notifyOutputChanged = notifyOutputChanged;
    // Ask the host to re-render us when the container is resized.
    context.mode.trackContainerResize(true);
  }

  public updateView(
    context: ComponentFramework.Context<IInputs>,
  ): React.ReactElement {
    const props: CaldovaCardAppProps = {
      context,
      title: context.parameters.title.raw ?? '',
      value: context.parameters.value.raw ?? '',
      caption: context.parameters.caption.raw ?? undefined,
      status: (context.parameters.status.raw as CaldovaCardAppProps['status']) ?? 'active',
      acknowledged: this.acknowledged,
      onAcknowledge: () => {
        this.acknowledged = !this.acknowledged;
        this.notifyOutputChanged();
      },
    };
    return React.createElement(CaldovaCardApp, props);
  }

  public getOutputs(): IOutputs {
    return { acknowledged: this.acknowledged };
  }

  public destroy(): void {
    // React unmount is handled by the platform for React controls.
  }
}
