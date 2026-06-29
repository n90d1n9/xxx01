import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_risk_council_commitment_log_provider.dart';
import 'incoming_talent_risk_council_commitment_log_tile.dart';

class IncomingTalentRiskCouncilCommitmentLogPanel extends ConsumerWidget {
  const IncomingTalentRiskCouncilCommitmentLogPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(
      incomingTalentRiskCouncilCommitmentLogItemsProvider,
    );
    final summary = ref.watch(
      incomingTalentRiskCouncilCommitmentLogSummaryProvider,
    );
    final color =
        summary.attentionCount == 0
            ? const Color(0xFF15803D)
            : summary.blockedCount > 0 || summary.needsDecisionCount > 0
            ? const Color(0xFFDC2626)
            : HrisColors.primary;

    return HrisSectionPanel(
      icon: Icons.assignment_turned_in_outlined,
      title: 'Talent risk council commitment log',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent risk council commitments',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Log', value: '${summary.totalCount}'),
            HrisMetricStripItem(
              label: 'Decision',
              value: '${summary.needsDecisionCount}',
            ),
            HrisMetricStripItem(
              label: 'Owner',
              value: '${summary.needsOwnerCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: HrisProgressBar(
            value: summary.publishableRatio,
            color: color,
            label: '${(summary.publishableRatio * 100).round()}% publish-ready',
          ),
        ),
        for (final item in items.take(5))
          IncomingTalentRiskCouncilCommitmentLogTile(item: item),
      ],
    );
  }
}
