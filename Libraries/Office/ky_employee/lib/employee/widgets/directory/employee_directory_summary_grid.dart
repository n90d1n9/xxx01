import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';

class EmployeeDirectorySummaryGrid extends StatelessWidget {
  final EmployeeDirectorySummary summary;

  const EmployeeDirectorySummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Headcount',
          value: '${summary.headcount}',
          detail: '${summary.departmentCount} departments in view',
          icon: Icons.badge_outlined,
          color: HrisColors.primary,
        ),
        HrisSummaryMetric(
          title: 'High performers',
          value: '${summary.highPerformerCount}',
          detail: 'Rating at 4.6 or higher',
          icon: Icons.workspace_premium_outlined,
          color: const Color(0xFF15803D),
        ),
        HrisSummaryMetric(
          title: 'Avg rating',
          value: summary.averagePerformance.toStringAsFixed(1),
          detail: 'Current filtered population',
          icon: Icons.trending_up_outlined,
          color: const Color(0xFFD97706),
        ),
        HrisSummaryMetric(
          title: 'Avg tenure',
          value: '${summary.averageTenureMonths} mo',
          detail: '${summary.watchlistCount} watchlist profiles',
          icon: Icons.history_toggle_off_outlined,
          color: const Color(0xFF7C3AED),
        ),
      ],
    );
  }
}
