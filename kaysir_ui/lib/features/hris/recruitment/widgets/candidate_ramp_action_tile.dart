import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_ramp_action_models.dart';
import 'recruitment_meta_label.dart';

class CandidateRampSubmittedActionTile extends StatelessWidget {
  final CandidateRampAction action;

  const CandidateRampSubmittedActionTile({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  action.candidateName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: action.status.label,
                color: const Color(0xFF2563EB),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              RecruitmentMetaLabel(
                icon: Icons.school_outlined,
                label: action.learningPlanTitle,
              ),
              RecruitmentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: action.mentorName,
              ),
              RecruitmentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(action.readinessDate),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            action.notes,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}
