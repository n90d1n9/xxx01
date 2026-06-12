import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../project_management_routes.dart';
import '../services/project_budget_pulse_service.dart';
import '../services/project_milestone_forecast_service.dart';
import '../services/project_resource_capacity_service.dart';
import '../services/project_risk_exposure_service.dart';
import '../states/project_delivery_command_provider.dart';
import '../states/project_portfolio_provider.dart';
import '../widgets/project_budget_pulse_panel.dart';
import '../widgets/project_delivery_command_components.dart';
import '../widgets/project_delivery_command_lens_bar.dart';
import '../widgets/project_delivery_saved_lens_profile_bar.dart';
import '../widgets/project_delivery_saved_lens_strip.dart';
import '../widgets/project_milestone_forecast_panel.dart';
import '../widgets/project_resource_capacity_panel.dart';
import '../widgets/project_risk_exposure_panel.dart';

class ProjectCommandCenterScreen extends ConsumerStatefulWidget {
  const ProjectCommandCenterScreen({super.key});

  @override
  ConsumerState<ProjectCommandCenterScreen> createState() =>
      _ProjectCommandCenterScreenState();
}

class _ProjectCommandCenterScreenState
    extends ConsumerState<ProjectCommandCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(projectDeliveryCommandViewHydrationProvider.future));
    });
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectPortfolioProvider);
    final summary = ref.watch(projectDeliveryCommandSummaryProvider);
    final filteredCommands = ref.watch(filteredProjectDeliveryCommandsProvider);
    final commandFilter = ref.watch(projectDeliveryCommandFilterProvider);
    final savedLensProfile = ref.watch(projectDeliverySavedLensProfileProvider);
    final savedLenses = ref.watch(projectDeliverySavedLensesProvider);
    final commandViewNotifier = ref.read(
      projectDeliveryCommandViewProvider.notifier,
    );
    final capacitySummary = buildProjectResourceCapacitySummary(
      projects: projects,
    );
    final milestoneForecast = buildProjectMilestoneForecastSummary(
      projects: projects,
    );
    final riskExposure = buildProjectRiskExposureSummary(projects: projects);
    final budgetPulse = buildProjectBudgetPulseSummary(projects: projects);

    return Scaffold(
      appBar: AppBar(title: const Text('Command Center')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextCluster(
                    eyebrow: 'Project Management',
                    title: 'Delivery Command Center',
                    subtitle:
                        'A prioritized queue for blockers, schedule pressure, dependency risk, milestones, and budget drift.',
                    titleStyle: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                    subtitleMaxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ProjectDeliveryCommandSummaryGrid(summary: summary),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Resource Capacity',
                    subtitle:
                        '${capacitySummary.contributorCount} contributors across active projects',
                    leadingIcon: Icons.groups_outlined,
                    child: ProjectResourceCapacityPanel(
                      summary: capacitySummary,
                      onOpenProject:
                          (projectId) => context.go('/projects/$projectId'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Risk Exposure',
                    subtitle:
                        '${riskExposure.activeCount} active risks across ${riskExposure.projectCount} projects',
                    leadingIcon: Icons.health_and_safety_outlined,
                    child: ProjectRiskExposurePanel(
                      summary: riskExposure,
                      onOpenProject:
                          (projectId) => context.go('/projects/$projectId'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Budget Pulse',
                    subtitle:
                        '${budgetPulse.pressureCount} projects under budget pressure',
                    leadingIcon: Icons.account_balance_wallet_outlined,
                    child: ProjectBudgetPulsePanel(
                      summary: budgetPulse,
                      onOpenProject:
                          (projectId) => context.go('/projects/$projectId'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Milestone Forecast',
                    subtitle:
                        '${milestoneForecast.totalCount} milestones in the next ${milestoneForecast.horizonDays} days',
                    leadingIcon: Icons.flag_outlined,
                    child: ProjectMilestoneForecastPanel(
                      summary: milestoneForecast,
                      onOpenProject:
                          (projectId) => context.go('/projects/$projectId'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppContentPanel(
                    title: 'Priority Queue',
                    subtitle: '${summary.totalCount} active delivery signals',
                    leadingIcon: Icons.rule_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProjectDeliverySavedLensProfileBar(
                          value: savedLensProfile,
                          onChanged: commandViewNotifier.setProfile,
                        ),
                        const SizedBox(height: 12),
                        ProjectDeliverySavedLensStrip(
                          commands: summary.commands,
                          filter: commandFilter,
                          onFilterChanged: commandViewNotifier.setFilter,
                          lenses: savedLenses,
                        ),
                        const SizedBox(height: 12),
                        ProjectDeliveryCommandLensBar(
                          commands: summary.commands,
                          filter: commandFilter,
                          onFilterChanged: commandViewNotifier.setFilter,
                        ),
                        const SizedBox(height: 12),
                        ProjectDeliveryCommandFilteredQueue(
                          commands: summary.commands,
                          filteredCommands: filteredCommands,
                          filter: commandFilter,
                          onFilterChanged: commandViewNotifier.setFilter,
                          onOpenProject:
                              (projectId) => context.go('/projects/$projectId'),
                          onFocusGantt:
                              (projectId, taskId) => context.go(
                                ProjectManagementRoutes.ganttChartUri(
                                  projectId: projectId,
                                  taskId: taskId,
                                ),
                              ),
                        ),
                      ],
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
}
