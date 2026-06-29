import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/screens/main/main_home_screen.dart';
import '../../app/screens/main/main_screen.dart';
import '../../config/routes/redirect_config.dart';
import 'navigation_provider.dart';
import '../../widgets/transitions/slide_transition.dart';
import '../../config/routes/all_path.dart';
import '../../widgets/error/error_404.dart';
import '../../widgets/transitions/fade_transition.dart';

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
    Ref? ref,
    usedDebugLog = false,
    String initial = PathApps.home,
    bool isLoggedIn = true,
  }) {
    GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

    return GoRouter(
      navigatorKey: navKey,
      initialLocation: initial,
      debugLogDiagnostics: usedDebugLog,
      observers: [HeroController()],
      redirect: (context, state) async {
        if (ref == null) return null;
        try {
          return redirect(context, state, ref);
        } catch (e) {
          // Handle redirect errors gracefully
          debugPrint('Redirect error: $e');
          return null;
        }
      },
      routes: [
        ..._goroutes,
        StatefulShellRoute.indexedStack(
          parentNavigatorKey: navKey,
          builder:
              (
                BuildContext context,
                GoRouterState state,
                StatefulNavigationShell navigationShell,
              ) {
                return MainScreen(navigationShell: navigationShell);
              },
          branches: [
            Routes.shellBranch('main', PathApps.home, const MainHomeScreen()),
            ..._branches,
          ],
        ),
      ],
      errorBuilder: (context, state) {
        // Handle routing errors gracefully
        debugPrint('Route error: ${state.error}');
        return NotFoundScreen(state: state);
      },
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

  static StatefulShellBranch shellBranchWithTransition(
    String name,
    String path,
    Widget child,
    WidgetRef ref, [
    List<RouteBase>? routes,
  ]) {
    final transitionType = ref.read(navigationProvider);
    GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    return StatefulShellBranch(
      navigatorKey: navigatorKey,
      routes: [
        GoRoute(
          name: name,
          path: path,
          pageBuilder: (context, state) {
            switch (transitionType.transitionType) {
              case TransitionType.slide:
                return SlideTransitionPage(child: child);
              case TransitionType.fade:
                return FadeTransitionPage(child: child);
              case TransitionType.none:
                return NoTransitionPage(child: child);
            }
          },
          routes: routes ?? [],
        ),
      ],
    );
  }

  Page<dynamic> transitionPage(Widget child, TransitionType transitionType) {
    switch (transitionType) {
      case TransitionType.slide:
        return SlideTransitionPage(child: child);
      case TransitionType.fade:
        return FadeTransitionPage(child: child);
      case TransitionType.none:
        return NoTransitionPage(child: child);
    }
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

  static GoRoute pageSlideTrans(String path, Widget page) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => SlideTransitionPage(child: page),
    );
  }
}
