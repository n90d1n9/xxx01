import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_risk_council_sla_provider.dart';
import '../states/talent_provider.dart';
import 'incoming_talent_risk_council_sla_tile.dart';

class IncomingTalentRiskCouncilSlaPanel extends ConsumerWidget {
  const IncomingTalentRiskCouncilSlaPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(incomingTalentRiskCouncilSlaItemsProvider);
    final summary = ref.watch(incomingTalentRiskCouncilSlaSummaryProvider);
    final asOfDate = ref.watch(talentAsOfDateProvider);

    return HrisSectionPanel(
      icon: Icons.timer_outlined,
      title: 'Talent risk SLA command center',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent risk SLA data',
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
              value: '${summary.waitingDecisionCount}',
            ),
          ],
        ),
        if (items.isEmpty)
          const HrisListSurface(child: Text('Talent risk SLAs are clear.'))
        else
          for (final item in items.take(4))
            IncomingTalentRiskCouncilSlaTile(item: item, asOfDate: asOfDate),
      ],
    );
  }
}
