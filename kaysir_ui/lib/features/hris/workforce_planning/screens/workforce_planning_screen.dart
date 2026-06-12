import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/workforce_planning_provider.dart';
import '../widgets/capacity_risk_panel.dart';
import '../widgets/headcount_plan_panel.dart';
import '../widgets/position_request_panel.dart';
import '../widgets/workforce_planning_summary_grid.dart';
import '../widgets/workforce_scenario_panel.dart';

class WorkforcePlanningScreen extends ConsumerWidget {
  const WorkforcePlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(workforcePlanningDepartmentsProvider);
    final selectedDepartment = ref.watch(workforcePlanningDepartmentProvider);
    final attentionOnly = ref.watch(workforcePlanningAttentionOnlyProvider);
    final summary = ref.watch(workforcePlanningSummaryProvider);
    final headcountPlans = ref.watch(filteredHeadcountPlansProvider);
    final positionRequests = ref.watch(filteredPositionRequestsProvider);
    final capacityRisks = ref.watch(filteredCapacityRisksProvider);
    final scenarios = ref.watch(filteredWorkforceScenariosProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Workforce Planning'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(headcountPlansProvider);
              ref.invalidate(positionRequestsProvider);
              ref.invalidate(capacityRisksProvider);
              ref.invalidate(workforceScenariosProvider);
            },
          ),
          IconButton(
            tooltip: 'Create scenario',
            icon: const Icon(Icons.add_chart_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Planning scenario drafted')),
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
                icon: Icons.account_tree_outlined,
                title: 'Workforce Planning Center',
                subtitle: 'Headcount, vacancies, capacity, and scenarios',
                departments: departments,
                selectedDepartment: selectedDepartment,
                attentionOnly: attentionOnly,
                onDepartmentChanged: (value) {
                  if (value != null) {
                    ref
                        .read(workforcePlanningDepartmentProvider.notifier)
                        .state = value;
                  }
                },
                onAttentionChanged: (value) {
                  ref
                      .read(workforcePlanningAttentionOnlyProvider.notifier)
                      .state = value;
                },
              ),
              const SizedBox(height: 16),
              WorkforcePlanningSummaryGrid(summary: summary),
              const SizedBox(height: 16),
              HrisResponsivePanelGrid(
                panels: [
                  HeadcountPlanPanel(plans: headcountPlans),
                  PositionRequestPanel(requests: positionRequests),
                  CapacityRiskPanel(risks: capacityRisks),
                  WorkforceScenarioPanel(scenarios: scenarios),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
