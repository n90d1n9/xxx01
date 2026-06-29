import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_transition_pulse_provider.dart';
import 'incoming_talent_succession_transition_pulse_form.dart';
import 'incoming_talent_succession_transition_pulse_tile.dart';

class IncomingTalentSuccessionTransitionPulsePanel extends ConsumerWidget {
  const IncomingTalentSuccessionTransitionPulsePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyClosures = ref.watch(
      pulseReadySuccessionActivationClosuresProvider,
    );
    final pulses = ref.watch(
      filteredIncomingTalentSuccessionTransitionPulsesProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionTransitionPulseSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.monitor_heart_outlined,
      title: 'Transition pulses',
      subtitle: summary.nextAction,
      emptyMessage: 'No transition pulses',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyClosures.length}',
            ),
            HrisMetricStripItem(
              label: 'Stable',
              value: '${summary.thrivingCount + summary.stableCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value:
                  '${summary.watchCount + summary.interventionCount + summary.highRiskCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionTransitionPulseForm(),
        if (pulses.isEmpty)
          const HrisListSurface(child: Text('No transition pulses yet.'))
        else
          for (final pulse in pulses.take(3))
            IncomingTalentSuccessionTransitionPulseTile(pulse: pulse),
      ],
    );
  }
}
