import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_development_models.dart';
import 'recruitment_meta_label.dart';

class CandidateDevelopmentObjectiveTile extends StatelessWidget {
  final CandidateDevelopmentObjective objective;
  final DateTime asOfDate;
  final VoidCallback onActivate;
  final VoidCallback onComplete;

  const CandidateDevelopmentObjectiveTile({
    super.key,
    required this.objective,
    required this.asOfDate,
    required this.onActivate,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(objective.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_statusIcon(objective.status), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          objective.candidateName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          objective.objectiveTitle,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HrisColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final status = HrisStatusPill(
                label: objective.status.label,
                color: color,
              );

              if (constraints.maxWidth < 700) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 10), status],
                );
              }

              return Row(
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 12),
                  status,
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              RecruitmentMetaLabel(
                icon: Icons.track_changes_outlined,
                label: objective.skillFocus,
              ),
              RecruitmentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: 'Mentor: ${objective.mentorName}',
              ),
              RecruitmentMetaLabel(
                icon: Icons.event_available_outlined,
                label:
                    '${objective.daysUntilDue(asOfDate)} days - ${DateFormat('MMM d').format(objective.dueDate)}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            objective.successMeasure,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (objective.status !=
              CandidateDevelopmentObjectiveStatus.completed) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child:
                  objective.status ==
                          CandidateDevelopmentObjectiveStatus.planned
                      ? FilledButton.icon(
                        onPressed: onActivate,
                        icon: const Icon(Icons.play_arrow_outlined),
                        label: const Text('Activate'),
                      )
                      : OutlinedButton.icon(
                        onPressed: onComplete,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Complete'),
                      ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _statusColor(CandidateDevelopmentObjectiveStatus status) {
  return switch (status) {
    CandidateDevelopmentObjectiveStatus.planned => const Color(0xFF2563EB),
    CandidateDevelopmentObjectiveStatus.active => const Color(0xFFB45309),
    CandidateDevelopmentObjectiveStatus.completed => const Color(0xFF15803D),
  };
}

IconData _statusIcon(CandidateDevelopmentObjectiveStatus status) {
  return switch (status) {
    CandidateDevelopmentObjectiveStatus.planned => Icons.flag_circle_outlined,
    CandidateDevelopmentObjectiveStatus.active => Icons.trending_up_outlined,
    CandidateDevelopmentObjectiveStatus.completed => Icons.verified_outlined,
  };
}
