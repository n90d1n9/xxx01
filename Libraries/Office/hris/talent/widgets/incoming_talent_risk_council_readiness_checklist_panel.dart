import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_risk_council_readiness_checklist_provider.dart';
import 'incoming_talent_risk_council_readiness_checklist_tile.dart';

class IncomingTalentRiskCouncilReadinessChecklistPanel extends ConsumerWidget {
  const IncomingTalentRiskCouncilReadinessChecklistPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(
      incomingTalentRiskCouncilReadinessChecklistItemsProvider,
    );
    final summary = ref.watch(
      incomingTalentRiskCouncilReadinessChecklistSummaryProvider,
    );
    final color =
        summary.attentionCount == 0
            ? const Color(0xFF15803D)
            : summary.blockedCount > 0 || summary.overdueCount > 0
            ? const Color(0xFFDC2626)
            : HrisColors.primary;

    return HrisSectionPanel(
      icon: Icons.checklist_outlined,
      title: 'Talent risk council readiness',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent risk council readiness tasks',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Ready', value: '${summary.readyCount}'),
            HrisMetricStripItem(
              label: 'Prep',
              value: '${summary.needsPrepCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: HrisProgressBar(
            value: summary.readinessRatio,
            color: color,
            label:
                '${(summary.readinessRatio * 100).round()}% council prep ready',
          ),
        ),
        for (final item in items.take(5))
          IncomingTalentRiskCouncilReadinessChecklistTile(item: item),
      ],
    );
  }
}
