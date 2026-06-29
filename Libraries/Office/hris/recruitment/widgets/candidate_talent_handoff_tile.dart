import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_talent_handoff_models.dart';
import 'recruitment_meta_label.dart';

class CandidateTalentHandoffTile extends StatelessWidget {
  final CandidateTalentHandoff handoff;
  final DateTime asOfDate;

  const CandidateTalentHandoffTile({
    super.key,
    required this.handoff,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(handoff.status);

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
                    child: Icon(_statusIcon(handoff.status), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          handoff.candidateName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          handoff.type.label,
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
                label: handoff.status.label,
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
                label: 'Owner: ${handoff.ownerName}',
              ),
              RecruitmentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: 'Manager: ${handoff.receivingManagerName}',
              ),
              RecruitmentMetaLabel(
                icon: Icons.speed_outlined,
                label: '${handoff.readinessScore}% readiness',
              ),
              RecruitmentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label: handoff.risk.label,
              ),
              RecruitmentMetaLabel(
                icon: Icons.event_available_outlined,
                label:
                    '${_daysUntil(handoff.targetStartDate, asOfDate)} days - ${DateFormat('MMM d').format(handoff.targetStartDate)}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            handoff.talentFocus,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            handoff.handoffNote,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(CandidateTalentHandoffStatus status) {
  return switch (status) {
    CandidateTalentHandoffStatus.ready => const Color(0xFF15803D),
    CandidateTalentHandoffStatus.watch => const Color(0xFF2563EB),
    CandidateTalentHandoffStatus.blocked => const Color(0xFFB45309),
  };
}

IconData _statusIcon(CandidateTalentHandoffStatus status) {
  return switch (status) {
    CandidateTalentHandoffStatus.ready => Icons.hub_outlined,
    CandidateTalentHandoffStatus.watch => Icons.visibility_outlined,
    CandidateTalentHandoffStatus.blocked => Icons.report_problem_outlined,
  };
}

int _daysUntil(DateTime dueDate, DateTime asOfDate) {
  final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return due.difference(today).inDays;
}
