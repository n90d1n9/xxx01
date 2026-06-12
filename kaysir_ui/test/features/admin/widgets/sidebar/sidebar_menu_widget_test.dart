import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/admin/states/sidebar_provider.dart';
import 'package:kaysir/features/admin/widgets/sidebar/sidebar_menu.dart';
import 'package:kaysir/features/project_management/project/project_management_routes.dart';
import 'package:kaysir/routes/register_routes_screen.dart';

void main() {
  testWidgets('expanded sidebar menu renders visible sidebar routes', (
    tester,
  ) async {
    FeatureRoutes? selected;
    final dashboard = FeatureRoutes(
      id: 1,
      title: 'Dashboard',
      subtitle: 'Daily pulse',
      path: '/dashboard',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            height: 260,
            child: SidebarMenuWidget(
              menuItems: [
                dashboard,
                FeatureRoutes(
                  id: 2,
                  title: 'Header only',
                  path: '/header',
                  position: const [MenuPosition.header],
                ),
                FeatureRoutes(
                  id: 3,
                  title: 'Disabled',
                  path: '/disabled',
                  enabled: false,
                ),
              ],
              selectedMenu: dashboard,
              onMenuSelected: (menu) => selected = menu,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Daily pulse'), findsOneWidget);
    expect(find.text('Header only'), findsNothing);
    expect(find.text('Disabled'), findsNothing);

    await tester.tap(find.text('Dashboard'));

    expect(selected, dashboard);
  });

  testWidgets('compact sidebar menu keeps labels in tooltips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 76,
            height: 180,
            child: SidebarMenuWidget(
              displayMode: SidebarMode.compact,
              menuItems: [
                FeatureRoutes(id: 1, title: 'Inventory', path: '/inventory'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Inventory'), findsNothing);
    expect(find.byTooltip('Inventory'), findsOneWidget);
  });

  testWidgets('sidebar menu can select a parent route with children', (
    tester,
  ) async {
    FeatureRoutes? selected;
    final commerce = FeatureRoutes(
      id: 1,
      title: 'Commerce Workspace',
      path: '/commerce',
      items: [FeatureRoutes(id: 2, title: ' Orders', path: '/commerce/orders')],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            height: 260,
            child: SidebarMenuWidget(
              menuItems: [commerce],
              onMenuSelected: (menu) => selected = menu,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Commerce Workspace'));
    await tester.pumpAndSettle();

    expect(selected, commerce);
    expect(find.text(' Orders'), findsOneWidget);
  });

  testWidgets('dashboard menu recursively exposes nested screen shortcuts', (
    tester,
  ) async {
    FeatureRoutes? selected;
    final retailDetail = FeatureRoutes(
      id: 3,
      title: 'Retail Modernization',
      path: '/projects/retail-modernization',
    );
    final projects = FeatureRoutes(
      id: 2,
      title: 'Project Dashboard',
      path: '/projects',
      items: [retailDetail],
    );
    final dashboard = FeatureRoutes(
      id: 1,
      title: 'Dashboard',
      path: '/dashboard',
      items: [projects],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 360,
            child: SidebarMenuWidget(
              menuItems: [dashboard],
              onMenuSelected: (menu) => selected = menu,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(selected, dashboard);

    await tester.tap(find.text('Project Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Retail Modernization'), findsOneWidget);

    await tester.tap(find.text('Retail Modernization'));
    await tester.pump();

    expect(selected, retailDetail);
  });

  testWidgets('expanded admin sidebar reaches project operational screens', (
    tester,
  ) async {
    FeatureRoutes? selected;
    final projectMenu = _projectMenu();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 520,
            child: SidebarMenuWidget(
              menuItems: [projectMenu],
              onMenuSelected: (menu) => selected = menu,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Project Management'));
    await tester.pumpAndSettle();

    expect(find.text('Project Table'), findsOneWidget);
    expect(find.text('Project Form'), findsOneWidget);
    expect(find.text('Command Center'), findsOneWidget);
    expect(find.text('Full Gantt Chart'), findsOneWidget);

    await tester.tap(find.text('Project Table'));
    await tester.pump();
    expect(selected?.path, ProjectManagementRoutes.tablePath);

    await tester.tap(find.text('Project Form'));
    await tester.pump();
    expect(selected?.path, ProjectManagementRoutes.formPath);

    await tester.tap(find.text('Command Center'));
    await tester.pump();
    expect(selected?.path, ProjectManagementRoutes.commandCenterPath);

    await tester.tap(find.text('Full Gantt Chart'));
    await tester.pump();
    expect(selected?.path, ProjectManagementRoutes.ganttChartPath);
  });

  testWidgets('compact admin sidebar reaches project operational screens', (
    tester,
  ) async {
    FeatureRoutes? selected;
    final projectMenu = _projectMenu();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 76,
            height: 520,
            child: SidebarMenuWidget(
              displayMode: SidebarMode.compact,
              menuItems: [projectMenu],
              onMenuSelected: (menu) => selected = menu,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Project Management'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Project Table'), findsOneWidget);
    expect(find.byTooltip('Project Form'), findsOneWidget);
    expect(find.byTooltip('Command Center'), findsOneWidget);
    expect(find.byTooltip('Full Gantt Chart'), findsOneWidget);

    await tester.tap(find.byTooltip('Project Form'));
    await tester.pump();
    expect(selected?.path, ProjectManagementRoutes.formPath);

    await tester.tap(find.byTooltip('Project Table'));
    await tester.pump();
    expect(selected?.path, ProjectManagementRoutes.tablePath);
  });
}

FeatureRoutes _projectMenu() {
  return registerScreens().firstWhere((route) => route.name == 'Project');
}
