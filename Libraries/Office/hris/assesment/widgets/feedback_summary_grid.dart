import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/feedback_state.dart';

class FeedbackSummaryGrid extends StatelessWidget {
  final FeedbackSummary summary;

  const FeedbackSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Employees',
          value: '${summary.employeeCount}',
          detail: 'available for review',
          icon: Icons.groups_2_outlined,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Categories',
          value: '${summary.categoryCount}',
          detail: 'feedback dimensions',
          icon: Icons.fact_check_outlined,
          color: const Color(0xFF7C3AED),
        ),
        HrisSummaryMetric(
          title: 'Rated',
          value: '${summary.ratedCount}',
          detail:
              summary.hasCompleteRatings ? 'complete' : 'ratings in progress',
          icon: Icons.star_half_outlined,
          color: const Color(0xFFD97706),
        ),
        HrisSummaryMetric(
          title: 'Average',
          value: summary.averageRating.toStringAsFixed(1),
          detail: 'current score',
          icon: Icons.insights_outlined,
          color: const Color(0xFF0F766E),
        ),
      ],
    );
  }
}
