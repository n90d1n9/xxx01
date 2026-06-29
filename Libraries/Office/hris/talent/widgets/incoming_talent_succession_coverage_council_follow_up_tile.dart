import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionCoverageCouncilFollowUpTile
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageCouncilFollowUp followUp;
  final VoidCallback onStart;
  final VoidCallback onBlock;
  final VoidCallback onEscalate;
  final VoidCallback onComplete;

  const IncomingTalentSuccessionCoverageCouncilFollowUpTile({
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
                      followUp.scopeLabel,
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
                label: followUp.departmentScope,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: followUp.followUpOwnerName,
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
                              IncomingTalentSuccessionCoverageCouncilFollowUpStatus
                                  .inProgress
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      followUp.status ==
                              IncomingTalentSuccessionCoverageCouncilFollowUpStatus
                                  .blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      followUp.status ==
                              IncomingTalentSuccessionCoverageCouncilFollowUpStatus
                                  .escalated
                          ? null
                          : onEscalate,
                  icon: const Icon(Icons.trending_up_outlined),
                  label: const Text('Escalate'),
                ),
                FilledButton.icon(
                  onPressed:
                      followUp.status ==
                              IncomingTalentSuccessionCoverageCouncilFollowUpStatus
                                  .completed
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

Color _statusColor(
  IncomingTalentSuccessionCoverageCouncilFollowUpStatus status,
) {
  return switch (status) {
    IncomingTalentSuccessionCoverageCouncilFollowUpStatus.planned =>
      const Color(0xFF2563EB),
    IncomingTalentSuccessionCoverageCouncilFollowUpStatus.inProgress =>
      const Color(0xFF059669),
    IncomingTalentSuccessionCoverageCouncilFollowUpStatus.blocked =>
      const Color(0xFFD97706),
    IncomingTalentSuccessionCoverageCouncilFollowUpStatus.escalated =>
      const Color(0xFFDC2626),
    IncomingTalentSuccessionCoverageCouncilFollowUpStatus.completed =>
      const Color(0xFF15803D),
  };
}
