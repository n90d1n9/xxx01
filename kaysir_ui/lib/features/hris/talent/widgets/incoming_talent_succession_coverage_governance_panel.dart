import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_coverage_governance_provider.dart';
import 'incoming_talent_succession_coverage_governance_tile.dart';

class IncomingTalentSuccessionCoverageGovernancePanel extends ConsumerWidget {
  const IncomingTalentSuccessionCoverageGovernancePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(
      filteredIncomingTalentSuccessionCoverageGovernanceRecordsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionCoverageGovernanceSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.policy_outlined,
      title: 'Coverage governance',
      subtitle: summary.nextAction,
      emptyMessage: 'No coverage governance records',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Open', value: '${summary.openRecords}'),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalCount}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
          ],
        ),
        if (records.isEmpty)
          const HrisListSurface(
            child: Text('Coverage reviews will appear here for governance.'),
          )
        else
          for (final record in records.take(4))
            IncomingTalentSuccessionCoverageGovernanceTile(record: record),
      ],
    );
  }
}
