import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/core/features/features_registry.dart';
import 'package:kaysir/core/routes/app_route_shell.dart';
import 'package:kaysir/core/routes/routes.dart';
import 'package:kaysir/core/routes/shell/route_search_dialog.dart';
import 'package:kaysir/core/routes/shell/route_search_index.dart';
import 'package:kaysir/core/routes/shell/route_shell_metadata.dart';
import 'package:kaysir/features/project_management/project/project_management_routes.dart';
import 'package:kaysir/features/project_management/project/screens/project_detail_screen.dart';

void main() {
  setUp(FeaturesRegistry.reset);
  tearDown(FeaturesRegistry.reset);

  test('registered sidebar routes are indexed by route search', () {
    FeaturesRegistry.init();

    final routes = FeaturesRegistry.getFeatures();
    final sidebarPaths =
        routeShellVisibleNavigableRoutes(
          routes,
        ).map((route) => route.path!.trim()).toSet();
    final searchPaths =
        buildRouteSearchEntries(
          routes,
        ).map((entry) => entry.path.trim()).toSet();

    expect(sidebarPaths, isNotEmpty);
    expect(searchPaths, containsAll(sidebarPaths));
  });

  test('registered sidebar routes resolve through GoRouter paths', () {
    FeaturesRegistry.init();

    final routes = FeaturesRegistry.getFeatures();
    final sidebarLocations =
        routeShellVisibleNavigableRoutes(
          routes,
        ).map((route) => route.path!.trim()).toSet();
    final goRoutePaths = _goRouteFullPathsFor(Routes.routes);
    final missing =
        sidebarLocations
            .where(
              (location) =>
                  !goRoutePaths.any(
                    (routePath) =>
                        routeShellPathMatchesExactly(location, routePath),
                  ),
            )
            .toList();

    expect(sidebarLocations, isNotEmpty);
    expect(goRoutePaths, contains('/projects/:projectId'));
    expect(missing, isEmpty);
  });

  test('registered feature page routes resolve through GoRouter paths', () {
    FeaturesRegistry.init();

    final featureRouteLocations = _featurePageLocationsFor(
      FeaturesRegistry.getFeatures(),
    );
    final goRoutePaths = _goRouteFullPathsFor(Routes.routes);
    final missing =
        featureRouteLocations
            .where(
              (location) =>
                  !goRoutePaths.any(
                    (routePath) =>
                        routeShellPathMatchesExactly(location, routePath),
                  ),
            )
            .toList();

    expect(featureRouteLocations, isNotEmpty);
    expect(featureRouteLocations, contains('/products/sku-1/edit'));
    expect(missing, isEmpty);
  });

  testWidgets('project detail shortcuts open through app router', (
    tester,
  ) async {
    FeaturesRegistry.init();
    final location = ProjectManagementRoutes.detailPath('retail-modernization');
    final router = GoRouter(initialLocation: location, routes: Routes.routes);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    expect(router.routeInformationProvider.value.uri.path, location);
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('Project not found'), findsNothing);
  });

  testWidgets('renders expanded sidebar beside route content', (tester) async {
    FeaturesRegistry.init();

    await _pumpShell(tester, width: 1280);

    expect(find.text('Kaysir'), findsOneWidget);
    expect(find.text('Workspace'), findsNWidgets(2));
    expect(find.text('Search workspace'), findsOneWidget);
    expect(find.text('Live workspace'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Route content'), findsOneWidget);
  });

  testWidgets('expanded sidebar exposes parent route overview entries', (
    tester,
  ) async {
    FeaturesRegistry.init();

    await _pumpShell(tester, width: 1280);

    expect(find.text('Overview'), findsNothing);

    await tester.tap(find.widgetWithText(ExpansionTile, 'Dashboard'));
    await tester.pumpAndSettle();

    final overviewTile = find.widgetWithText(ListTile, 'Overview');
    expect(overviewTile, findsOneWidget);
    expect(tester.widget<ListTile>(overviewTile).onTap, isNotNull);
    expect(find.text('Project Dashboard'), findsOneWidget);
  });

  testWidgets('expanded sidebar opens the active parent branch', (
    tester,
  ) async {
    FeaturesRegistry.init();

    await _pumpShell(tester, width: 1280, currentLocation: '/projects');

    expect(find.widgetWithText(ExpansionTile, 'Dashboard'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Project Dashboard'), findsOneWidget);
  });

  testWidgets('header shows breadcrumb trail for nested routes', (
    tester,
  ) async {
    FeaturesRegistry.init();

    await _pumpShell(tester, width: 1280, currentLocation: '/projects');

    final breadcrumbs = find.byKey(
      const ValueKey('route-shell-header-breadcrumbs'),
    );
    expect(breadcrumbs, findsOneWidget);
    expect(
      find.descendant(of: breadcrumbs, matching: find.text('Dashboard')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: breadcrumbs,
        matching: find.text('Project Dashboard'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('expanded sidebar marks query shortcut selected', (tester) async {
    FeaturesRegistry.init();

    await _pumpShell(
      tester,
      width: 1280,
      currentLocation: '/accounting?role=auditor',
    );

    final auditorTile = tester.widget<ListTile>(
      find.byKey(
        const ValueKey('route-sidebar-expanded-/accounting?role=auditor'),
      ),
    );
    final workspaceTile = tester.widget<ListTile>(
      find.byKey(const ValueKey('route-sidebar-expanded-/accounting')),
    );

    expect(find.widgetWithText(ExpansionTile, 'Accounting'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey('route-sidebar-expanded-/accounting?role=auditor'),
        ),
        matching: find.text('Auditor Workspace'),
      ),
      findsOneWidget,
    );
    expect(auditorTile.selected, isTrue);
    expect(workspaceTile.selected, isFalse);
  });

  testWidgets('renders compact sidebar on medium widths', (tester) async {
    FeaturesRegistry.init();

    await _pumpShell(tester, width: 920);

    expect(find.byTooltip('Kaysir'), findsOneWidget);
    expect(find.text('Search workspace'), findsOneWidget);
    expect(find.text('Route content'), findsOneWidget);
    expect(find.byTooltip('Open navigation'), findsNothing);
  });

  testWidgets('compact sidebar marks current route selected', (tester) async {
    FeaturesRegistry.init();

    await _pumpShell(tester, width: 920, currentLocation: '/accounting');

    final accountingButton = tester.widget<IconButton>(
      find.byKey(const ValueKey('route-sidebar-compact-/accounting')),
    );

    expect(accountingButton.isSelected, isTrue);
    expect(find.text('Route content'), findsOneWidget);
  });

  testWidgets('compact sidebar marks query shortcut selected', (tester) async {
    FeaturesRegistry.init();

    await _pumpShell(
      tester,
      width: 920,
      currentLocation: '/accounting?role=auditor',
    );

    final auditorButton = tester.widget<IconButton>(
      find.byKey(
        const ValueKey('route-sidebar-compact-/accounting?role=auditor'),
      ),
    );
    final workspaceButton = tester.widget<IconButton>(
      find.byKey(const ValueKey('route-sidebar-compact-/accounting')),
    );

    expect(auditorButton.isSelected, isTrue);
    expect(workspaceButton.isSelected, isFalse);
    expect(find.text('Route content'), findsOneWidget);
  });

  testWidgets('opens workspace route search from the header', (tester) async {
    FeaturesRegistry.init();

    await _pumpShell(tester, width: 1280);

    await tester.tap(find.text('Search workspace'));
    await tester.pumpAndSettle();

    expect(find.byType(RouteSearchDialog), findsOneWidget);
    expect(find.text('Find workspace route'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'website');
    await tester.pumpAndSettle();

    final dialog = find.byType(RouteSearchDialog);
    expect(
      find.descendant(of: dialog, matching: find.text('Website Builder')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Cashier')),
      findsNothing,
    );
  });

  testWidgets('opens workspace route search from command shortcuts', (
    tester,
  ) async {
    FeaturesRegistry.init();

    await _pumpShell(tester, width: 1280);
    await tester.pump();

    await _pressShortcut(tester, LogicalKeyboardKey.metaLeft);

    expect(find.byType(RouteSearchDialog), findsOneWidget);
    expect(find.text('Find workspace route'), findsOneWidget);

    await tester.tap(find.byTooltip('Close search'));
    await tester.pumpAndSettle();

    await _pressShortcut(tester, LogicalKeyboardKey.controlLeft);

    expect(find.byType(RouteSearchDialog), findsOneWidget);
    expect(find.text('Find workspace route'), findsOneWidget);
  });

  testWidgets('uses drawer navigation on small widths', (tester) async {
    FeaturesRegistry.init();

    await _pumpShell(tester, width: 640);

    expect(find.byTooltip('Open navigation'), findsOneWidget);
    expect(find.byTooltip('Search workspace'), findsOneWidget);
    expect(find.text('Route content'), findsOneWidget);
    expect(find.text('Kaysir'), findsNothing);

    await tester.tap(find.byTooltip('Search workspace'));
    await tester.pumpAndSettle();

    expect(find.byType(RouteSearchDialog), findsOneWidget);

    await tester.tap(find.byTooltip('Close search'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();

    expect(find.text('Kaysir'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}

Future<void> _pumpShell(
  WidgetTester tester, {
  required double width,
  double height = 820,
  String? currentLocation,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: AppRouteShell(
        currentLocation: currentLocation,
        child: const Center(child: Text('Route content')),
      ),
    ),
  );
}

Future<void> _pressShortcut(
  WidgetTester tester,
  LogicalKeyboardKey modifier,
) async {
  await tester.sendKeyDownEvent(modifier);
  await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(modifier);
  await tester.pumpAndSettle();
}

Set<String> _featurePageLocationsFor(List<FeatureRoutes> routes) {
  final locations = <String>{};

  void visit(FeatureRoutes route) {
    final path = route.path?.trim();
    final hasPage =
        path != null &&
        path.isNotEmpty &&
        (route.pageBuilder != null || route.builder != null || route.child != null);
    if (hasPage) locations.add(_sampleLocationFor(path));

    for (final child in route.items) {
      visit(child);
    }
  }

  for (final route in routes) {
    visit(route);
  }

  return locations;
}

Set<String> _goRouteFullPathsFor(List<RouteBase> routes) {
  final paths = <String>{};

  void visit(RouteBase route, String parentPath) {
    if (route is GoRoute) {
      final fullPath = _joinGoRoutePaths(parentPath, route.path);
      paths.add(fullPath);
      for (final child in route.routes) {
        visit(child, fullPath);
      }
      return;
    }

    if (route is ShellRoute) {
      for (final child in route.routes) {
        visit(child, parentPath);
      }
    }
  }

  for (final route in routes) {
    visit(route, '');
  }

  return paths;
}

String _sampleLocationFor(String path) {
  final uri = Uri.parse(path);
  final sampledSegments = [
    for (final segment in uri.pathSegments)
      if (segment.startsWith(':')) _samplePathParameterFor(segment) else segment,
  ];

  return uri.replace(pathSegments: sampledSegments).toString();
}

String _samplePathParameterFor(String segment) {
  final name = segment.substring(1);
  if (name.toLowerCase().contains('id')) return 'sku-1';
  return 'sample';
}

String _joinGoRoutePaths(String parentPath, String childPath) {
  final child = childPath.trim();
  if (child.startsWith('/')) return child;

  final parent = parentPath.trim();
  final childSegment = child.replaceFirst(RegExp(r'^/+'), '');
  if (parent.isEmpty || parent == '/') return '/$childSegment';

  return '${parent.replaceFirst(RegExp(r'/+$'), '')}/$childSegment';
}
