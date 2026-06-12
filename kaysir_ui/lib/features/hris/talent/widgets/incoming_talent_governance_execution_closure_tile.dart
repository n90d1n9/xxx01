import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import 'talent_meta_label.dart';

/// Tile for one submitted governance execution closure.
class IncomingTalentGovernanceExecutionClosureTile extends StatelessWidget {
  final IncomingTalentGovernanceExecutionClosure closure;

  const IncomingTalentGovernanceExecutionClosureTile({
    super.key,
    required this.closure,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentGovernanceExecutionClosureOutcomeColor(
      closure.outcome,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_outcomeIcon(closure.outcome), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      closure.ownerName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      closure.actionType.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: closure.outcome.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            closure.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            closure.evidenceSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.fact_check_outlined,
                label: DateFormat('MMM d').format(closure.closureDate),
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label:
                    'Next ${DateFormat('MMM d').format(closure.nextReviewDate)}',
              ),
              TalentMetaLabel(
                icon: Icons.report_problem_outlined,
                label: '${closure.residualRiskCount} residual risks',
              ),
              TalentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label: '${closure.signalCount} signals',
              ),
              TalentMetaLabel(
                icon: Icons.gavel_outlined,
                label: '${closure.decisionCount} decisions',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentGovernanceExecutionClosureOutcomeColor(
  IncomingTalentGovernanceExecutionClosureOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentGovernanceExecutionClosureOutcome.completed => const Color(
      0xFF15803D,
    ),
    IncomingTalentGovernanceExecutionClosureOutcome.monitor => const Color(
      0xFFD97706,
    ),
    IncomingTalentGovernanceExecutionClosureOutcome.reopened => const Color(
      0xFFDC2626,
    ),
    IncomingTalentGovernanceExecutionClosureOutcome.escalated => const Color(
      0xFF7C3AED,
    ),
  };
}

IconData _outcomeIcon(IncomingTalentGovernanceExecutionClosureOutcome outcome) {
  return switch (outcome) {
    IncomingTalentGovernanceExecutionClosureOutcome.completed =>
      Icons.check_circle_outline,
    IncomingTalentGovernanceExecutionClosureOutcome.monitor =>
      Icons.visibility_outlined,
    IncomingTalentGovernanceExecutionClosureOutcome.reopened =>
      Icons.replay_outlined,
    IncomingTalentGovernanceExecutionClosureOutcome.escalated =>
      Icons.priority_high_outlined,
  };
}

@Preview(name: 'Talent governance execution closure tile')
Widget incomingTalentGovernanceExecutionClosureTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceExecutionClosureTile(
          closure: _previewClosure,
        ),
      ),
    ),
  );
}

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
