import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_development_check_in_models.dart';
import 'recruitment_meta_label.dart';

class CandidateDevelopmentCheckInTile extends StatelessWidget {
  final CandidateDevelopmentCheckIn checkIn;
  final DateTime asOfDate;

  const CandidateDevelopmentCheckInTile({
    super.key,
    required this.checkIn,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(checkIn.status);

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
                    child: Icon(_statusIcon(checkIn.status), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checkIn.candidateName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          checkIn.objectiveTitle,
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
                label: checkIn.status.label,
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
                icon: Icons.speed_outlined,
                label: 'Confidence ${checkIn.confidenceLevel}/5',
              ),
              RecruitmentMetaLabel(
                icon: Icons.badge_outlined,
                label: 'Owner: ${checkIn.ownerName}',
              ),
              RecruitmentMetaLabel(
                icon: Icons.event_repeat_outlined,
                label:
                    '${checkIn.daysUntilReview(asOfDate)} days - ${DateFormat('MMM d').format(checkIn.nextReviewDate)}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            checkIn.progressNote,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (checkIn.blockerNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              checkIn.blockerNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB45309),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _statusColor(CandidateDevelopmentCheckInStatus status) {
  return switch (status) {
    CandidateDevelopmentCheckInStatus.onTrack => const Color(0xFF15803D),
    CandidateDevelopmentCheckInStatus.watch => const Color(0xFF2563EB),
    CandidateDevelopmentCheckInStatus.blocked => const Color(0xFFB45309),
  };
}

IconData _statusIcon(CandidateDevelopmentCheckInStatus status) {
  return switch (status) {
    CandidateDevelopmentCheckInStatus.onTrack => Icons.trending_up_outlined,
    CandidateDevelopmentCheckInStatus.watch => Icons.visibility_outlined,
    CandidateDevelopmentCheckInStatus.blocked => Icons.report_problem_outlined,
  };
}
