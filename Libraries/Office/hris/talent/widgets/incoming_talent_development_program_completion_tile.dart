import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentProgramCompletionTile extends StatelessWidget {
  final IncomingTalentDevelopmentProgramCompletion completion;

  const IncomingTalentDevelopmentProgramCompletionTile({
    super.key,
    required this.completion,
  });

  @override
  Widget build(BuildContext context) {
    final color = _completionDecisionColor(completion.decision);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      completion.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      completion.programTitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: completion.decision.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: completion.scoreRatio,
            color: color,
            label: '${completion.score}% credential score',
          ),
          const SizedBox(height: 10),
          Text(
            completion.credentialNote,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            completion.managerRecommendation,
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
                label: completion.department,
              ),
              TalentMetaLabel(
                icon: Icons.verified_outlined,
                label: completion.credentialLevel.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(completion.completedAt),
              ),
              if (completion.renewalDate != null)
                TalentMetaLabel(
                  icon: Icons.pending_actions_outlined,
                  label:
                      'Renew ${DateFormat('MMM d').format(completion.renewalDate!)}',
                ),
              TalentMetaLabel(icon: Icons.work_outline, label: completion.role),
            ],
          ),
        ],
      ),
    );
  }
}

Color _completionDecisionColor(
  IncomingTalentDevelopmentProgramCompletionDecision decision,
) {
  return switch (decision) {
    IncomingTalentDevelopmentProgramCompletionDecision.roleReady => const Color(
      0xFF059669,
    ),
    IncomingTalentDevelopmentProgramCompletionDecision.credentialed =>
      const Color(0xFF2563EB),
    IncomingTalentDevelopmentProgramCompletionDecision.evidenceArchived =>
      const Color(0xFF475569),
    IncomingTalentDevelopmentProgramCompletionDecision.extendProgram =>
      const Color(0xFFD97706),
  };
}
