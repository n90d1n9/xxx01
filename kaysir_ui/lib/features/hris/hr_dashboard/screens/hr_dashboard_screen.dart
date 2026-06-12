import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/dashboard_action_tracking_provider.dart';
import '../states/hr_dashboard_controller.dart';
import '../states/metric_provider.dart';
import '../states/report_generation_provider.dart';
import '../widgets/dashboard_action_summary_panel.dart';
import '../widgets/dashboard_charts.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_insights_panel.dart';
import '../widgets/dashboard_metric_grid.dart';
import '../widgets/dashboard_risk_rollup_panel.dart';
import '../widgets/report_launcher_section.dart';
import '../widgets/workspace_launcher.dart';

class HRDashboardScreen extends ConsumerWidget {
  const HRDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(hrDashboardViewModelProvider);
    final actionStatuses = ref.watch(dashboardActionTrackingProvider);
    final hideCompletedActions = ref.watch(
      dashboardHideCompletedActionsProvider,
    );
    final actionOwnerFocus = ref.watch(dashboardActionOwnerFocusProvider);
    final actionPriorityFocus = ref.watch(dashboardActionPriorityFocusProvider);
    final actionUrgencyFocus = ref.watch(dashboardActionUrgencyFocusProvider);
    final reportJobs = ref.watch(reportGenerationJobsProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('HR Analytics Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person_outline, size: 18),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body:
          dashboard.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DashboardHeader(
                            selectedPeriod: dashboard.selectedPeriod,
                            lastUpdated: dashboard.lastUpdated,
                            onPeriodChanged: (value) {
                              unawaited(
                                ref
                                    .read(hrDashboardControllerProvider)
                                    .changePeriod(value),
                              );
                            },
                            onRefresh: () {
                              unawaited(
                                ref
                                    .read(hrDashboardControllerProvider)
                                    .refresh(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          DashboardMetricGrid(metrics: dashboard.hrMetrics),
                          const SizedBox(height: 20),
                          DashboardInsightsPanel(
                            summary: dashboard.insightSummary,
                          ),
                          const SizedBox(height: 20),
                          DashboardRiskRollupPanel(
                            rollup: dashboard.riskRollup,
                          ),
                          const SizedBox(height: 20),
                          DashboardActionSummaryPanel(
                            summary: dashboard.actionSummary,
                            statuses: actionStatuses,
                            hideCompleted: hideCompletedActions,
                            selectedOwner: actionOwnerFocus,
                            selectedPriority: actionPriorityFocus,
                            selectedUrgency: actionUrgencyFocus,
                            onHideCompletedChanged: (value) {
                              ref
                                  .read(
                                    dashboardHideCompletedActionsProvider
                                        .notifier,
                                  )
                                  .state = value;
                            },
                            onOwnerChanged: (owner) {
                              ref
                                  .read(
                                    dashboardActionOwnerFocusProvider.notifier,
                                  )
                                  .state = owner;
                            },
                            onPriorityChanged: (priority) {
                              ref
                                  .read(
                                    dashboardActionPriorityFocusProvider
                                        .notifier,
                                  )
                                  .state = priority;
                            },
                            onUrgencyChanged: (urgency) {
                              ref
                                  .read(
                                    dashboardActionUrgencyFocusProvider
                                        .notifier,
                                  )
                                  .state = urgency;
                            },
                            onStart: (action) {
                              ref
                                  .read(
                                    dashboardActionTrackingProvider.notifier,
                                  )
                                  .start(action.id);
                            },
                            onComplete: (action) {
                              ref
                                  .read(
                                    dashboardActionTrackingProvider.notifier,
                                  )
                                  .complete(action.id);
                            },
                            onReopen: (action) {
                              ref
                                  .read(
                                    dashboardActionTrackingProvider.notifier,
                                  )
                                  .reopen(action.id);
                            },
                          ),
                          const SizedBox(height: 20),
                          WorkspaceLauncher(
                            entries: dashboard.workspaceEntries,
                          ),
                          const SizedBox(height: 20),
                          HrisResponsivePanelGrid(
                            panels: [
                              DepartmentPerformanceChart(
                                departmentData: dashboard.departmentPerformance,
                              ),
                              HiringTrendsChart(
                                hiringData: dashboard.hiringTrends,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ReportLauncherSection(
                            reportTypes: dashboard.reportTypes,
                            recentJobs: reportJobs,
                            onGenerate: (report, request) async {
                              await ref
                                  .read(reportGenerationJobsProvider.notifier)
                                  .submit(report, request);
                            },
                            onDownload: (job) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${job.fileName} downloaded'),
                                ),
                              );
                            },
                            onDownloadReady: (jobs) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _downloadReadyReportsMessage(jobs.length),
                                  ),
                                ),
                              );
                            },
                            onRetry: (job) {
                              unawaited(
                                ref
                                    .read(reportGenerationJobsProvider.notifier)
                                    .retry(job),
                              );
                            },
                            onRetryFailed: () {
                              unawaited(
                                ref
                                    .read(reportGenerationJobsProvider.notifier)
                                    .retryFailed(),
                              );
                            },
                            onClearFinished: () {
                              ref
                                  .read(reportGenerationJobsProvider.notifier)
                                  .clearCompleted();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}

String _downloadReadyReportsMessage(int count) {
  final noun = count == 1 ? 'export' : 'exports';
  return '$count ready report $noun downloaded';
}
