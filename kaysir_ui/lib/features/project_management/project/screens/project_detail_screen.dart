import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../../gantt/widgets/gantt_baseline_variance_panel.dart';
import '../../gantt/widgets/gantt_schedule_focus_panel.dart';
import '../models/project_portfolio_item.dart';
import '../project_management_routes.dart';
import '../services/project_budget_overview_service.dart';
import '../services/project_cash_flow_forecast_service.dart';
import '../services/project_change_control_service.dart';
import '../services/project_cost_structure_service.dart';
import '../services/project_decision_governance_service.dart';
import '../services/project_domain_playbook_service.dart';
import '../services/project_evidence_pack_service.dart';
import '../services/project_expense_intake_service.dart';
import '../services/project_finance_control_service.dart';
import '../services/project_finance_ledger_summary_service.dart';
import '../services/project_finance_reconciliation_service.dart';
import '../services/project_handoff_brief_service.dart';
import '../services/project_next_decision_service.dart';
import '../services/project_operating_cadence_service.dart';
import '../services/project_readiness_score_service.dart';
import '../services/project_spend_authority_service.dart';
import '../services/project_stakeholder_alignment_service.dart';
import '../services/project_value_realization_service.dart';
import '../states/project_portfolio_provider.dart';
import '../states/project_status_update_provider.dart';
import '../states/project_timeline_provider.dart';
import '../widgets/project_budget_overview_panel.dart';
import '../widgets/project_cash_flow_forecast_panel.dart';
import '../widgets/project_change_control_panel.dart';
import '../widgets/project_cost_structure_panel.dart';
import '../widgets/project_custom_attributes_panel.dart';
import '../widgets/project_decision_governance_panel.dart';
import '../widgets/project_detail_components.dart';
import '../widgets/project_domain_playbook_panel.dart';
import '../widgets/project_evidence_pack_panel.dart';
import '../widgets/project_expense_intake_panel.dart';
import '../widgets/project_finance_control_panel.dart';
import '../widgets/project_finance_ledger_snapshot_panel.dart';
import '../widgets/project_finance_reconciliation_panel.dart';
import '../widgets/project_handoff_brief_panel.dart';
import '../widgets/project_next_decision_panel.dart';
import '../widgets/project_operating_cadence_panel.dart';
import '../widgets/project_readiness_score_panel.dart';
import '../widgets/project_spend_authority_panel.dart';
import '../widgets/project_stakeholder_alignment_panel.dart';
import '../widgets/project_status_update_panel.dart';
import '../widgets/project_timeline_health_panel.dart';
import '../widgets/project_value_realization_panel.dart';

/// Project detail workspace combining delivery, governance, and finance signals.
class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

/// State holder that hydrates preferences before building project detail panels.
class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref.read(projectStatusUpdatePreferencesHydrationProvider.future),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectByIdProvider(widget.projectId));

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Detail')),
        body: SafeArea(
          child: Center(
            child: AppEmptyState(
              icon: Icons.folder_off_outlined,
              title: 'Project not found',
              message: 'Return to the portfolio and choose an active project.',
              action: AppActionButton(
                label: 'Back to Projects',
                icon: Icons.arrow_back_rounded,
                onPressed: () => context.go('/projects'),
              ),
            ),
          ),
        ),
      );
    }

    final timelineTasks = ref.watch(projectTimelineTasksProvider(project.id));
    final allGanttTasks = ref.watch(gantt.tasksProvider);
    final selectedStatusUpdateVocabulary = ref.watch(
      selectedProjectStatusUpdateVocabularyForProjectProvider(project.id),
    );
    final selectedStatusUpdateAudience = ref.watch(
      selectedProjectStatusUpdateAudienceForProjectProvider(project.id),
    );
    final statusUpdatePreferencesNotifier = ref.read(
      projectStatusUpdatePreferencesProvider.notifier,
    );
    final readinessSummary = buildProjectReadinessScoreSummary(
      project: project,
      timelineTasks: timelineTasks,
    );
    final valueRealization = buildProjectValueRealization(
      project: project,
      timelineTasks: timelineTasks,
      dependencyTasks: allGanttTasks,
      vocabulary: selectedStatusUpdateVocabulary,
      audience: selectedStatusUpdateAudience,
    );
    final handoffBrief = buildProjectHandoffBrief(
      project: project,
      timelineTasks: timelineTasks,
    );
    final domainPlaybook = buildProjectDomainPlaybook(
      project: project,
      timelineTasks: timelineTasks,
      vocabulary: selectedStatusUpdateVocabulary,
      audience: selectedStatusUpdateAudience,
    );
    final evidencePack = buildProjectEvidencePack(
      project: project,
      timelineTasks: timelineTasks,
      vocabulary: selectedStatusUpdateVocabulary,
      audience: selectedStatusUpdateAudience,
    );
    final stakeholderAlignment = buildProjectStakeholderAlignment(
      project: project,
      timelineTasks: timelineTasks,
      vocabulary: selectedStatusUpdateVocabulary,
      audience: selectedStatusUpdateAudience,
    );
    final decisionGovernance = buildProjectDecisionGovernance(
      project: project,
      timelineTasks: timelineTasks,
      dependencyTasks: allGanttTasks,
      vocabulary: selectedStatusUpdateVocabulary,
      audience: selectedStatusUpdateAudience,
    );
    final operatingCadence = buildProjectOperatingCadence(
      project: project,
      timelineTasks: timelineTasks,
      vocabulary: selectedStatusUpdateVocabulary,
      audience: selectedStatusUpdateAudience,
    );
    final changeControl = buildProjectChangeControl(
      project: project,
      timelineTasks: timelineTasks,
      dependencyTasks: allGanttTasks,
      vocabulary: selectedStatusUpdateVocabulary,
      audience: selectedStatusUpdateAudience,
    );
    final nextDecisionSummary = buildProjectNextDecisionSummary(
      project: project,
      timelineTasks: timelineTasks,
      dependencyTasks: allGanttTasks,
    );
    final budgetOverview = buildProjectBudgetOverview(project);
    final financeLedger = buildProjectFinanceLedgerSummary(
      projectId: project.id,
    );
    final financeControls = buildProjectFinanceControlSummary(project);
    final costStructure = buildProjectCostStructureSummary(
      project,
      financeSummary: financeControls,
    );
    final expenseIntake = buildProjectExpenseIntakeSummary(project);
    final spendAuthority = buildProjectSpendAuthoritySummary(
      project,
      expenseIntake: expenseIntake,
    );
    final cashFlowForecast = buildProjectCashFlowForecastSummary(
      project,
      costStructure: costStructure,
      spendAuthority: spendAuthority,
    );
    final financeReconciliation = buildProjectFinanceReconciliationSummary(
      project,
      expenseIntake: expenseIntake,
      spendAuthority: spendAuthority,
      cashFlowForecast: cashFlowForecast,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final healthColor = project.health.color(colorScheme);

    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
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
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: AppTextCluster(
                          eyebrow: project.client,
                          title: project.name,
                          subtitle:
                              project.summary.isEmpty
                                  ? 'Project delivery detail and timeline focus.'
                                  : project.summary,
                          titleStyle: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                          subtitleMaxLines: 3,
                        ),
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          AppStatusPill(
                            label: project.health.label,
                            icon: project.health.icon,
                            color: healthColor,
                          ),
                          AppActionButton(
                            label: 'Portfolio',
                            icon: Icons.arrow_back_rounded,
                            variant: AppActionButtonVariant.secondary,
                            onPressed: () => context.go('/projects'),
                          ),
                          AppActionButton(
                            label: 'Focus Gantt',
                            icon: Icons.timeline_outlined,
                            onPressed:
                                () => context.go(
                                  ProjectManagementRoutes.ganttChartUri(
                                    projectId: project.id,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ProjectDetailSummaryGrid(project: project),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 960;
                      final left = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppContentPanel(
                            title: 'Execution Overview',
                            leadingIcon: Icons.space_dashboard_outlined,
                            child: ProjectDetailOverview(project: project),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Domain Extensions',
                            subtitle: project.businessDomain,
                            leadingIcon: Icons.extension_outlined,
                            child: ProjectCustomAttributesPanel(
                              businessDomain: project.businessDomain,
                              attributes: project.customAttributes,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Next Decisions',
                            subtitle:
                                'Action-ready calls from timeline, risk, budget, and readiness',
                            leadingIcon: Icons.rule_folder_outlined,
                            child: ProjectNextDecisionPanel(
                              summary: nextDecisionSummary,
                              onOpenTask:
                                  (task) => context.go(
                                    ProjectManagementRoutes.ganttChartUri(
                                      projectId: project.id,
                                      taskId: task.id,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Schedule Focus',
                            subtitle: 'Overdue, behind, and starting-soon work',
                            leadingIcon: Icons.crisis_alert_outlined,
                            child: GanttScheduleFocusPanel(
                              tasks: timelineTasks,
                              dependencyTasks: allGanttTasks,
                              scopeLabel: project.name,
                              maxItems: 4,
                              onTaskSelected:
                                  (taskId) => context.go(
                                    ProjectManagementRoutes.ganttChartUri(
                                      projectId: project.id,
                                      taskId: taskId,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Timeline Health',
                            subtitle: 'Schedule and dependency rollup',
                            leadingIcon: Icons.monitor_heart_outlined,
                            child: ProjectTimelineHealthPanel(
                              tasks: timelineTasks,
                              dependencyTasks: allGanttTasks,
                              onTaskFocus:
                                  (task) => context.go(
                                    ProjectManagementRoutes.ganttChartUri(
                                      projectId: project.id,
                                      taskId: task.id,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Baseline Variance',
                            subtitle: 'Expected pace vs linked progress',
                            leadingIcon: Icons.stacked_line_chart_outlined,
                            child: GanttBaselineVariancePanel(
                              tasks: timelineTasks,
                              maxItems: 4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Milestones',
                            leadingIcon: Icons.flag_outlined,
                            child: ProjectMilestoneTimeline(
                              milestones: project.milestones,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Linked Timeline',
                            subtitle: '${timelineTasks.length} Gantt tasks',
                            leadingIcon: Icons.timeline_outlined,
                            child: ProjectLinkedTimelinePanel(
                              tasks: timelineTasks,
                              onTaskFocus:
                                  (task) => context.go(
                                    ProjectManagementRoutes.ganttChartUri(
                                      projectId: project.id,
                                      taskId: task.id,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      );
                      final right = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppContentPanel(
                            title: 'Readiness Score',
                            subtitle: 'Confidence, blockers, and watch signals',
                            leadingIcon: Icons.speed_outlined,
                            child: ProjectReadinessScorePanel(
                              summary: readinessSummary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Budget Overview',
                            subtitle:
                                'Spend pace, progress gap, and remaining runway',
                            leadingIcon: Icons.account_balance_wallet_outlined,
                            child: ProjectBudgetOverviewPanel(
                              overview: budgetOverview,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Finance Ledger',
                            subtitle:
                                'Budget lines, expenses, petty cash, and evidence',
                            leadingIcon: Icons.receipt_long_outlined,
                            child: ProjectFinanceLedgerSnapshotPanel(
                              summary: financeLedger,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Cost Structure',
                            subtitle:
                                'Domain-adaptive baseline categories and controls',
                            leadingIcon: Icons.pie_chart_outline_rounded,
                            child: ProjectCostStructurePanel(
                              summary: costStructure,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Finance Controls',
                            subtitle:
                                'Petty cash, expense ownership, and approvals',
                            leadingIcon: Icons.receipt_long_outlined,
                            child: ProjectFinanceControlPanel(
                              summary: financeControls,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Spend Authority',
                            subtitle:
                                'Delegation, thresholds, and escalation routes',
                            leadingIcon: Icons.verified_user_outlined,
                            child: ProjectSpendAuthorityPanel(
                              summary: spendAuthority,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Cash Flow Forecast',
                            subtitle:
                                'Funding windows, release gates, and reserve runway',
                            leadingIcon: Icons.query_stats_outlined,
                            child: ProjectCashFlowForecastPanel(
                              summary: cashFlowForecast,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Expense Intake',
                            subtitle:
                                'Petty cash, reimbursements, vendors, and exceptions',
                            leadingIcon: Icons.request_quote_outlined,
                            child: ProjectExpenseIntakePanel(
                              summary: expenseIntake,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Finance Reconciliation',
                            subtitle:
                                'Receipts, approvals, vendor proof, and closeout',
                            leadingIcon: Icons.fact_check_outlined,
                            child: ProjectFinanceReconciliationPanel(
                              summary: financeReconciliation,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Value Realization',
                            subtitle:
                                '${selectedStatusUpdateVocabulary.label} outcome and proof path',
                            leadingIcon: Icons.insights_outlined,
                            child: ProjectValueRealizationPanel(
                              summary: valueRealization,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Status Update Composer',
                            subtitle:
                                'Reusable wording for different business domains',
                            leadingIcon: Icons.edit_note_outlined,
                            child: ProjectStatusUpdateComposerPanel(
                              project: project,
                              timelineTasks: timelineTasks,
                              dependencyTasks: allGanttTasks,
                              selectedVocabulary:
                                  selectedStatusUpdateVocabulary,
                              selectedAudience: selectedStatusUpdateAudience,
                              onVocabularyChanged:
                                  (vocabulary) =>
                                      statusUpdatePreferencesNotifier
                                          .setProjectVocabulary(
                                            projectId: project.id,
                                            vocabulary: vocabulary,
                                          ),
                              onAudienceChanged:
                                  (audience) => statusUpdatePreferencesNotifier
                                      .setProjectAudience(
                                        projectId: project.id,
                                        audience: audience,
                                      ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Domain Playbook',
                            subtitle:
                                '${selectedStatusUpdateVocabulary.label} operating checks',
                            leadingIcon: Icons.fact_check_outlined,
                            child: ProjectDomainPlaybookPanel(
                              summary: domainPlaybook,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Stakeholder Alignment',
                            subtitle:
                                '${selectedStatusUpdateVocabulary.label} decision routes',
                            leadingIcon: Icons.hub_outlined,
                            child: ProjectStakeholderAlignmentPanel(
                              summary: stakeholderAlignment,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Decision Governance',
                            subtitle:
                                '${selectedStatusUpdateVocabulary.label} approval and escalation routes',
                            leadingIcon: Icons.account_tree_outlined,
                            child: ProjectDecisionGovernancePanel(
                              summary: decisionGovernance,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Operating Cadence',
                            subtitle:
                                '${selectedStatusUpdateVocabulary.label} review rhythm',
                            leadingIcon: Icons.sync_alt_outlined,
                            child: ProjectOperatingCadencePanel(
                              summary: operatingCadence,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Change Control',
                            subtitle:
                                '${selectedStatusUpdateVocabulary.label} scope and approval guardrails',
                            leadingIcon: Icons.rule_folder_outlined,
                            child: ProjectChangeControlPanel(
                              summary: changeControl,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Evidence Pack',
                            subtitle:
                                '${selectedStatusUpdateVocabulary.label} acceptance and sign-off',
                            leadingIcon: Icons.inventory_2_outlined,
                            child: ProjectEvidencePackPanel(
                              summary: evidencePack,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Handoff Brief',
                            subtitle: 'Owner, milestone, and risk context',
                            leadingIcon: Icons.assignment_turned_in_outlined,
                            child: ProjectHandoffBriefPanel(
                              brief: handoffBrief,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Attention Plan',
                            subtitle:
                                'Schedule, risk, milestone, and budget signals',
                            leadingIcon: Icons.auto_awesome_motion_outlined,
                            child: ProjectAttentionPanel(
                              project: project,
                              timelineTasks: timelineTasks,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Delivery Risks',
                            leadingIcon: Icons.health_and_safety_outlined,
                            child: ProjectRiskQueue(risks: project.risks),
                          ),
                          const SizedBox(height: 16),
                          AppContentPanel(
                            title: 'Team',
                            leadingIcon: Icons.groups_outlined,
                            child: ProjectTeamRoster(members: project.team),
                          ),
                        ],
                      );

                      if (!isWide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [left, const SizedBox(height: 16), right],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: left),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: right),
                        ],
                      );
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
