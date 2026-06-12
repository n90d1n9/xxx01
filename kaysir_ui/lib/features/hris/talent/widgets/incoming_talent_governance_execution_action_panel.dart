import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import '../states/incoming_talent_governance_execution_action_provider.dart';
import 'incoming_talent_governance_execution_action_tile.dart';
import 'talent_meta_label.dart';

/// Action board for owner-ready talent governance execution follow-through.
class IncomingTalentGovernanceExecutionActionPanel extends ConsumerWidget {
  const IncomingTalentGovernanceExecutionActionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(incomingTalentGovernanceExecutionActionsProvider);
    final summary = ref.watch(
      incomingTalentGovernanceExecutionActionSummaryProvider,
    );
    final color = incomingTalentGovernanceExecutionActionSummaryColor(summary);

    return HrisSectionPanel(
      icon: Icons.playlist_add_check_circle_outlined,
      title: 'Talent governance action board',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent governance execution actions',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Actions',
              value: '${summary.actionCount}',
            ),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalActionCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueActionCount}',
            ),
            HrisMetricStripItem(
              label: 'Owners',
              value: '${summary.ownerCount}',
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
                    '${(summary.averageProgressRatio * 100).round()}% average execution progress',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TalentMetaLabel(
                    icon: Icons.priority_high_outlined,
                    label:
                        '${summary.highActionCount} high-priority ${_plural(summary.highActionCount, 'action')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.gavel_outlined,
                    label:
                        '${summary.decisionCount} governance ${_plural(summary.decisionCount, 'decision')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.warning_amber_outlined,
                    label:
                        '${summary.signalCount} active ${_plural(summary.signalCount, 'signal')}',
                  ),
                ],
              ),
            ],
          ),
        ),
        if (actions.isEmpty)
          const HrisListSurface(
            child: Text('No active governance execution actions.'),
          )
        else
          for (final action in actions.take(5))
            IncomingTalentGovernanceExecutionActionTile(action: action),
      ],
    );
  }
}

Color incomingTalentGovernanceExecutionActionSummaryColor(
  IncomingTalentGovernanceExecutionActionSummary summary,
) {
  if (summary.criticalActionCount > 0 || summary.overdueActionCount > 0) {
    return const Color(0xFFDC2626);
  }
  if (summary.highActionCount > 0) {
    return const Color(0xFFD97706);
  }
  return const Color(0xFF059669);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance execution action panel')
Widget incomingTalentGovernanceExecutionActionPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentGovernanceExecutionActionsProvider.overrideWithValue(
        _previewActions,
      ),
      incomingTalentGovernanceExecutionActionSummaryProvider.overrideWithValue(
        IncomingTalentGovernanceExecutionActionSummary.fromActions(
          _previewActions,
        ),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentGovernanceExecutionActionPanel(),
        ),
      ),
    ),
  );
}

final _previewActions = [
  IncomingTalentGovernanceExecutionAction(
    id:
        'talent-governance-execution-action:talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-assurance',
    trackId:
        'talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-assurance',
    type: IncomingTalentGovernanceExecutionActionType.recoverOverdue,
    priority: IncomingTalentGovernanceExecutionActionPriority.critical,
    title: 'People Risk and Assurance - recover overdue',
    detail: 'Execute assurance approval decision',
    nextAction:
        'Ask People Risk and Assurance to recover overdue follow-through for execute assurance approval decision.',
    playbook:
        'Reconfirm due date, capture recovery evidence, and mark owner acceptance.',
    evidenceExpectation:
        'Approve immediate intervention for assurance: Unblock 1 assurance remediation execution track. Evidence: Gaps 4 with 5 active signals.',
    ownerName: 'People Risk and Assurance',
    dueDate: DateTime(2026, 6, 11),
    progressRatio: 0.1,
    signalCount: 5,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: true,
  ),
  IncomingTalentGovernanceExecutionAction(
    id:
        'talent-governance-execution-action:talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-action-sla',
    trackId:
        'talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-action-sla',
    type: IncomingTalentGovernanceExecutionActionType.attachEvidence,
    priority: IncomingTalentGovernanceExecutionActionPriority.high,
    title: 'Talent Operations - attach evidence',
    detail: 'Execute action SLA unblock decision',
    nextAction:
        'Ask Talent Operations to attach execution evidence for execute action SLA unblock decision.',
    playbook:
        'Attach evidence, refresh notes, and make the audit trail reviewable.',
    evidenceExpectation:
        'Keep action SLA on weekly governance watch and confirm the accountable owner. Evidence: SLAs 8 with 3 active signals.',
    ownerName: 'Talent Operations',
    dueDate: DateTime(2026, 6, 14),
    progressRatio: 0.45,
    signalCount: 3,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: false,
  ),
];
