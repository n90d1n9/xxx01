import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import '../states/incoming_talent_governance_execution_closure_provider.dart';
import 'incoming_talent_governance_execution_closure_form.dart';
import 'incoming_talent_governance_execution_closure_tile.dart';

/// Panel for submitting and reviewing governance execution closures.
class IncomingTalentGovernanceExecutionClosurePanel extends ConsumerWidget {
  const IncomingTalentGovernanceExecutionClosurePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyActions = ref.watch(
      closureReadyTalentGovernanceExecutionActionsProvider,
    );
    final closures = ref.watch(
      incomingTalentGovernanceExecutionClosuresProvider,
    );
    final summary = ref.watch(
      incomingTalentGovernanceExecutionClosureSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Talent governance closure reviews',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent governance closure data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyActions.length}',
            ),
            HrisMetricStripItem(
              label: 'Closed',
              value: '${summary.totalCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value:
                  '${summary.monitorCount + summary.reopenedCount + summary.escalatedCount}',
            ),
            HrisMetricStripItem(
              label: 'Risk',
              value: '${summary.residualRiskCount}',
            ),
          ],
        ),
        const IncomingTalentGovernanceExecutionClosureForm(),
        if (closures.isEmpty)
          const HrisListSurface(
            child: Text('No governance execution closure reviews yet.'),
          )
        else
          for (final closure in closures.take(3))
            IncomingTalentGovernanceExecutionClosureTile(closure: closure),
      ],
    );
  }
}

@Preview(name: 'Talent governance execution closure panel')
Widget incomingTalentGovernanceExecutionClosurePanelPreview() {
  final readyActions = [_previewAction];
  final closures = [_previewClosure];

  return ProviderScope(
    overrides: [
      closureReadyTalentGovernanceExecutionActionsProvider.overrideWithValue(
        readyActions,
      ),
      incomingTalentGovernanceExecutionClosuresProvider.overrideWith(
        (_) => _PreviewClosuresNotifier(closures),
      ),
      incomingTalentGovernanceExecutionClosureSummaryProvider.overrideWithValue(
        IncomingTalentGovernanceExecutionClosureSummary.fromClosures(closures),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentGovernanceExecutionClosurePanel(),
        ),
      ),
    ),
  );
}

class _PreviewClosuresNotifier
    extends IncomingTalentGovernanceExecutionClosuresNotifier {
  _PreviewClosuresNotifier(
    List<IncomingTalentGovernanceExecutionClosure> items,
  ) {
    state = items;
  }
}

final _previewAction = IncomingTalentGovernanceExecutionAction(
  id: 'talent-governance-execution-action-preview',
  trackId: 'talent-governance-execution-preview',
  type: IncomingTalentGovernanceExecutionActionType.recoverOverdue,
  priority: IncomingTalentGovernanceExecutionActionPriority.critical,
  title: 'People Risk and Assurance - recover overdue',
  detail: 'Execute assurance approval decision',
  nextAction:
      'Ask People Risk and Assurance to recover overdue follow-through for execute assurance approval decision.',
  playbook:
      'Reconfirm due date, capture recovery evidence, and mark owner acceptance.',
  evidenceExpectation:
      'Attach assurance approval evidence, owner confirmation, and recovery note.',
  ownerName: 'People Risk and Assurance',
  dueDate: DateTime(2026, 6, 11),
  progressRatio: 0.1,
  signalCount: 5,
  decisionCount: 3,
  readinessTaskCount: 1,
  overdue: true,
);

final _previewClosure = IncomingTalentGovernanceExecutionClosure(
  id: 'talent-governance-execution-closure-001',
  actionId: 'talent-governance-execution-action-preview',
  trackId: 'talent-governance-execution-preview',
  ownerName: 'People Risk and Assurance',
  reviewerName: 'People Risk and Assurance',
  actionType: IncomingTalentGovernanceExecutionActionType.recoverOverdue,
  actionPriority: IncomingTalentGovernanceExecutionActionPriority.critical,
  actionDueDate: DateTime(2026, 6, 11),
  closureDate: DateTime(2026, 6, 12),
  outcome: IncomingTalentGovernanceExecutionClosureOutcome.monitor,
  residualRiskCount: 1,
  evidenceSummary:
      'Closure evidence confirms assurance approval follow-through is attached.',
  ownerConfirmationNote:
      'Owner confirms recovery evidence and governance cadence.',
  nextAction: 'Monitor closure evidence in the next governance check-in.',
  nextReviewDate: DateTime(2026, 6, 26),
  signalCount: 5,
  decisionCount: 3,
  createdAt: DateTime(2026, 6, 12),
);
