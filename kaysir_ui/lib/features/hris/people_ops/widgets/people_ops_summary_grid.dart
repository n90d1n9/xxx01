import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/people_ops_models.dart';

class PeopleOpsSummaryGrid extends StatelessWidget {
  final PeopleOpsSummary summary;

  const PeopleOpsSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Open roles',
          value: '${summary.openRoles}',
          detail: '${summary.hiresNeeded} hires needed',
          icon: Icons.person_search_outlined,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Onboarding due',
          value: '${summary.onboardingTasksDue}',
          detail: 'tasks remaining',
          icon: Icons.fact_check_outlined,
          color: const Color(0xFF0F766E),
        ),
        HrisSummaryMetric(
          title: 'Compliance risks',
          value: '${summary.complianceRisks}',
          detail: 'items need review',
          icon: Icons.verified_user_outlined,
          color: const Color(0xFFB45309),
        ),
        HrisSummaryMetric(
          title: 'Pulse score',
          value: summary.averagePulseScore.toStringAsFixed(0),
          detail: 'average sentiment',
          icon: Icons.favorite_border,
          color: const Color(0xFFBE123C),
        ),
      ],
    );
  }
}
