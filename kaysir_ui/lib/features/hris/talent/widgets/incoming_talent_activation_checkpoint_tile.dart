import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_checkpoint_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentActivationCheckpointTile extends StatelessWidget {
  final IncomingTalentActivationCheckpoint checkpoint;

  const IncomingTalentActivationCheckpointTile({
    super.key,
    required this.checkpoint,
  });

  @override
  Widget build(BuildContext context) {
    final color = _healthColor(checkpoint.health);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monitor_heart_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkpoint.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      checkpoint.nextStep,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: checkpoint.health.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: checkpoint.confidenceRatio,
            color: color,
            label: '${checkpoint.confidenceScore}/5 confidence',
          ),
          const SizedBox(height: 10),
          Text(
            checkpoint.managerFeedback,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (checkpoint.blockerNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              checkpoint.blockerNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFFDC2626)),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: checkpoint.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: checkpoint.reviewerName,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: checkpoint.mentorName,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(checkpoint.reviewDate),
              ),
              if (checkpoint.acceptedProgramMilestoneCount > 0)
                TalentMetaLabel(
                  icon: Icons.task_alt_outlined,
                  label:
                      '${checkpoint.acceptedProgramMilestoneCount} milestones',
                ),
              if (checkpoint.roleReadyProgramCompletionCount > 0)
                TalentMetaLabel(
                  icon: Icons.workspace_premium_outlined,
                  label:
                      '${checkpoint.roleReadyProgramCompletionCount} role-ready',
                ),
              if (checkpoint.programCompletionExtensionCount > 0)
                TalentMetaLabel(
                  icon: Icons.report_problem_outlined,
                  label:
                      '${checkpoint.programCompletionExtensionCount} extensions',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _healthColor(IncomingTalentActivationCheckpointHealth health) {
  return switch (health) {
    IncomingTalentActivationCheckpointHealth.onTrack => const Color(0xFF059669),
    IncomingTalentActivationCheckpointHealth.watch => const Color(0xFFD97706),
    IncomingTalentActivationCheckpointHealth.blocked => const Color(0xFFDC2626),
  };
}
