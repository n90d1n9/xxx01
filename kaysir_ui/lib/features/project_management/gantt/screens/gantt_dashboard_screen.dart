import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../project/states/project_portfolio_provider.dart';
import '../gantt_dashboard.dart' as gantt;
import '../states/gantt_filter_provider.dart';
import '../widgets/gantt_baseline_variance_panel.dart';
import '../widgets/gantt_dependency_overview_panel.dart';
import '../widgets/gantt_overview_components.dart';
import '../widgets/gantt_schedule_focus_panel.dart';

class GanttDashboardScreen extends ConsumerWidget {
  const GanttDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(gantt.tasksProvider);
    final tasks = ref.watch(operationalGanttTasksProvider);
    final dateRange = ref.watch(gantt.dateRangeProvider);
    final projects = ref.watch(projectPortfolioProvider);
    final projectNamesById = {
      for (final project in projects) project.id: project.name,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Gantt Dashboard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: AppTextCluster(
                          eyebrow: 'Timeline Intelligence',
                          title: 'Gantt Dashboard',
                          subtitle:
                              'Schedule health, dependency readiness, and baseline signals across active project work.',
                          titleStyle: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                          subtitleMaxLines: 3,
                        ),
                      ),
                      AppActionButton(
                        label: 'Full Chart',
                        icon: Icons.view_timeline_outlined,
                        onPressed: () => context.go(_fullChartPath()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GanttOverviewSummaryGrid(
                    tasks: tasks,
                    dependencyTasks: allTasks,
                    dateRange: dateRange,
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Schedule Focus',
                    subtitle: 'Overdue, behind, and starting-soon work',
                    leadingIcon: Icons.crisis_alert_outlined,
                    child: GanttScheduleFocusPanel(
                      tasks: tasks,
                      dependencyTasks: allTasks,
                      projectNamesById: projectNamesById,
                      onTaskSelected:
                          (taskId) =>
                              context.go(_fullChartPath(taskId: taskId)),
                      onProjectSelected:
                          (projectId) => context.go('/projects/$projectId'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Baseline Variance',
                    subtitle: 'Expected pace vs actual task progress',
                    leadingIcon: Icons.stacked_line_chart_outlined,
                    child: GanttBaselineVariancePanel(
                      tasks: tasks,
                      projectNamesById: projectNamesById,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Dependency Readiness',
                    subtitle: 'Blocked, waiting, and ready predecessor links',
                    leadingIcon: Icons.account_tree_outlined,
                    child: GanttDependencyOverviewPanel(
                      tasks: tasks,
                      dependencyTasks: allTasks,
                      projectNamesById: projectNamesById,
                      onTaskSelected:
                          (taskId) =>
                              context.go(_fullChartPath(taskId: taskId)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fullChartPath({String? taskId}) {
    return Uri(
      path: '/gantt/chart',
      queryParameters: {if (taskId != null) 'task': taskId},
    ).toString();
  }
}
