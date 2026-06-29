import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_coverage_sla_provider.dart';
import '../states/talent_provider.dart';
import 'incoming_talent_succession_coverage_sla_tile.dart';

class IncomingTalentSuccessionCoverageSlaPanel extends ConsumerWidget {
  const IncomingTalentSuccessionCoverageSlaPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(incomingTalentSuccessionCoverageSlaItemsProvider);
    final summary = ref.watch(
      incomingTalentSuccessionCoverageSlaSummaryProvider,
    );
    final asOfDate = ref.watch(talentAsOfDateProvider);

    return HrisSectionPanel(
      icon: Icons.timer_outlined,
      title: 'Coverage SLA command center',
      subtitle: summary.nextAction,
      emptyMessage: 'No coverage SLA data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueCount}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Council',
              value: '${summary.waitingCouncilCount}',
            ),
          ],
        ),
        if (items.isEmpty)
          const HrisListSurface(
            child: Text('Succession coverage SLAs are clear.'),
          )
        else
          for (final item in items.take(4))
            IncomingTalentSuccessionCoverageSlaTile(
              item: item,
              asOfDate: asOfDate,
            ),
      ],
    );
  }
}
