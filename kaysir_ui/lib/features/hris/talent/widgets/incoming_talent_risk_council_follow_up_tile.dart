import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';
import '../models/incoming_talent_risk_council_follow_up_models.dart';
import '../models/incoming_talent_risk_council_queue_models.dart';
import 'talent_meta_label.dart';

/// Follow-up tile for operating council commitments through completion.
class IncomingTalentRiskCouncilFollowUpTile extends StatelessWidget {
  final IncomingTalentRiskCouncilFollowUp followUp;
  final VoidCallback onStart;
  final VoidCallback onBlock;
  final VoidCallback onEscalate;
  final VoidCallback onComplete;

  const IncomingTalentRiskCouncilFollowUpTile({
    super.key,
    required this.followUp,
    required this.onStart,
    required this.onBlock,
    required this.onEscalate,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(followUp.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.next_plan_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      followUp.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      followUp.followUpType.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: followUp.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            followUp.actionPlan,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            followUp.successCriteria,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          if (followUp.blockerNote.isNotEmpty ||
              followUp.escalationReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              followUp.blockerNote.isNotEmpty
                  ? followUp.blockerNote
                  : followUp.escalationReason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB45309),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: followUp.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: followUp.followUpOwnerName,
              ),
              if (followUp.source !=
                  IncomingTalentRiskCouncilQueueSource.general)
                TalentMetaLabel(
                  icon: Icons.account_tree_outlined,
                  label: followUp.source.label,
                ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(followUp.dueDate),
              ),
              TalentMetaLabel(
                icon: Icons.verified_user_outlined,
                label: followUp.outcome.label,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      followUp.status ==
                              IncomingTalentRiskCouncilFollowUpStatus.inProgress
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      followUp.status ==
                              IncomingTalentRiskCouncilFollowUpStatus.blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      followUp.status ==
                              IncomingTalentRiskCouncilFollowUpStatus.escalated
                          ? null
                          : onEscalate,
                  icon: const Icon(Icons.trending_up_outlined),
                  label: const Text('Escalate'),
                ),
                FilledButton.icon(
                  onPressed:
                      followUp.status ==
                              IncomingTalentRiskCouncilFollowUpStatus.completed
                          ? null
                          : onComplete,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Complete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentRiskCouncilFollowUpStatus status) {
  return switch (status) {
    IncomingTalentRiskCouncilFollowUpStatus.planned => const Color(0xFF2563EB),
    IncomingTalentRiskCouncilFollowUpStatus.inProgress => const Color(
      0xFF059669,
    ),
    IncomingTalentRiskCouncilFollowUpStatus.blocked => const Color(0xFFD97706),
    IncomingTalentRiskCouncilFollowUpStatus.escalated => const Color(
      0xFFDC2626,
    ),
    IncomingTalentRiskCouncilFollowUpStatus.completed => const Color(
      0xFF15803D,
    ),
  };
}

@Preview(name: 'Talent risk council follow-up tile')
Widget incomingTalentRiskCouncilFollowUpTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentRiskCouncilFollowUpTile(
          followUp: _previewFollowUp,
          onStart: () {},
          onBlock: () {},
          onEscalate: () {},
          onComplete: () {},
        ),
      ),
    ),
  );
}

final _previewFollowUp = IncomingTalentRiskCouncilFollowUp(
  id: 'talent-risk-council-follow-up-preview',
  decisionId: 'talent-risk-council-decision-preview',
  queueItemId: 'risk-council:candidate-preview:promotion-resolution-review',
  candidateId: 'candidate-preview',
  candidateName: 'Alya Maheswari',
  role: 'Senior People Partner',
  department: 'People Operations',
  decisionMakerName: 'Talent Council',
  followUpOwnerName: 'People Operations Promotion Stabilization Partner',
  outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  followUpType: IncomingTalentRiskCouncilFollowUpType.monitoringReview,
  status: IncomingTalentRiskCouncilFollowUpStatus.inProgress,
  dueDate: DateTime(2026, 7, 11),
  actionPlan:
      'Review promotion stabilization evidence and decide whether monitoring can close.',
  successCriteria:
      'Role-risk evidence, manager checkpoint, and council disposition are recorded.',
  blockerNote: '',
  escalationReason: '',
  createdAt: DateTime(2026, 6, 11),
  signalCount: 1,
);
