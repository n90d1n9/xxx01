import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import 'talent_meta_label.dart';

/// Promotion stabilization follow-up tile with owner, status, and evidence.
class IncomingTalentPromotionStabilizationFollowUpActionTile
    extends StatelessWidget {
  final IncomingTalentPromotionStabilizationFollowUpAction action;

  const IncomingTalentPromotionStabilizationFollowUpActionTile({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentPromotionStabilizationFollowUpStatusColor(
      action.status,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_actionIcon(action.actionType), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${action.frameworkLevelCode} ${action.newRole}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: action.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: action.progressRatio,
            color: color,
            label: action.actionType.label,
          ),
          const SizedBox(height: 10),
          Text(
            action.actionPlan,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action.successCriteria,
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
                icon: Icons.apartment_outlined,
                label: action.department,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: action.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: action.priority.label,
              ),
              TalentMetaLabel(
                icon: Icons.insights_outlined,
                label: action.sourceOutcome.label,
              ),
              TalentMetaLabel(
                icon: Icons.speed_outlined,
                label: '${action.sourceConfidenceScore}/5 confidence',
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(action.dueDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentPromotionStabilizationFollowUpStatusColor(
  IncomingTalentPromotionStabilizationFollowUpStatus status,
) {
  return switch (status) {
    IncomingTalentPromotionStabilizationFollowUpStatus.open => const Color(
      0xFF2563EB,
    ),
    IncomingTalentPromotionStabilizationFollowUpStatus.inProgress =>
      const Color(0xFFD97706),
    IncomingTalentPromotionStabilizationFollowUpStatus.resolved => const Color(
      0xFF059669,
    ),
    IncomingTalentPromotionStabilizationFollowUpStatus.escalated => const Color(
      0xFFDC2626,
    ),
    IncomingTalentPromotionStabilizationFollowUpStatus.cancelled => const Color(
      0xFF64748B,
    ),
  };
}

IconData _actionIcon(
  IncomingTalentPromotionStabilizationFollowUpActionType actionType,
) {
  return switch (actionType) {
    IncomingTalentPromotionStabilizationFollowUpActionType.managerCoaching =>
      Icons.support_agent_outlined,
    IncomingTalentPromotionStabilizationFollowUpActionType
        .compensationConfirmation =>
      Icons.payments_outlined,
    IncomingTalentPromotionStabilizationFollowUpActionType.trialCheckpoint =>
      Icons.schedule_outlined,
    IncomingTalentPromotionStabilizationFollowUpActionType.roleResetPlan =>
      Icons.manage_accounts_outlined,
    IncomingTalentPromotionStabilizationFollowUpActionType
        .peoplePanelEscalation =>
      Icons.groups_outlined,
  };
}

@Preview(name: 'Talent promotion stabilization follow-up tile')
Widget incomingTalentPromotionStabilizationFollowUpActionTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationFollowUpActionTile(
          action: _previewAction,
        ),
      ),
    ),
  );
}

final _previewAction = IncomingTalentPromotionStabilizationFollowUpAction(
  id: 'promotion-stabilization-follow-up-preview',
  reviewId: 'promotion-stabilization-review-preview',
  implementationId: 'promotion-implementation-preview',
  decisionId: 'promotion-decision-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  actionType:
      IncomingTalentPromotionStabilizationFollowUpActionType.managerCoaching,
  priority: IncomingTalentPromotionStabilizationFollowUpPriority.critical,
  status: IncomingTalentPromotionStabilizationFollowUpStatus.inProgress,
  dueDate: DateTime(2026, 7, 21),
  actionPlan:
      'Run manager coaching checkpoint and clarify promotion success measures.',
  successCriteria:
      'Manager and employee confirm clear expectations and support cadence.',
  escalationNote: 'Escalate if progress is not confirmed by the due date.',
  resolutionNote: '',
  sourceOutcome:
      IncomingTalentPromotionStabilizationOutcome.needsManagerSupport,
  sourceReviewStatus:
      IncomingTalentPromotionStabilizationStatus.followUpRequired,
  sourceConfidenceScore: 2,
  createdAt: DateTime(2026, 7, 9),
);
