import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_risk_council_commitment_owner_workload_provider.dart';
import 'incoming_talent_risk_council_commitment_owner_workload_tile.dart';

class IncomingTalentRiskCouncilCommitmentOwnerWorkloadPanel
    extends ConsumerWidget {
  const IncomingTalentRiskCouncilCommitmentOwnerWorkloadPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workloads = ref.watch(
      incomingTalentRiskCouncilCommitmentOwnerWorkloadItemsProvider,
    );
    final summary = ref.watch(
      incomingTalentRiskCouncilCommitmentOwnerWorkloadSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.groups_2_outlined,
      title: 'Council commitment owner workload',
      subtitle: summary.nextAction,
      emptyMessage: 'No council owner workload',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Owners',
              value: '${summary.ownerCount}',
            ),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalOwnerCount}',
            ),
            HrisMetricStripItem(
              label: 'Open',
              value: '${summary.openActionCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueActionCount}',
            ),
          ],
        ),
        if (workloads.isEmpty)
          const HrisListSurface(
            child: Text('No council commitment owner workload yet.'),
          )
        else
          for (final item in workloads.take(5))
            IncomingTalentRiskCouncilCommitmentOwnerWorkloadTile(item: item),
      ],
    );
  }
}
