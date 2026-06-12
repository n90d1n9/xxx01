import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_bench_check_in_provider.dart';
import 'incoming_talent_succession_bench_check_in_form.dart';
import 'incoming_talent_succession_bench_check_in_tile.dart';

class IncomingTalentSuccessionBenchCheckInPanel extends ConsumerWidget {
  const IncomingTalentSuccessionBenchCheckInPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyPlans = ref.watch(
      checkInReadySuccessionBenchReplenishmentsProvider,
    );
    final checkIns = ref.watch(
      filteredIncomingTalentSuccessionBenchCheckInsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionBenchCheckInSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.monitor_heart_outlined,
      title: 'Bench check-ins',
      subtitle: summary.nextAction,
      emptyMessage: 'No bench check-ins',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Ready', value: '${readyPlans.length}'),
            HrisMetricStripItem(
              label: 'On track',
              value: '${summary.onTrackCount}',
            ),
            HrisMetricStripItem(
              label: 'Attention',
              value: '${summary.attentionCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionBenchCheckInForm(),
        if (checkIns.isEmpty)
          const HrisListSurface(child: Text('No bench check-ins yet.'))
        else
          for (final checkIn in checkIns.take(3))
            IncomingTalentSuccessionBenchCheckInTile(checkIn: checkIn),
      ],
    );
  }
}
