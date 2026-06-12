import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_intervention_outcome_follow_up_models.dart';
import '../states/incoming_talent_development_intervention_outcome_follow_up_provider.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpTile
    extends ConsumerWidget {
  final IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpTile({
    super.key,
    required this.followUp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor(followUp.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_task_outlined, color: color),
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
                      '${followUp.role} - ${followUp.department}',
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
          const SizedBox(height: 12),
          HrisProgressBar(
            value: followUp.confidenceRatio,
            color: color,
            label: '${followUp.confidenceAfter}/5 outcome confidence',
          ),
          const SizedBox(height: 10),
          Text(
            followUp.action,
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
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: followUp.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.rule_folder_outlined,
                label: followUp.sourceDecision.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(followUp.dueDate),
              ),
              if (followUp.remainingReleaseRiskCount > 0)
                TalentMetaLabel(
                  icon: Icons.report_problem_outlined,
                  label:
                      '${followUp.remainingReleaseRiskCount} release risks left',
                ),
            ],
          ),
          if (!followUp.isClosed) ...[
            const SizedBox(height: 12),
            _FollowUpActions(followUp: followUp),
          ],
        ],
      ),
    );
  }
}

class _FollowUpActions extends ConsumerWidget {
  final IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp;

  const _FollowUpActions({required this.followUp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider.notifier,
    );

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (followUp.status ==
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.open)
          OutlinedButton.icon(
            onPressed: () => notifier.start(followUp.id),
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Start'),
          ),
        if (followUp.status !=
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.open)
          OutlinedButton.icon(
            onPressed:
                () => notifier.complete(
                  followUp.id,
                  resolutionNote:
                      'Follow-up completed and outcome evidence reviewed.',
                ),
            icon: const Icon(Icons.done_outlined),
            label: const Text('Complete'),
          ),
        OutlinedButton.icon(
          onPressed:
              () => notifier.escalate(
                followUp.id,
                resolutionNote:
                    'Follow-up escalated because residual outcome risk remains.',
              ),
          icon: const Icon(Icons.report_problem_outlined),
          label: const Text('Escalate'),
        ),
      ],
    );
  }
}

Color _statusColor(
  IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus status,
) {
  return switch (status) {
    IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.open =>
      const Color(0xFF2563EB),
    IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.inProgress =>
      const Color(0xFFD97706),
    IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.completed =>
      const Color(0xFF15803D),
    IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.escalated =>
      const Color(0xFFDC2626),
  };
}
