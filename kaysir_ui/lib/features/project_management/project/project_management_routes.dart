import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ky_core/core/features/feature_routes.dart';
import 'package:ky_scrumboard/ky_scrumboard.dart';

import '../gantt/screens/gantt_dashboard_screen.dart';
import '../gantt/screens/gantt_screen.dart';
import 'data/project_portfolio_repository.dart';
import 'models/project_form_focus.dart';
import 'models/project_portfolio_item.dart';
import 'screens/project_approvals_screen.dart';
import 'screens/project_budget_changes_screen.dart';
import 'screens/project_command_center_screen.dart';
import 'screens/project_decisions_screen.dart';
import 'screens/project_detail_screen.dart';
import 'screens/project_evidence_vault_screen.dart';
import 'screens/project_finance_screen.dart';
import 'screens/project_form_screen.dart';
import 'screens/project_funding_releases_screen.dart';
import 'screens/project_petty_cash_screen.dart';
import 'screens/project_procurement_screen.dart';
import 'screens/project_risk_issues_screen.dart';
import 'screens/project_table_screen.dart';
import 'screens/projects_screen.dart';

/// Route registry for project dashboards and operational workspaces.
class ProjectManagementRoutes {
  const ProjectManagementRoutes._();

  static const portfolioPath = '/projects';
  static const tablePath = '/project-table';
  static const formPath = '/project-form';
  static const financePath = '/project-finance';
  static const pettyCashPath = '/project-petty-cash';
  static const budgetChangesPath = '/project-budget-changes';
  static const evidenceVaultPath = '/project-evidence-vault';
  static const approvalsPath = '/project-approvals';
  static const fundingReleasesPath = '/project-funding-releases';
  static const procurementPath = '/project-procurement';
  static const riskIssuesPath = '/project-risk-issues';
  static const decisionsPath = '/project-decisions';
  static const commandCenterPath = '/project-command';
  static const scrumBoardPath = '/scrum-board';
  static const ganttPath = '/gantt';
  static const ganttChartPath = '/gantt/chart';
  static const formProjectQueryKey = 'project';
  static const financeProjectQueryKey = 'project';
  static const pettyCashProjectQueryKey = 'project';
  static const budgetChangesProjectQueryKey = 'project';
  static const evidenceVaultProjectQueryKey = 'project';
  static const approvalsProjectQueryKey = 'project';
  static const fundingReleasesProjectQueryKey = 'project';
  static const procurementProjectQueryKey = 'project';
  static const riskIssuesProjectQueryKey = 'project';
  static const decisionsProjectQueryKey = 'project';

  static String detailPath(String projectId) => '$portfolioPath/$projectId';

  static String financeUri({String? projectId}) {
    final queryParameters = <String, String>{};
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId != null && normalizedProjectId.isNotEmpty) {
      queryParameters[financeProjectQueryKey] = normalizedProjectId;
    }

    return Uri(
      path: financePath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String pettyCashUri({String? projectId}) {
    final queryParameters = <String, String>{};
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId != null && normalizedProjectId.isNotEmpty) {
      queryParameters[pettyCashProjectQueryKey] = normalizedProjectId;
    }

    return Uri(
      path: pettyCashPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String budgetChangesUri({String? projectId}) {
    final queryParameters = <String, String>{};
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId != null && normalizedProjectId.isNotEmpty) {
      queryParameters[budgetChangesProjectQueryKey] = normalizedProjectId;
    }

    return Uri(
      path: budgetChangesPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String evidenceVaultUri({String? projectId}) {
    final queryParameters = <String, String>{};
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId != null && normalizedProjectId.isNotEmpty) {
      queryParameters[evidenceVaultProjectQueryKey] = normalizedProjectId;
    }

    return Uri(
      path: evidenceVaultPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String approvalsUri({String? projectId}) {
    final queryParameters = <String, String>{};
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId != null && normalizedProjectId.isNotEmpty) {
      queryParameters[approvalsProjectQueryKey] = normalizedProjectId;
    }

    return Uri(
      path: approvalsPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String fundingReleasesUri({String? projectId}) {
    final queryParameters = <String, String>{};
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId != null && normalizedProjectId.isNotEmpty) {
      queryParameters[fundingReleasesProjectQueryKey] = normalizedProjectId;
    }

    return Uri(
      path: fundingReleasesPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String procurementUri({String? projectId}) {
    final queryParameters = <String, String>{};
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId != null && normalizedProjectId.isNotEmpty) {
      queryParameters[procurementProjectQueryKey] = normalizedProjectId;
    }

    return Uri(
      path: procurementPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String riskIssuesUri({String? projectId}) {
    final queryParameters = <String, String>{};
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId != null && normalizedProjectId.isNotEmpty) {
      queryParameters[riskIssuesProjectQueryKey] = normalizedProjectId;
    }

    return Uri(
      path: riskIssuesPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String decisionsUri({String? projectId}) {
    final queryParameters = <String, String>{};
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId != null && normalizedProjectId.isNotEmpty) {
      queryParameters[decisionsProjectQueryKey] = normalizedProjectId;
    }

    return Uri(
      path: decisionsPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String ganttChartUri({String? projectId, String? taskId}) {
    final queryParameters = <String, String>{};
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId != null && normalizedProjectId.isNotEmpty) {
      queryParameters['project'] = normalizedProjectId;
    }

    final normalizedTaskId = taskId?.trim();
    if (normalizedTaskId != null && normalizedTaskId.isNotEmpty) {
      queryParameters['task'] = normalizedTaskId;
    }

    return Uri(
      path: ganttChartPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String formUri({
    String? projectId,
    ProjectFormPanelFocus focus = ProjectFormPanelFocus.none,
    String? focusedAttributeKey,
  }) {
    final queryParameters = <String, String>{};
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId != null && normalizedProjectId.isNotEmpty) {
      queryParameters[formProjectQueryKey] = normalizedProjectId;
    }

    final normalizedFocusedAttributeKey =
        projectFormFocusedAttributeKeyFromQuery(focusedAttributeKey);
    final effectiveFocus =
        normalizedFocusedAttributeKey == null
            ? focus
            : ProjectFormPanelFocus.domainExtensions;
    final focusValue = projectFormPanelFocusQueryValue(effectiveFocus);
    if (focusValue != null) {
      queryParameters[projectFormFocusQueryKey] = focusValue;
    }
    if (normalizedFocusedAttributeKey != null) {
      queryParameters[projectFormFocusedAttributeQueryKey] =
          normalizedFocusedAttributeKey;
    }

    return Uri(
      path: formPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static List<FeatureRoutes> dashboardItems() {
    return [
      _projectDashboardRoute(),
      _ganttDashboardRoute(),
      for (final project in demoProjectPortfolio)
        _projectDetailShortcut(project),
    ];
  }

  static FeatureRoutes menu() {
    return FeatureRoutes(
      name: 'Project',
      title: 'Project Management',
      subtitle: 'Records, intake, command',
      description:
          'Project records, reusable intake, delivery command center, and full-screen planning workspaces.',
      icon: 'project',
      items: [
        _projectTableRoute(),
        _projectFormRoute(),
        _projectFinanceRoute(),
        _projectPettyCashRoute(),
        _projectBudgetChangesRoute(),
        _projectEvidenceVaultRoute(),
        _projectApprovalsRoute(),
        _projectFundingReleasesRoute(),
        _projectProcurementRoute(),
        _projectRiskIssuesRoute(),
        _projectDecisionsRoute(),
        _scrumBoardRoute(),
        _commandCenterRoute(),
        _fullGanttChartRoute(),
      ],
    );
  }

  static FeatureRoutes _projectDashboardRoute() {
    return FeatureRoutes(
      name: 'Projects',
      title: 'Project Dashboard',
      subtitle: 'Portfolio board',
      description:
          'Project dashboard for portfolio health, filters, milestones, and delivery ownership.',
      icon: 'dashboard',
      path: portfolioPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              const MaterialPage(child: ProjectScreen()),
      pathBuilder: ':projectId',
      builder:
          (BuildContext context, GoRouterState state) => ProjectDetailScreen(
            projectId: state.pathParameters['projectId']!,
          ),
    );
  }

  static FeatureRoutes _projectTableRoute() {
    return FeatureRoutes(
      name: 'Project Table',
      title: 'Project Table',
      subtitle: 'Records and filters',
      description:
          'Project table for searchable records, portfolio filters, health columns, budget usage, milestones, and quick detail access.',
      icon: 'table',
      path: tablePath,
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              const MaterialPage(child: ProjectTableScreen()),
    );
  }

  static FeatureRoutes _projectFormRoute() {
    return FeatureRoutes(
      name: 'Project Form',
      title: 'Project Form',
      subtitle: 'Create project',
      description:
          'Project form for reusable multi-domain intake across construction, software development, events, government, education, wedding organizer, and general business work.',
      icon: 'form',
      path: formPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) => MaterialPage(
            child: ProjectFormScreen(
              projectId: state.uri.queryParameters[formProjectQueryKey],
              initialFocus: projectFormPanelFocusFromQuery(
                state.uri.queryParameters[projectFormFocusQueryKey],
              ),
              focusedAttributeKey: projectFormFocusedAttributeKeyFromQuery(
                state.uri.queryParameters[projectFormFocusedAttributeQueryKey],
              ),
            ),
          ),
    );
  }

  static FeatureRoutes _projectFinanceRoute() {
    return FeatureRoutes(
      name: 'Project Finance',
      title: 'Project Finance',
      subtitle: 'Budgets and cash flow',
      description:
          'Project finance workspace for budget ledger, petty cash, expense approvals, spend authority, cash flow, and reconciliation.',
      icon: 'project-finance',
      path: financePath,
      pageBuilder:
          (BuildContext context, GoRouterState state) => MaterialPage(
            child: ProjectFinanceScreen(
              initialProjectId:
                  state.uri.queryParameters[financeProjectQueryKey],
            ),
          ),
    );
  }

  static FeatureRoutes _projectPettyCashRoute() {
    return FeatureRoutes(
      name: 'Project Petty Cash',
      title: 'Project Petty Cash',
      subtitle: 'Float and receipts',
      description:
          'Project petty-cash workspace for field float, custodians, receipts, approval route, reconciliation, and closeout evidence.',
      icon: 'payments',
      path: pettyCashPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) => MaterialPage(
            child: ProjectPettyCashScreen(
              initialProjectId:
                  state.uri.queryParameters[pettyCashProjectQueryKey],
            ),
          ),
    );
  }

  static FeatureRoutes _projectBudgetChangesRoute() {
    return FeatureRoutes(
      name: 'Project Budget Changes',
      title: 'Project Budget Changes',
      subtitle: 'Variations and approvals',
      description:
          'Project budget-change workspace for variation requests, recovery amounts, scope tradeoffs, approval routes, and budget evidence.',
      icon: 'rule_folder',
      path: budgetChangesPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) => MaterialPage(
            child: ProjectBudgetChangesScreen(
              initialProjectId:
                  state.uri.queryParameters[budgetChangesProjectQueryKey],
            ),
          ),
    );
  }

  static FeatureRoutes _projectEvidenceVaultRoute() {
    return FeatureRoutes(
      name: 'Project Evidence Vault',
      title: 'Project Evidence Vault',
      subtitle: 'Receipts and proof',
      description:
          'Project evidence vault for receipts, approvals, milestone proof, reconciliation records, and closeout handoff evidence.',
      icon: 'inventory_2',
      path: evidenceVaultPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) => MaterialPage(
            child: ProjectEvidenceVaultScreen(
              initialProjectId:
                  state.uri.queryParameters[evidenceVaultProjectQueryKey],
            ),
          ),
    );
  }

  static FeatureRoutes _projectApprovalsRoute() {
    return FeatureRoutes(
      name: 'Project Approvals',
      title: 'Project Approvals',
      subtitle: 'Sign-offs and authority',
      description:
          'Project approvals workspace for spend authority, budget changes, evidence sign-off, and approval records.',
      icon: 'verified_user',
      path: approvalsPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) => MaterialPage(
            child: ProjectApprovalsScreen(
              initialProjectId:
                  state.uri.queryParameters[approvalsProjectQueryKey],
            ),
          ),
    );
  }

  static FeatureRoutes _projectFundingReleasesRoute() {
    return FeatureRoutes(
      name: 'Project Funding Releases',
      title: 'Project Funding Releases',
      subtitle: 'Cash-flow gates',
      description:
          'Project funding release workspace for cash-flow gates, reserve guardrails, spend authority, and release evidence.',
      icon: 'waterfall_chart',
      path: fundingReleasesPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) => MaterialPage(
            child: ProjectFundingReleasesScreen(
              initialProjectId:
                  state.uri.queryParameters[fundingReleasesProjectQueryKey],
            ),
          ),
    );
  }

  static FeatureRoutes _projectProcurementRoute() {
    return FeatureRoutes(
      name: 'Project Procurement',
      title: 'Project Procurement',
      subtitle: 'Vendors and commitments',
      description:
          'Project procurement workspace for vendor packages, supplier risks, commitment authority, and delivery proof.',
      icon: 'inventory_2',
      path: procurementPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) => MaterialPage(
            child: ProjectProcurementScreen(
              initialProjectId:
                  state.uri.queryParameters[procurementProjectQueryKey],
            ),
          ),
    );
  }

  static FeatureRoutes _projectRiskIssuesRoute() {
    return FeatureRoutes(
      name: 'Project Risk & Issues',
      title: 'Project Risk & Issues',
      subtitle: 'Blockers and exposure',
      description:
          'Project risk and issue workspace for blockers, delivery risks, milestones, budget exposure, authority, cash-flow, and evidence issues.',
      icon: 'health_and_safety',
      path: riskIssuesPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) => MaterialPage(
            child: ProjectRiskIssuesScreen(
              initialProjectId:
                  state.uri.queryParameters[riskIssuesProjectQueryKey],
            ),
          ),
    );
  }

  static FeatureRoutes _projectDecisionsRoute() {
    return FeatureRoutes(
      name: 'Project Decisions',
      title: 'Project Decisions',
      subtitle: 'Governance routes',
      description:
          'Project decisions workspace for next decisions, governance routes, sponsor ownership, approval evidence, and decision briefs.',
      icon: 'account_tree',
      path: decisionsPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) => MaterialPage(
            child: ProjectDecisionsScreen(
              initialProjectId:
                  state.uri.queryParameters[decisionsProjectQueryKey],
            ),
          ),
    );
  }

  static FeatureRoutes _commandCenterRoute() {
    return FeatureRoutes(
      name: 'Command Center',
      title: 'Command Center',
      subtitle: 'Delivery signals',
      description:
          'Cross-project command center for blockers, budget pulse, risk exposure, resource capacity, and milestone forecast.',
      icon: 'command',
      path: commandCenterPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              const MaterialPage(child: ProjectCommandCenterScreen()),
    );
  }

  static FeatureRoutes _scrumBoardRoute() {
    return FeatureRoutes(
      name: 'Scrum Board',
      title: 'Scrum Board',
      subtitle: 'Sprint kanban',
      description:
          'Reusable scrumboard workspace for sprint backlog, active delivery, review, and done work.',
      icon: 'scrumboard',
      path: scrumBoardPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              const MaterialPage(child: ScrumBoardScreen()),
    );
  }

  static FeatureRoutes _ganttDashboardRoute() {
    return FeatureRoutes(
      name: 'Gantt Dashboard',
      title: 'Gantt Dashboard',
      subtitle: 'Timeline planning',
      description:
          'Gantt dashboard for timeline planning, schedule health, dependency readiness, baseline variance, and recovery focus.',
      icon: 'gantt',
      path: ganttPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              const MaterialPage(child: GanttDashboardScreen()),
    );
  }

  static FeatureRoutes _fullGanttChartRoute() {
    return FeatureRoutes(
      name: 'Full Gantt Chart',
      title: 'Full Gantt Chart',
      subtitle: 'Interactive planning',
      description:
          'Full-screen Gantt workspace for project schedules, dependencies, baselines, and task operations.',
      icon: 'gantt',
      path: ganttChartPath,
      pageBuilder:
          (BuildContext context, GoRouterState state) => MaterialPage(
            child: GanttChartScreen(
              initialProjectId: state.uri.queryParameters['project'],
              initialTaskId: state.uri.queryParameters['task'],
            ),
          ),
    );
  }

  static FeatureRoutes _projectDetailShortcut(ProjectPortfolioItem project) {
    return FeatureRoutes(
      name: '${project.name} Detail',
      title: project.name,
      subtitle: 'Project detail',
      description:
          'Open ${project.name} detail for readiness, timeline health, governance, evidence, change control, and handoff.',
      icon: 'project-detail',
      path: detailPath(project.id),
    );
  }
}
