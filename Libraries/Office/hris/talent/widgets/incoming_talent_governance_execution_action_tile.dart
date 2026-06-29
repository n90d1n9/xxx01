import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import 'talent_meta_label.dart';

/// Tile for one owner-ready talent governance execution action.
class IncomingTalentGovernanceExecutionActionTile extends StatelessWidget {
  final IncomingTalentGovernanceExecutionAction action;

  const IncomingTalentGovernanceExecutionActionTile({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentGovernanceExecutionActionPriorityColor(
      action.priority,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_typeIcon(action.type), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      action.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: action.priority.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: action.normalizedProgressRatio,
            color: color,
            label:
                '${(action.normalizedProgressRatio * 100).round()}% track progress',
          ),
          const SizedBox(height: 10),
          Text(
            action.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            action.playbook,
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
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(action.dueDate),
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: action.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label:
                    '${action.signalCount} ${_plural(action.signalCount, 'signal')}',
              ),
              TalentMetaLabel(
                icon: Icons.gavel_outlined,
                label:
                    '${action.decisionCount} ${_plural(action.decisionCount, 'decision')}',
              ),
              TalentMetaLabel(
                icon: Icons.checklist_outlined,
                label:
                    '${action.readinessTaskCount} prep ${_plural(action.readinessTaskCount, 'task')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentGovernanceExecutionActionPriorityColor(
  IncomingTalentGovernanceExecutionActionPriority priority,
) {
  return switch (priority) {
    IncomingTalentGovernanceExecutionActionPriority.critical => const Color(
      0xFFDC2626,
    ),
    IncomingTalentGovernanceExecutionActionPriority.high => const Color(
      0xFFD97706,
    ),
    IncomingTalentGovernanceExecutionActionPriority.standard => const Color(
      0xFF2563EB,
    ),
  };
}

IconData _typeIcon(IncomingTalentGovernanceExecutionActionType type) {
  return switch (type) {
    IncomingTalentGovernanceExecutionActionType.recoverOverdue =>
      Icons.timer_outlined,
    IncomingTalentGovernanceExecutionActionType.clearBlocker =>
      Icons.report_problem_outlined,
    IncomingTalentGovernanceExecutionActionType.recordDecision =>
      Icons.gavel_outlined,
    IncomingTalentGovernanceExecutionActionType.attachEvidence =>
      Icons.article_outlined,
    IncomingTalentGovernanceExecutionActionType.confirmOwner =>
      Icons.assignment_ind_outlined,
    IncomingTalentGovernanceExecutionActionType.publishFollowThrough =>
      Icons.play_circle_outline,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance execution action tile')
Widget incomingTalentGovernanceExecutionActionTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceExecutionActionTile(
          action: _previewAction,
        ),
      ),
    ),
  );
}

final _previewAction = IncomingTalentGovernanceExecutionAction(
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
);
