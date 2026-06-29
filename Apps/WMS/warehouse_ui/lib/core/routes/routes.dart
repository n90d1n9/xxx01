import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/app_module.dart';
import '../../layout/main_layout_screen.dart';
import '../../features/auth/screens/forgot_password_page.dart';
import '../../features/home/screens/home.dart';
import '../../features/intro/screens/intro_screen.dart';
import '../../features/auth/screens/login.dart';
import '../../features/register/register_page.dart';
import '../../features/splash/screens/splash.dart';
import '../../features/auth/states/auth_provider.dart';
import '../../shared/widgets/error/error_404.dart';
import '../../shared/widgets/transitions/fade_transition.dart';
import 'router_observer.dart';

class Routes {
  static final Routes _singleton = Routes._();

  Routes._();

  factory Routes() => _singleton;

  static final List<RouteBase> _goroutes = [];

  static final List<StatefulShellBranch> _branches = [];

  static Future<Routes> get instance async {
    _goroutes.addAll(AppModule().goroutes());
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

  static GoRouter config(
      {WidgetRef? ref,
      String initial = '/',
      bool debugLog = true,
      bool isLoggedIn = true}) {
    final authState = ref!.watch(authProvider);
    return GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      initialLocation: initial,
      debugLogDiagnostics: debugLog,
      // Navigation observers
      observers: [RouterObserver()],
      // Redirect logic
      redirect: (context, state) async {

        //return '/splash';
        // final isLoggedIn = ref!.read(authProvider).loggedIn;
        /*  final isGoingToAuth = state.fullPath == '/sign-in' ||
            state.fullPath == '/register' ||
            state.fullPath == '/forgot-password'; */
        if (authState.isLoading) {
          return null;
        }
        final isIntroduction = state.fullPath == '/introduction';
        final isSplash = state.fullPath == '/splash';
        final isSignIn = state.fullPath == '/signin';
        final isRegister = state.fullPath == '/register';
        final isForgotPassword = state.fullPath == '/forgot-password';
        final isHome = state.fullPath == '/home';

        // Handle first time user
        if (authState.isFirstTime && !isIntroduction) {
          return '/introduction';
        }

        // Handle authenticated user
        //if (authState.isAuthenticated) {
          if (!isHome) return '/home';
         // return null;
        //}

        // Handle non-authenticated user
        if (!authState.isAuthenticated) {
          if (isHome) return '/signin';
          if (!isSignIn &&
              !isRegister &&
              !isForgotPassword &&
              !isSplash &&
              !isIntroduction) {
            return '/signin';
          }
          return null;
        }

        return null;
      },
      routes: [
        /* GoRoute(
          path: '/',
          redirect: (_, __) => '/splash',
        ), */
        GoRoute(
          path: '/splash',
          builder: (BuildContext context, GoRouterState state) =>
              const SplashScreen(),
        ),
        GoRoute(
          path: '/introduction',
          builder: (context, state) => const IntroductionScreen(),
        ),
        GoRoute(
          path: '/signin',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),

        // All others features routes
        ..._goroutes,

        StatefulShellRoute.indexedStack(
            builder: (BuildContext context, GoRouterState state,
                StatefulNavigationShell navigationShell) {
              return MainLayoutScreen(navigationShell: navigationShell);
            },
            branches: [
              Routes.shellBranch('main', '/', const HomePage()),
              ..._branches
            ]),
      ],
      errorBuilder: (context, state) => NotFoundScreen(
        state: state,
      ),
    );
  }

  static shellBranch(String name, String path, Widget child,
      [List<RouteBase>? routes]) {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    return StatefulShellBranch(navigatorKey: navigatorKey, routes: [
      GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          return MaterialPage(child: child);
        }, /* routes: routes! */
      ),
    ]);
  }

  static GoRoute page(String path, Widget page) {
    return GoRoute(
      path: path,
      builder: (context, state) => page,
    );
  }

  static GoRoute pageNoTrans(String path, Widget page) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => NoTransitionPage(
        child: page,
      ),
    );
  }

  static GoRoute pageFadeTrans(String path, Widget page) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => FadeTransitionPage(child: page),
    );
  }
}
