import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/features/feature_routes.dart';

import '../app/screens/auth/login.dart';

import '../features/dashboard/screens/dashboard_main.dart';

List<FeatureRoutes> registerScreens() => [
  FeatureRoutes(
    name: 'Dashboard',
    path: '/dashboard',
    pageBuilder: (BuildContext context, GoRouterState state) {
      return MaterialPage(child: DashboardMainScreen());
    },
  ),
  FeatureRoutes(
    name: 'Login',
    path: '/login',
    pageBuilder: (BuildContext context, GoRouterState state) {
      return MaterialPage(child: LoginScreen());
    },
  ),
  /* FeatureRoutes(
    name: 'Accounting',
    items: [
      FeatureRoutes(
        name: 'Report',
        path: '/report',
        screenType: ScreenType.singlePage,
        pageBuilder:
            (BuildContext context, GoRouterState state) =>
                MaterialPage(child: ReportScreen()),
      ),
      FeatureRoutes(
        name: 'Fincancial Report',
        path: '/finreport',
        screenType: ScreenType.singlePage,
        pageBuilder:
            (BuildContext context, GoRouterState state) =>
                MaterialPage(child: ReportScreen()),
      ),
      FeatureRoutes(
        name: 'General Ledger',
        path: '/gl',
        pageBuilder:
            (BuildContext context, GoRouterState state) =>
                MaterialPage(child: GLScreen()),
      ),
    ],
  ), */

  // Point of Sales (PoS)

  /* FeatureRoutes(
    name: 'Project',
    items: [
      FeatureRoutes(
        name: 'Projects',
        path: '/projects',
        pageBuilder:
            (BuildContext context, GoRouterState state) =>
                MaterialPage(child: ProjectScreen()),
      ),
      FeatureRoutes(
        name: 'Gantt Chart',
        path: '/gantt',
        pageBuilder:
            (BuildContext context, GoRouterState state) =>
                MaterialPage(child: GanttChartScreen()),
      ),
    ],
  ), */
];
