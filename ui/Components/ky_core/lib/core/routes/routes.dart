import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../transitions/fade_transition.dart';
import '../../transitions/slide_transition.dart';
import 'route_diagnostics_screen.dart';
import 'navigation_provider.dart';
import '../features/features_provider.dart';

export 'navigation_provider.dart';

/// Provider for external redirection logic provided by the UI layer
final externalRedirectProvider = Provider<GoRouterRedirect?>((ref) => null);

class RouteDiagnosticsSnapshot {
  final List<String> paths;
  final Map<String, String> namedRoutes;
  final int totalRoutes;
  final int totalBranches;
  final DateTime generatedAt;

  const RouteDiagnosticsSnapshot({
    required this.paths,
    required this.namedRoutes,
    required this.totalRoutes,
    required this.totalBranches,
    required this.generatedAt,
  });
}

typedef RouteGuard = FutureOr<String?> Function(
  BuildContext context,
  GoRouterState state,
  Ref? ref,
);

class RouteGuardEntry {
  final String name;
  final String group;
  final int priority;
  final bool enabled;
  final RouteGuard guard;

  const RouteGuardEntry({
    required this.name,
    required this.guard,
    this.group = 'default',
    this.priority = 0,
    this.enabled = true,
  });
}

class RouteGuardPipeline {
  static Future<String?> evaluate(
    List<RouteGuardEntry> entries,
    BuildContext context,
    GoRouterState state,
    Ref? ref, {
    Set<String> enabledGroups = const {},
  }) async {
    final active = entries
        .where(
          (entry) =>
              entry.enabled &&
              (enabledGroups.isEmpty || enabledGroups.contains(entry.group)),
        )
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    for (final entry in active) {
      final redirectPath = await entry.guard(context, state, ref);
      if (redirectPath != null && redirectPath.isNotEmpty) {
        return redirectPath;
      }
    }
    return null;
  }
}

/// GoRouter provider - optimized to prevent rebuild loops
/// Uses ref.read for navState to avoid rebuilding router on every navigation
final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch feature routes - these are stable
  final featureRoutes = ref.watch(featureRoutesProvider);
  final featureBranches = ref.watch(featureBranchesProvider);

  // Read navState without watching - prevents router rebuild on navigation state changes
  final navState = ref.read(navigationProvider);

  return Routes.config(
    ref: ref,
    navState: navState,
    featureRoutes: featureRoutes,
    featureBranches: featureBranches,
    redirect: ref.watch(externalRedirectProvider),
  );
});

class Routes {
  static final Routes _singleton = Routes._();

  Routes._();

  factory Routes() => _singleton;

  static final _registry = _RouteRegistry();

  static Future<Routes> get instance async {
    return _singleton;
  }

  static List<RouteBase> get routes => _registry.routes;

  static List<StatefulShellBranch> get branches => _registry.branches;

  static void addRoutes(List<GoRoute> newRoutes) {
    _registry.addRoutes(newRoutes);
  }

  static void addBranches(List<StatefulShellBranch> newBranches) {
    _registry.addBranches(newBranches);
  }

  static void clearRoutes() {
    _registry.clearRoutes();
  }

  static void clearBranches() {
    _registry.clearBranches();
  }

  static List<String> getAllPaths() {
    return _registry.getAllPaths();
  }

  static Map<String, String> getAllNamedRoutes() {
    return _registry.getAllNamedRoutes();
  }

  static RouteDiagnosticsSnapshot diagnostics() {
    return RouteDiagnosticsSnapshot(
      paths: _registry.getAllPaths(),
      namedRoutes: _registry.getAllNamedRoutes(),
      totalRoutes: _registry.routes.length,
      totalBranches: _registry.branches.length,
      generatedAt: DateTime.now(),
    );
  }

  static GoRouter config({
    Ref? ref,
    NavigationState? navState,
    List<RouteBase> featureRoutes = const [],
    List<StatefulShellBranch> featureBranches = const [],
    bool debugLogDiagnostics = false,
    String initial = '/',
    bool isLoggedIn = true,
    GoRouterRedirect? redirect,
    List<String> publicRoutes = const [
      '/splash',
      '/onboard',
      '/login',
      '/register',
      '/forgotpassword',
      '/verify-otp',
      '/reset-password',
      '/home',
    ],
    List<RouteGuard> guards = const [],
    List<RouteGuardEntry> guardEntries = const [],
    Set<String> enabledGuardGroups = const {},
    GlobalKey<NavigatorState>? navigatorKey,
    List<NavigatorObserver>? observers,
    bool includeDiagnosticsRoutes = false,
    String diagnosticsPath = '/__routes__',
  }) {
    final navKey = navigatorKey ?? GlobalKey<NavigatorState>();

    final mainScreenBuilder = navState?.shellBuilder;
    final branchScreens = navState?.initialBranches;

    // Use fixed initial location - don't use navState.currentPath as it can cause loops
    // The RootScreen will handle navigation after splash
    String initialLocation = initial;

    debugPrint(
      'DEBUG: Routes.config called with '
      '${featureRoutes.length} featureRoutes and '
      '${featureBranches.length} featureBranches',
    );

    // NEW: Trace all paths in featureRoutes
    for (var route in featureRoutes) {
      if (route is GoRoute) {
        debugPrint('DEBUG: Registered Route: ${route.path}');
      }
    }

    final allBranches = [
      if (branchScreens != null) ...branchScreens,
      ...featureBranches,
      ..._registry.branches,
    ];

    final diagnosticsRoutes = includeDiagnosticsRoutes
        ? [
            GoRoute(
              path: diagnosticsPath,
              builder: (context, state) => const RouteDiagnosticsScreen(),
            ),
          ]
        : <RouteBase>[];

    final dedupedRoutes = _registry.mergeRoutes([
      ...featureRoutes,
      ...diagnosticsRoutes,
    ]);

    return GoRouter(
      navigatorKey: navKey,
      initialLocation: initialLocation,
      debugLogDiagnostics: debugLogDiagnostics,
      observers: observers ?? [HeroController()],
      redirect: (context, state) async {
        if (redirect != null) {
          return redirect(context, state);
        }

        if (ref == null) return null;

        // Use custom redirect if provided
        final customRedirect = navState?.redirect;
        if (customRedirect != null) {
          return customRedirect(context, state, ref);
        }

        final currentPath = state.matchedLocation;

        if (_isPublicRoute(currentPath, publicRoutes)) {
          return null;
        }

        // ignore: use_build_context_synchronously
        if (guardEntries.isNotEmpty) {
          // ignore: use_build_context_synchronously
          final redirectPath = await RouteGuardPipeline.evaluate(
            guardEntries,
            context,
            state,
            ref,
            enabledGroups: enabledGuardGroups,
          );
          if (redirectPath != null && redirectPath.isNotEmpty) {
            return redirectPath;
          }
        }

        for (final guard in guards) {
          // ignore: use_build_context_synchronously
          final redirectPath = await guard(context, state, ref);
          if (redirectPath != null && redirectPath.isNotEmpty) {
            return redirectPath;
          }
        }

        return null;
      },
      routes: [
        ...dedupedRoutes,
        if (allBranches.isNotEmpty)
          StatefulShellRoute.indexedStack(
            parentNavigatorKey: navKey,
            builder: (context, state, navigationShell) {
              if (mainScreenBuilder != null) {
                return mainScreenBuilder(context, state, navigationShell);
              }
              // Fallback screen if no shell builder is provided
              return Scaffold(body: navigationShell);
            },
            branches: allBranches,
          ),
        if (_registry.isEmpty && featureRoutes.isEmpty && allBranches.isEmpty)
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('No routes configured [v2]')),
            ),
          ),
      ],
      errorBuilder: (context, state) {
        // Handle routing errors gracefully
        debugPrint('Route error: ${state.error}');

        final customErrorBuilder = navState?.errorBuilder;
        if (customErrorBuilder != null) {
          return customErrorBuilder(context, state);
        }

        return DefaultNotFoundScreen(state: state);
      },
    );
  }

  static StatefulShellBranch shellBranch(
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

  static GoRoute pageWithGuards(
    String path,
    Widget page, {
    String? name,
    List<RouteGuard> guards = const [],
  }) {
    return GoRoute(
      name: name,
      path: path,
      redirect: (context, state) async {
        for (final guard in guards) {
          final redirectPath = await guard(context, state, null);
          if (redirectPath != null && redirectPath.isNotEmpty) {
            return redirectPath;
          }
        }
        return null;
      },
      builder: (context, state) => page,
    );
  }

  static GoRoute pageNamed(
    String name,
    String path,
    Widget page, {
    List<RouteGuard> guards = const [],
  }) {
    return pageWithGuards(
      path,
      page,
      name: name,
      guards: guards,
    );
  }
}

class _RouteRegistry {
  final List<RouteBase> _routes = [];
  final List<StatefulShellBranch> _branches = [];
  final Set<String> _paths = {};
  final Set<String> _names = {};

  List<RouteBase> get routes => _routes;
  List<StatefulShellBranch> get branches => _branches;
  bool get isEmpty => _routes.isEmpty && _branches.isEmpty;

  void addRoutes(List<GoRoute> routes) {
    for (final route in routes) {
      final path = route.path;
      final name = route.name;
      if (_paths.contains(path)) {
        debugPrint('DEBUG: Duplicate route path skipped: $path');
        continue;
      }
      if (name != null && _names.contains(name)) {
        debugPrint('DEBUG: Duplicate route name skipped: $name');
        continue;
      }
      _paths.add(path);
      if (name != null) _names.add(name);
      _routes.add(route);
    }
  }

  void addBranches(List<StatefulShellBranch> branches) {
    _branches.addAll(branches);
  }

  void clearRoutes() {
    _routes.clear();
    _paths.clear();
    _names.clear();
  }

  void clearBranches() {
    _branches.clear();
  }

  List<String> getAllPaths() {
    return _paths.toList()..sort();
  }

  Map<String, String> getAllNamedRoutes() {
    final mapped = <String, String>{};
    for (final route in _routes) {
      if (route is GoRoute) {
        final name = route.name;
        if (name != null) {
          mapped[name] = route.path;
        }
      }
    }
    return mapped;
  }

  List<RouteBase> mergeRoutes(List<RouteBase> featureRoutes) {
    final merged = <RouteBase>[];
    merged.addAll(_routes);
    merged.addAll(featureRoutes);
    return merged;
  }
}

bool _isPublicRoute(String currentPath, List<String> publicRoutes) {
  for (final route in publicRoutes) {
    if (route.endsWith('/*')) {
      final prefix = route.substring(0, route.length - 2);
      if (currentPath == prefix || currentPath.startsWith('$prefix/')) {
        return true;
      }
    } else if (currentPath == route || currentPath.startsWith('$route/')) {
      return true;
    }
  }
  return false;
}

// Custom screen for 404/Route errors
class DefaultNotFoundScreen extends StatelessWidget {
  final GoRouterState? state;
  const DefaultNotFoundScreen({super.key, this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Route not found: ${state?.matchedLocation ?? "Unknown"}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
