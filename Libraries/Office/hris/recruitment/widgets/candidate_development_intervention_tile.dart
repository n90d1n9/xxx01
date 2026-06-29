import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_development_intervention_models.dart';
import 'recruitment_meta_label.dart';

class CandidateDevelopmentInterventionTile extends StatelessWidget {
  final CandidateDevelopmentIntervention intervention;
  final DateTime asOfDate;
  final VoidCallback onStart;
  final VoidCallback onResolve;

  const CandidateDevelopmentInterventionTile({
    super.key,
    required this.intervention,
    required this.asOfDate,
    required this.onStart,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(intervention.status);

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
                    child: Icon(_statusIcon(intervention.status), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          intervention.candidateName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          intervention.type.label,
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
                label: intervention.status.label,
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
                icon: Icons.badge_outlined,
                label: 'Owner: ${intervention.ownerName}',
              ),
              RecruitmentMetaLabel(
                icon: Icons.event_available_outlined,
                label:
                    '${intervention.daysUntilDue(asOfDate)} days - ${DateFormat('MMM d').format(intervention.dueDate)}',
              ),
              if (intervention.escalationRequired)
                const RecruitmentMetaLabel(
                  icon: Icons.priority_high_outlined,
                  label: 'Escalation',
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            intervention.actionNote,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (intervention.status !=
              CandidateDevelopmentInterventionStatus.resolved) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child:
                  intervention.status ==
                          CandidateDevelopmentInterventionStatus.open
                      ? FilledButton.icon(
                        onPressed: onStart,
                        icon: const Icon(Icons.play_arrow_outlined),
                        label: const Text('Start'),
                      )
                      : OutlinedButton.icon(
                        onPressed: onResolve,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Resolve'),
                      ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _statusColor(CandidateDevelopmentInterventionStatus status) {
  return switch (status) {
    CandidateDevelopmentInterventionStatus.open => const Color(0xFF2563EB),
    CandidateDevelopmentInterventionStatus.inProgress => const Color(
      0xFFB45309,
    ),
    CandidateDevelopmentInterventionStatus.resolved => const Color(0xFF15803D),
  };
}

IconData _statusIcon(CandidateDevelopmentInterventionStatus status) {
  return switch (status) {
    CandidateDevelopmentInterventionStatus.open => Icons.assignment_outlined,
    CandidateDevelopmentInterventionStatus.inProgress =>
      Icons.handyman_outlined,
    CandidateDevelopmentInterventionStatus.resolved => Icons.verified_outlined,
  };
}
