import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/screens/main_screen.dart';
import '../../features/dashboard/screens/dashboard_main.dart';
import '../../routes/redirect_config.dart';

import '../../app/widgets/error/error_404.dart';
import '../../app/widgets/transitions/fade_transition.dart';
import 'router_observer.dart';

class Routes {
  static final Routes _singleton = Routes._();

  Routes._();

  factory Routes() => _singleton;

  static final List<RouteBase> _goroutes = [];

  static final List<StatefulShellBranch> _branches = [];

  static Future<Routes> get instance async {
    return _singleton;
  }

  static get routes => _goroutes;

  static List<StatefulShellBranch> get branches => _branches;

  static addRoutes(List<GoRoute> newRoutes) {
    _goroutes.addAll(newRoutes);
  }

  static addBranches(List<StatefulShellBranch> newBranches) {
    _branches.addAll(newBranches);
  }

  static GoRouter config({
    WidgetRef? ref,
    String initial = '/',
    bool debugLog = true,
    bool isLoggedIn = true,
  }) {
    GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
    return GoRouter(
      navigatorKey: navKey,
      initialLocation: initial,
      debugLogDiagnostics: debugLog,
      // Navigation observers
      observers: [RouterObserver()],
      // Redirect logic
      redirect: (context, state) async {
        return redirect(context, state, ref!);
      },
      routes: [
        // All others features routes
        ..._goroutes,

        StatefulShellRoute.indexedStack(
          parentNavigatorKey: navKey,
          builder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return MainScreen(navigationShell: navigationShell);
          },
          branches: [
            Routes.shellBranch('main', '/', const DashboardMainScreen()),
            ..._branches,
          ],
        ),
      ],
      errorBuilder: (context, state) => NotFoundScreen(state: state),
    );
  }

  static shellBranch(
    String name,
    String path,
    Widget child, [
    List<RouteBase>? routes,
  ]) {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    return StatefulShellBranch(
      navigatorKey: navigatorKey,
      routes: [
        GoRoute(
          name: name,
          path: path,
          pageBuilder: (context, state) {
            return MaterialPage(child: child);
          } /* routes: routes! */,
        ),
      ],
    );
  }

  static GoRoute page(String path, Widget page) {
    return GoRoute(path: path, builder: (context, state) => page);
  }

  static GoRoute pageNoTrans(String path, Widget page) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => NoTransitionPage(child: page),
    );
  }

  static GoRoute pageFadeTrans(String path, Widget page) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => FadeTransitionPage(child: page),
    );
  }
}
