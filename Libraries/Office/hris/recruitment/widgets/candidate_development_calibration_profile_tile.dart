import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_development_calibration_models.dart';
import 'recruitment_meta_label.dart';

class CandidateDevelopmentCalibrationProfileTile extends StatelessWidget {
  final CandidateDevelopmentCalibrationProfile profile;
  final DateTime asOfDate;
  final VoidCallback onCalibrate;

  const CandidateDevelopmentCalibrationProfileTile({
    super.key,
    required this.profile,
    required this.asOfDate,
    required this.onCalibrate,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(profile.status);

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
                    child: Icon(_statusIcon(profile.status), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.candidateName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          profile.objectiveTitle,
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
                label: profile.status.label,
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
          const SizedBox(height: 12),
          HrisProgressBar(
            value: profile.readinessScore / 100,
            color: color,
            label: '${profile.readinessScore}% calibrated readiness',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              RecruitmentMetaLabel(
                icon: Icons.speed_outlined,
                label:
                    profile.latestConfidence == null
                        ? 'No check-in'
                        : 'Confidence ${profile.latestConfidence}/5',
              ),
              RecruitmentMetaLabel(
                icon: Icons.handyman_outlined,
                label: '${profile.openInterventionCount} open actions',
              ),
              RecruitmentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: 'Mentor: ${profile.mentorName}',
              ),
              RecruitmentMetaLabel(
                icon: Icons.event_available_outlined,
                label:
                    '${_daysUntil(profile.dueDate, asOfDate)} days - ${DateFormat('MMM d').format(profile.dueDate)}',
              ),
              if (profile.escalationRequired)
                const RecruitmentMetaLabel(
                  icon: Icons.priority_high_outlined,
                  label: 'Escalation',
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            profile.nextAction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onCalibrate,
              icon: const Icon(Icons.tune_outlined),
              label: const Text('Calibrate'),
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(CandidateDevelopmentCalibrationStatus status) {
  return switch (status) {
    CandidateDevelopmentCalibrationStatus.ready => const Color(0xFF15803D),
    CandidateDevelopmentCalibrationStatus.monitor => const Color(0xFF2563EB),
    CandidateDevelopmentCalibrationStatus.blocked => const Color(0xFFB45309),
  };
}

IconData _statusIcon(CandidateDevelopmentCalibrationStatus status) {
  return switch (status) {
    CandidateDevelopmentCalibrationStatus.ready => Icons.verified_outlined,
    CandidateDevelopmentCalibrationStatus.monitor => Icons.visibility_outlined,
    CandidateDevelopmentCalibrationStatus.blocked =>
      Icons.report_problem_outlined,
  };
}

int _daysUntil(DateTime dueDate, DateTime asOfDate) {
  final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return due.difference(today).inDays;
}
