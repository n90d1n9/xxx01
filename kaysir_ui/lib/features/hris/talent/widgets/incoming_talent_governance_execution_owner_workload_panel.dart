import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import '../states/incoming_talent_governance_execution_owner_workload_provider.dart';
import 'incoming_talent_governance_execution_owner_workload_tile.dart';
import 'talent_meta_label.dart';

/// Owner workload heatmap for talent governance execution follow-through.
class IncomingTalentGovernanceExecutionOwnerWorkloadPanel
    extends ConsumerWidget {
  const IncomingTalentGovernanceExecutionOwnerWorkloadPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(
      incomingTalentGovernanceExecutionOwnerWorkloadItemsProvider,
    );
    final summary = ref.watch(
      incomingTalentGovernanceExecutionOwnerWorkloadSummaryProvider,
    );
    final color = incomingTalentGovernanceExecutionOwnerWorkloadSummaryColor(
      summary,
    );

    return HrisSectionPanel(
      icon: Icons.groups_2_outlined,
      title: 'Talent governance owner workload',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent governance owner workload',
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
              label: 'Actions',
              value: '${summary.actionCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueActionCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisProgressBar(
                value: summary.averageProgressRatio,
                color: color,
                label:
                    '${(summary.averageProgressRatio * 100).round()}% owner progress',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TalentMetaLabel(
                    icon: Icons.speed_outlined,
                    label:
                        '${summary.stretchedOwnerCount} stretched ${_plural(summary.stretchedOwnerCount, 'owner')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.warning_amber_outlined,
                    label:
                        '${summary.signalCount} active ${_plural(summary.signalCount, 'signal')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.gavel_outlined,
                    label:
                        '${summary.decisionCount} governance ${_plural(summary.decisionCount, 'decision')}',
                  ),
                ],
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          const HrisListSurface(
            child: Text('No active governance execution owner workload.'),
          )
        else
          for (final item in items.take(5))
            IncomingTalentGovernanceExecutionOwnerWorkloadTile(item: item),
      ],
    );
  }
}

Color incomingTalentGovernanceExecutionOwnerWorkloadSummaryColor(
  IncomingTalentGovernanceExecutionOwnerWorkloadSummary summary,
) {
  if (summary.criticalOwnerCount > 0 || summary.overdueActionCount > 0) {
    return const Color(0xFFDC2626);
  }
  if (summary.stretchedOwnerCount > 0 || summary.highActionCount > 0) {
    return const Color(0xFFD97706);
  }
  return const Color(0xFF059669);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance execution owner workload panel')
Widget incomingTalentGovernanceExecutionOwnerWorkloadPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentGovernanceExecutionOwnerWorkloadItemsProvider
          .overrideWithValue(_previewItems),
      incomingTalentGovernanceExecutionOwnerWorkloadSummaryProvider
          .overrideWithValue(
            IncomingTalentGovernanceExecutionOwnerWorkloadSummary.fromItems(
              _previewItems,
            ),
          ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentGovernanceExecutionOwnerWorkloadPanel(),
        ),
      ),
    ),
  );
}

final _previewItems = [
  IncomingTalentGovernanceExecutionOwnerWorkloadItem(
    ownerName: 'People Risk and Assurance',
    load: IncomingTalentGovernanceExecutionOwnerLoad.critical,
    actionCount: 2,
    criticalActionCount: 1,
    highActionCount: 1,
    standardActionCount: 0,
    overdueActionCount: 1,
    signalCount: 9,
    decisionCount: 6,
    readinessTaskCount: 2,
    earliestDueDate: DateTime(2026, 6, 11),
    averageProgressRatio: 0.25,
    nextAction:
        'Rebalance 1 overdue governance execution action from People Risk and Assurance.',
    actionIds: const [
      'talent-governance-execution-action:assurance',
      'talent-governance-execution-action:evidence',
    ],
  ),
  IncomingTalentGovernanceExecutionOwnerWorkloadItem(
    ownerName: 'Talent Operations',
    load: IncomingTalentGovernanceExecutionOwnerLoad.stretched,
    actionCount: 1,
    criticalActionCount: 0,
    highActionCount: 1,
    standardActionCount: 0,
    overdueActionCount: 0,
    signalCount: 3,
    decisionCount: 3,
    readinessTaskCount: 1,
    earliestDueDate: DateTime(2026, 6, 14),
    averageProgressRatio: 0.45,
    nextAction:
        'Support Talent Operations on 1 high-priority governance execution action.',
    actionIds: const ['talent-governance-execution-action:action-sla'],
  ),
];
