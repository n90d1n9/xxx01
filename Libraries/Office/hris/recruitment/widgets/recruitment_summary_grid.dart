import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/recruitment_models.dart';

class RecruitmentSummaryGrid extends StatelessWidget {
  final RecruitmentSummary summary;

  const RecruitmentSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Open reqs',
          value: '${summary.openRequisitions}',
          detail: 'active roles',
          icon: Icons.assignment_ind_outlined,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Candidates',
          value: '${summary.activeCandidates}',
          detail: 'active pipeline',
          icon: Icons.people_alt_outlined,
          color: const Color(0xFF7C3AED),
        ),
        HrisSummaryMetric(
          title: 'Today',
          value: '${summary.interviewsToday}',
          detail: 'interviews',
          icon: Icons.event_available_outlined,
          color: const Color(0xFF0F766E),
        ),
        HrisSummaryMetric(
          title: 'Offers',
          value: '${summary.pendingOffers}',
          detail:
              '${(summary.sourceHireRate * 100).toStringAsFixed(1)}% source hire',
          icon: Icons.handshake_outlined,
          color: const Color(0xFFD97706),
        ),
      ],
    );
  }
}
