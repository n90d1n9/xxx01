import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:queue_ui/kitchen/menu.dart';

import '../screens/analytic_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../states/auth_provider.dart';
import '../widgets/bottom.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // Use ProviderContainer to read the current auth state
      final container = ProviderContainer();
      final authState = container.read(AuthService.authProvider);

      final loginLocation = state.matchedLocation == '/login';
      final isAuthenticated = true; //authState.isAuthenticated;
      print('isAuthenticated $isAuthenticated  loginloc: $loginLocation');
      // If not authenticated, redirect to login
      if (!isAuthenticated && !loginLocation) return '/login';

      // If authenticated and on login page, redirect to dashboard
      if (isAuthenticated && loginLocation) return '/dashboard';

      return null;
    },
    routes: [
      // Login Route
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // Main Shell Route with Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder:
            (context, state, navigationShell) =>
                ScaffoldWithBottomNavBar(navigationShell: navigationShell),
        branches: [
          // Dashboard Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Analytics Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),

          // Settings Branch
          /*  StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ), */
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const MenuManagementScreen(),
              ),
            ],
          ),
        ],
      ),
      /* GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
        redirect: (context, state) {
          final authRepository = GoRouterProvider.of(context).authRepositoryProvider.read(context);
          return authRepository.hasPermission([UserRole.admin]) 
            ? null 
            : '/unauthorized';
        },
      ),
      GoRoute(
        path: '/manager-dashboard',
        builder: (context, state) => const ManagerDashboardScreen(),
        redirect: (context, state) {
          final authRepository = GoRouterProvider.of(context).authRepositoryProvider.read(context);
          return authRepository.hasPermission([UserRole.manager, UserRole.admin]) 
            ? null 
            : '/unauthorized';
        },
      ),
      GoRoute(
        path: '/user-dashboard',
        builder: (context, state) => const UserDashboardScreen(),
        redirect: (context, state) {
          final authRepository = GoRouterProvider.of(context).authRepositoryProvider.read(context);
          return authRepository.hasPermission([UserRole.user, UserRole.manager, UserRole.admin]) 
            ? null 
            : '/unauthorized';
        },
      ), */
    ],
  );
}
