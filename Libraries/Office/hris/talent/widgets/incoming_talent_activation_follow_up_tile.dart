import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_follow_up_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentActivationFollowUpTile extends StatelessWidget {
  final IncomingTalentActivationFollowUpAction action;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onBlock;

  const IncomingTalentActivationFollowUpTile({
    super.key,
    required this.action,
    required this.onStart,
    required this.onComplete,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(action.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt_outlined, color: HrisColors.primary),
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
                      action.actionType.label,
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
          const SizedBox(height: 10),
          Text(
            action.action,
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
                icon: Icons.badge_outlined,
                label: action.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(action.dueDate),
              ),
              if (action.acceptedProgramMilestoneCount > 0)
                TalentMetaLabel(
                  icon: Icons.task_alt_outlined,
                  label: '${action.acceptedProgramMilestoneCount} milestones',
                ),
              if (action.roleReadyProgramCompletionCount > 0)
                TalentMetaLabel(
                  icon: Icons.workspace_premium_outlined,
                  label: '${action.roleReadyProgramCompletionCount} role-ready',
                ),
              if (action.programCompletionExtensionCount > 0)
                TalentMetaLabel(
                  icon: Icons.report_problem_outlined,
                  label: '${action.programCompletionExtensionCount} extensions',
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
                      action.status ==
                              IncomingTalentActivationFollowUpStatus.inProgress
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentActivationFollowUpStatus.blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                FilledButton.icon(
                  onPressed:
                      action.status ==
                              IncomingTalentActivationFollowUpStatus.completed
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

Color _statusColor(IncomingTalentActivationFollowUpStatus status) {
  return switch (status) {
    IncomingTalentActivationFollowUpStatus.planned => const Color(0xFF2563EB),
    IncomingTalentActivationFollowUpStatus.inProgress => const Color(
      0xFF059669,
    ),
    IncomingTalentActivationFollowUpStatus.completed => const Color(0xFF15803D),
    IncomingTalentActivationFollowUpStatus.blocked => const Color(0xFFDC2626),
  };
}
