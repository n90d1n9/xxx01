import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/recruitment_models.dart';
import 'recruitment_meta_label.dart';
import 'recruitment_status_styles.dart';

class InterviewSchedulePanel extends StatelessWidget {
  final List<InterviewSlot> interviews;

  const InterviewSchedulePanel({super.key, required this.interviews});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Interview Schedule',
      icon: Icons.event_available_outlined,
      subtitle: '${interviews.length} interviews',
      emptyMessage: 'No interviews match filters',
      children:
          interviews
              .map((interview) => _InterviewTile(interview: interview))
              .toList(),
    );
  }
}

class _InterviewTile extends StatelessWidget {
  final InterviewSlot interview;

  const _InterviewTile({required this.interview});

  @override
  Widget build(BuildContext context) {
    final color = interviewStatusColor(interview.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.event_note_outlined, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        interview.candidateName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    HrisStatusPill(
                      label: interviewStatusLabel(interview.status),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  interview.role,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    RecruitmentMetaLabel(
                      icon: Icons.person_outline,
                      label: interview.interviewer,
                    ),
                    RecruitmentMetaLabel(
                      icon: Icons.schedule_outlined,
                      label: DateFormat(
                        'MMM d, HH:mm',
                      ).format(interview.scheduledAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
