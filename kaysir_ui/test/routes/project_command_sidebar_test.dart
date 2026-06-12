import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/project_management/project/project_management_routes.dart';
import 'package:kaysir/routes/register_routes_screen.dart';
import 'package:kaysir/widgets/side_menu/side_menu.dart';

void main() {
  test(
    'dashboard screens are registered under the dashboard sidebar route',
    () {
      final dashboardMenu = _dashboardMenu();
      final projectDashboard = dashboardMenu.items.firstWhere(
        (item) => item.name == 'Projects',
      );
      final ganttDashboard = dashboardMenu.items.firstWhere(
        (item) => item.name == 'Gantt Dashboard',
      );
      final detailShortcut = dashboardMenu.items.firstWhere(
        (item) => item.name == 'Retail Modernization Detail',
      );

      expect(dashboardMenu.position, contains(MenuPosition.sidebar));
      expect(dashboardMenu.title, 'Dashboard');
      expect(projectDashboard.title, 'Project Dashboard');
      expect(projectDashboard.position, contains(MenuPosition.sidebar));
      expect(projectDashboard.path, ProjectManagementRoutes.portfolioPath);
      expect(projectDashboard.pageBuilder, isNotNull);
      expect(projectDashboard.builder, isNotNull);
      expect(ganttDashboard.path, ProjectManagementRoutes.ganttPath);
      expect(ganttDashboard.pageBuilder, isNotNull);
      expect(
        detailShortcut.path,
        ProjectManagementRoutes.detailPath('retail-modernization'),
      );
    },
  );

  test('project management screens are registered as sidebar routes', () {
    final projectMenu = _projectMenu();
    final commandCenter = projectMenu.items.firstWhere(
      (item) => item.name == 'Command Center',
    );
    final table = projectMenu.items.firstWhere(
      (item) => item.name == 'Project Table',
    );
    final form = projectMenu.items.firstWhere(
      (item) => item.name == 'Project Form',
    );
    final finance = projectMenu.items.firstWhere(
      (item) => item.name == 'Project Finance',
    );
    final pettyCash = projectMenu.items.firstWhere(
      (item) => item.name == 'Project Petty Cash',
    );
    final budgetChanges = projectMenu.items.firstWhere(
      (item) => item.name == 'Project Budget Changes',
    );
    final evidenceVault = projectMenu.items.firstWhere(
      (item) => item.name == 'Project Evidence Vault',
    );
    final approvals = projectMenu.items.firstWhere(
      (item) => item.name == 'Project Approvals',
    );
    final fundingReleases = projectMenu.items.firstWhere(
      (item) => item.name == 'Project Funding Releases',
    );
    final procurement = projectMenu.items.firstWhere(
      (item) => item.name == 'Project Procurement',
    );
    final riskIssues = projectMenu.items.firstWhere(
      (item) => item.name == 'Project Risk & Issues',
    );
    final decisions = projectMenu.items.firstWhere(
      (item) => item.name == 'Project Decisions',
    );
    final scrumBoard = projectMenu.items.firstWhere(
      (item) => item.name == 'Scrum Board',
    );
    final gantt = projectMenu.items.firstWhere(
      (item) => item.name == 'Full Gantt Chart',
    );

    expect(projectMenu.position, contains(MenuPosition.sidebar));
    expect(projectMenu.title, 'Project Management');
    expect(projectMenu.items.any((item) => item.name == 'Projects'), isFalse);
    expect(
      projectMenu.items.any((item) => item.name == 'Gantt Dashboard'),
      isFalse,
    );
    expect(
      projectMenu.items.any(
        (item) => item.name == 'Retail Modernization Detail',
      ),
      isFalse,
    );
    expect(commandCenter.position, contains(MenuPosition.sidebar));
    expect(commandCenter.path, ProjectManagementRoutes.commandCenterPath);
    expect(commandCenter.pageBuilder, isNotNull);
    expect(table.path, ProjectManagementRoutes.tablePath);
    expect(table.pageBuilder, isNotNull);
    expect(form.path, ProjectManagementRoutes.formPath);
    expect(form.pageBuilder, isNotNull);
    expect(finance.path, ProjectManagementRoutes.financePath);
    expect(finance.pageBuilder, isNotNull);
    expect(
      ProjectManagementRoutes.financeUri(projectId: 'retail-modernization'),
      '/project-finance?project=retail-modernization',
    );
    expect(pettyCash.path, ProjectManagementRoutes.pettyCashPath);
    expect(pettyCash.pageBuilder, isNotNull);
    expect(
      ProjectManagementRoutes.pettyCashUri(projectId: 'retail-modernization'),
      '/project-petty-cash?project=retail-modernization',
    );
    expect(budgetChanges.path, ProjectManagementRoutes.budgetChangesPath);
    expect(budgetChanges.pageBuilder, isNotNull);
    expect(
      ProjectManagementRoutes.budgetChangesUri(
        projectId: 'warehouse-automation',
      ),
      '/project-budget-changes?project=warehouse-automation',
    );
    expect(evidenceVault.path, ProjectManagementRoutes.evidenceVaultPath);
    expect(evidenceVault.pageBuilder, isNotNull);
    expect(
      ProjectManagementRoutes.evidenceVaultUri(
        projectId: 'warehouse-automation',
      ),
      '/project-evidence-vault?project=warehouse-automation',
    );
    expect(approvals.path, ProjectManagementRoutes.approvalsPath);
    expect(approvals.pageBuilder, isNotNull);
    expect(
      ProjectManagementRoutes.approvalsUri(projectId: 'warehouse-automation'),
      '/project-approvals?project=warehouse-automation',
    );
    expect(fundingReleases.path, ProjectManagementRoutes.fundingReleasesPath);
    expect(fundingReleases.pageBuilder, isNotNull);
    expect(
      ProjectManagementRoutes.fundingReleasesUri(
        projectId: 'warehouse-automation',
      ),
      '/project-funding-releases?project=warehouse-automation',
    );
    expect(procurement.path, ProjectManagementRoutes.procurementPath);
    expect(procurement.pageBuilder, isNotNull);
    expect(
      ProjectManagementRoutes.procurementUri(projectId: 'warehouse-automation'),
      '/project-procurement?project=warehouse-automation',
    );
    expect(riskIssues.path, ProjectManagementRoutes.riskIssuesPath);
    expect(riskIssues.pageBuilder, isNotNull);
    expect(
      ProjectManagementRoutes.riskIssuesUri(projectId: 'warehouse-automation'),
      '/project-risk-issues?project=warehouse-automation',
    );
    expect(decisions.path, ProjectManagementRoutes.decisionsPath);
    expect(decisions.pageBuilder, isNotNull);
    expect(
      ProjectManagementRoutes.decisionsUri(projectId: 'warehouse-automation'),
      '/project-decisions?project=warehouse-automation',
    );
    expect(scrumBoard.path, ProjectManagementRoutes.scrumBoardPath);
    expect(scrumBoard.pageBuilder, isNotNull);
    expect(gantt.path, ProjectManagementRoutes.ganttChartPath);
    expect(gantt.pageBuilder, isNotNull);
  });

  testWidgets('dashboard screens appear and work in sidebar menu', (
    tester,
  ) async {
    FeatureRoutes? clickedRoute;
    final dashboardMenu = _dashboardMenu();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SideMenu(
            menuItems: [dashboardMenu],
            onMenuClick: (menu) => clickedRoute = menu,
            title: const Text('Kaysir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(clickedRoute?.name, 'Dashboard');
    expect(find.text('Project Dashboard'), findsOneWidget);
    expect(find.text('Gantt Dashboard'), findsOneWidget);
    expect(find.text('Retail Modernization'), findsOneWidget);

    await tester.tap(find.text('Project Dashboard'));
    await tester.pump();

    expect(clickedRoute?.name, 'Projects');
    expect(clickedRoute?.path, ProjectManagementRoutes.portfolioPath);

    await _tapSidebarText(tester, 'Gantt Dashboard');

    expect(clickedRoute?.name, 'Gantt Dashboard');
    expect(clickedRoute?.path, ProjectManagementRoutes.ganttPath);

    await _tapSidebarText(tester, 'Retail Modernization');

    expect(clickedRoute?.name, 'Retail Modernization Detail');
    expect(
      clickedRoute?.path,
      ProjectManagementRoutes.detailPath('retail-modernization'),
    );
  });

  testWidgets('project management screens appear and work in sidebar menu', (
    tester,
  ) async {
    FeatureRoutes? clickedRoute;
    final projectMenu = _projectMenu();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SideMenu(
            menuItems: [projectMenu],
            onMenuClick: (menu) => clickedRoute = menu,
            title: const Text('Kaysir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Project Management'));
    await tester.pumpAndSettle();

    expect(find.text('Command Center'), findsOneWidget);
    expect(find.text('Project Table'), findsOneWidget);
    expect(find.text('Project Form'), findsOneWidget);
    expect(find.text('Project Finance'), findsOneWidget);
    expect(find.text('Project Petty Cash'), findsOneWidget);
    expect(find.text('Project Budget Changes'), findsOneWidget);
    expect(find.text('Project Evidence Vault'), findsOneWidget);
    expect(find.text('Project Approvals'), findsOneWidget);
    expect(find.text('Project Funding Releases'), findsOneWidget);
    expect(find.text('Project Procurement'), findsOneWidget);
    expect(find.text('Project Risk & Issues'), findsOneWidget);
    expect(find.text('Project Decisions'), findsOneWidget);
    expect(find.text('Scrum Board'), findsOneWidget);
    expect(find.text('Full Gantt Chart'), findsOneWidget);
    expect(find.text('Project Dashboard'), findsNothing);
    expect(find.text('Gantt Dashboard'), findsNothing);
    expect(find.text('Retail Modernization'), findsNothing);

    await _tapSidebarText(tester, 'Project Table');

    expect(clickedRoute?.name, 'Project Table');
    expect(clickedRoute?.path, ProjectManagementRoutes.tablePath);

    await _tapSidebarText(tester, 'Project Form');

    expect(clickedRoute?.name, 'Project Form');
    expect(clickedRoute?.path, ProjectManagementRoutes.formPath);

    await _tapSidebarText(tester, 'Command Center');

    expect(clickedRoute?.name, 'Command Center');
    expect(clickedRoute?.path, ProjectManagementRoutes.commandCenterPath);

    await _tapSidebarText(tester, 'Project Finance');

    expect(clickedRoute?.name, 'Project Finance');
    expect(clickedRoute?.path, ProjectManagementRoutes.financePath);

    await _tapSidebarText(tester, 'Project Petty Cash');

    expect(clickedRoute?.name, 'Project Petty Cash');
    expect(clickedRoute?.path, ProjectManagementRoutes.pettyCashPath);

    await _tapSidebarText(tester, 'Project Budget Changes');

    expect(clickedRoute?.name, 'Project Budget Changes');
    expect(clickedRoute?.path, ProjectManagementRoutes.budgetChangesPath);

    await _tapSidebarText(tester, 'Project Evidence Vault');

    expect(clickedRoute?.name, 'Project Evidence Vault');
    expect(clickedRoute?.path, ProjectManagementRoutes.evidenceVaultPath);

    await _tapSidebarText(tester, 'Project Approvals');

    expect(clickedRoute?.name, 'Project Approvals');
    expect(clickedRoute?.path, ProjectManagementRoutes.approvalsPath);

    await _tapSidebarText(tester, 'Project Funding Releases');

    expect(clickedRoute?.name, 'Project Funding Releases');
    expect(clickedRoute?.path, ProjectManagementRoutes.fundingReleasesPath);

    await _tapSidebarText(tester, 'Project Procurement');

    expect(clickedRoute?.name, 'Project Procurement');
    expect(clickedRoute?.path, ProjectManagementRoutes.procurementPath);

    await _tapSidebarText(tester, 'Project Risk & Issues');

    expect(clickedRoute?.name, 'Project Risk & Issues');
    expect(clickedRoute?.path, ProjectManagementRoutes.riskIssuesPath);

    await _tapSidebarText(tester, 'Project Decisions');

    expect(clickedRoute?.name, 'Project Decisions');
    expect(clickedRoute?.path, ProjectManagementRoutes.decisionsPath);

    await _tapSidebarText(tester, 'Scrum Board');

    expect(clickedRoute?.name, 'Scrum Board');
    expect(clickedRoute?.path, ProjectManagementRoutes.scrumBoardPath);

    await _tapSidebarText(tester, 'Full Gantt Chart');

    expect(clickedRoute?.name, 'Full Gantt Chart');
    expect(clickedRoute?.path, ProjectManagementRoutes.ganttChartPath);
  });
}

FeatureRoutes _dashboardMenu() {
  return registerScreens().firstWhere((route) => route.name == 'Dashboard');
}

FeatureRoutes _projectMenu() {
  return registerScreens().firstWhere((route) => route.name == 'Project');
}

Future<void> _tapSidebarText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}
