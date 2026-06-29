import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentActivationPlanTile extends StatelessWidget {
  final IncomingTalentActivationPlan plan;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onBlock;

  const IncomingTalentActivationPlanTile({
    super.key,
    required this.plan,
    required this.onStart,
    required this.onComplete,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(plan.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.rocket_launch_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      plan.learningPlanTitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: plan.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: plan.progress,
            color: color,
            label: '${(plan.progress * 100).round()}% activation progress',
          ),
          const SizedBox(height: 10),
          Text(
            plan.successMeasure,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: plan.department,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: plan.mentorName,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: plan.activationOwner,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(plan.kickoffDate),
              ),
              if (plan.acceptedProgramMilestoneCount > 0)
                TalentMetaLabel(
                  icon: Icons.task_alt_outlined,
                  label: '${plan.acceptedProgramMilestoneCount} milestones',
                ),
              if (plan.roleReadyProgramCompletionCount > 0)
                TalentMetaLabel(
                  icon: Icons.workspace_premium_outlined,
                  label: '${plan.roleReadyProgramCompletionCount} role-ready',
                ),
              if (plan.programCompletionExtensionCount > 0)
                TalentMetaLabel(
                  icon: Icons.report_problem_outlined,
                  label: '${plan.programCompletionExtensionCount} extensions',
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
                      plan.status == IncomingTalentActivationStatus.active
                          ? null
                          : onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      plan.status == IncomingTalentActivationStatus.blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                FilledButton.icon(
                  onPressed:
                      plan.status == IncomingTalentActivationStatus.completed
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

Color _statusColor(IncomingTalentActivationStatus status) {
  return switch (status) {
    IncomingTalentActivationStatus.planned => const Color(0xFF2563EB),
    IncomingTalentActivationStatus.active => const Color(0xFF059669),
    IncomingTalentActivationStatus.completed => const Color(0xFF15803D),
    IncomingTalentActivationStatus.blocked => const Color(0xFFDC2626),
  };
}
