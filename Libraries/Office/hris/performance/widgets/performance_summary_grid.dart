import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/performance_models.dart';

class PerformanceSummaryGrid extends StatelessWidget {
  final PerformanceSummary summary;

  const PerformanceSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Active goals',
          value: '${summary.activeGoals}',
          detail: '${summary.highRetentionRisks} high risk',
          icon: Icons.flag_outlined,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Reviews due',
          value: '${summary.reviewsDue}',
          detail: 'submissions pending',
          icon: Icons.rate_review_outlined,
          color: const Color(0xFF7C3AED),
        ),
        HrisSummaryMetric(
          title: 'Calibration',
          value: '${summary.calibrationFlags}',
          detail: 'items to review',
          icon: Icons.tune_outlined,
          color: const Color(0xFFD97706),
        ),
        HrisSummaryMetric(
          title: 'Successors',
          value: '${summary.successorsReady}',
          detail: 'ready now',
          icon: Icons.account_tree_outlined,
          color: const Color(0xFF0F766E),
        ),
      ],
    );
  }
}
