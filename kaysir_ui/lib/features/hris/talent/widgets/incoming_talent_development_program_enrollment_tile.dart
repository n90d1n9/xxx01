import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentProgramEnrollmentTile extends StatelessWidget {
  final IncomingTalentDevelopmentProgramEnrollment enrollment;

  const IncomingTalentDevelopmentProgramEnrollmentTile({
    super.key,
    required this.enrollment,
  });

  @override
  Widget build(BuildContext context) {
    final color = _enrollmentStatusColor(enrollment.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_add_alt_1_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enrollment.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      enrollment.programTitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: enrollment.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: enrollment.progressRatio,
            color: color,
            label: '${enrollment.progressScore}% program progress',
          ),
          const SizedBox(height: 10),
          Text(
            enrollment.milestone,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            enrollment.evidencePlan,
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
                label: enrollment.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: enrollment.mentorName,
              ),
              TalentMetaLabel(icon: Icons.work_outline, label: enrollment.role),
              TalentMetaLabel(
                icon: Icons.fact_check_outlined,
                label: DateFormat('MMM d').format(enrollment.nextReviewDate),
              ),
              TalentMetaLabel(
                icon: Icons.flag_outlined,
                label: enrollment.sourcePortfolioStage.label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _enrollmentStatusColor(
  IncomingTalentDevelopmentProgramEnrollmentStatus status,
) {
  return switch (status) {
    IncomingTalentDevelopmentProgramEnrollmentStatus.planned => const Color(
      0xFF2563EB,
    ),
    IncomingTalentDevelopmentProgramEnrollmentStatus.active => const Color(
      0xFF059669,
    ),
    IncomingTalentDevelopmentProgramEnrollmentStatus.watch => const Color(
      0xFFDC2626,
    ),
    IncomingTalentDevelopmentProgramEnrollmentStatus.completed => const Color(
      0xFF15803D,
    ),
    IncomingTalentDevelopmentProgramEnrollmentStatus.withdrawn => const Color(
      0xFF64748B,
    ),
  };
}
