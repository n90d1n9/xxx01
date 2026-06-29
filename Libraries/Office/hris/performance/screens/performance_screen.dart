import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/performance_provider.dart';
import '../widgets/calibration_panel.dart';
import '../widgets/goal_progress_panel.dart';
import '../widgets/performance_summary_grid.dart';
import '../widgets/retention_risk_panel.dart';
import '../widgets/review_cycle_panel.dart';
import '../widgets/succession_panel.dart';

class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(performanceDepartmentsProvider);
    final selectedDepartment = ref.watch(performanceDepartmentProvider);
    final attentionOnly = ref.watch(performanceAttentionOnlyProvider);
    final summary = ref.watch(performanceSummaryProvider);
    final goals = ref.watch(filteredGoalProgressProvider);
    final reviews = ref.watch(filteredReviewCyclesProvider);
    final calibration = ref.watch(filteredCalibrationItemsProvider);
    final successors = ref.watch(filteredSuccessionCandidatesProvider);
    final retention = ref.watch(filteredRetentionRisksProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Performance & Succession'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(goalProgressProvider);
              ref.invalidate(reviewCyclesProvider);
              ref.invalidate(calibrationItemsProvider);
              ref.invalidate(successionCandidatesProvider);
              ref.invalidate(retentionRisksProvider);
            },
          ),
          IconButton(
            tooltip: 'Start review',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Performance review draft created'),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisCommandHeader(
                icon: Icons.insights_outlined,
                title: 'Performance Command Center',
                subtitle: 'Goals, reviews, calibration, succession, and risk',
                departments: departments,
                selectedDepartment: selectedDepartment,
                attentionOnly: attentionOnly,
                onDepartmentChanged: (value) {
                  if (value != null) {
                    ref.read(performanceDepartmentProvider.notifier).state =
                        value;
                  }
                },
                onAttentionChanged: (value) {
                  ref.read(performanceAttentionOnlyProvider.notifier).state =
                      value;
                },
              ),
              const SizedBox(height: 16),
              PerformanceSummaryGrid(summary: summary),
              const SizedBox(height: 16),
              HrisResponsivePanelGrid(
                breakpoint: 920,
                panels: [
                  GoalProgressPanel(goals: goals),
                  ReviewCyclePanel(reviews: reviews),
                  CalibrationPanel(items: calibration),
                  SuccessionPanel(successors: successors),
                ],
              ),
              const SizedBox(height: 16),
              RetentionRiskPanel(risks: retention),
            ],
          ),
        ),
      ),
    );
  }
}
