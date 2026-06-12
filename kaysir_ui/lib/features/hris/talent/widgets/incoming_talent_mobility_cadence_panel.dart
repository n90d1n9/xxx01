import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_mobility_cadence_check_in_provider.dart';
import 'incoming_talent_mobility_cadence_form.dart';
import 'incoming_talent_mobility_cadence_tile.dart';

class IncomingTalentMobilityCadencePanel extends ConsumerWidget {
  const IncomingTalentMobilityCadencePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyOutcomes = ref.watch(
      cadenceReadyMobilityStabilizationOutcomesProvider,
    );
    final checkIns = ref.watch(
      filteredIncomingTalentMobilityCadenceCheckInsProvider,
    );
    final summary = ref.watch(
      incomingTalentMobilityCadenceCheckInSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.event_repeat_outlined,
      title: 'Mobility cadence check-ins',
      subtitle: summary.nextAction,
      emptyMessage: 'No mobility cadence check-ins',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyOutcomes.length}',
            ),
            HrisMetricStripItem(
              label: 'On track',
              value: '${summary.onTrackCount}',
            ),
            HrisMetricStripItem(label: 'Watch', value: '${summary.watchCount}'),
            HrisMetricStripItem(
              label: 'Avg',
              value: '${summary.averageHostConfidence.toStringAsFixed(1)}/5',
            ),
          ],
        ),
        const IncomingTalentMobilityCadenceForm(),
        if (checkIns.isEmpty)
          const HrisListSurface(
            child: Text('No mobility cadence check-ins yet.'),
          )
        else
          for (final checkIn in checkIns.take(3))
            IncomingTalentMobilityCadenceTile(checkIn: checkIn),
      ],
    );
  }
}
