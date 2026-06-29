import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/features/feature_routes.dart';
import '../../app/screens/main/main_home_screen.dart';

import 'all_path.dart';

List<FeatureRoutes> appsRoutes = [
  FeatureRoutes(
    name: 'SplashToHome',
    path: PathApps.splashToHome,
    screenType: ScreenType.singlePage,
    pageBuilder: (BuildContext context, GoRouterState state) {
      return const MaterialPage(child: MainHomeScreen());
    },
  ) /* 
  FeatureRoutes(
    name: 'Splash',
    path: PathApps.splash,
    screenType: ScreenType.singlePage,
    pageBuilder: (BuildContext context, GoRouterState state) {
      return const MaterialPage(child: SplashScreen());
    },
  ),
  FeatureRoutes(
    name: 'Onboard',
    path: PathApps.onboard,
    screenType: ScreenType.singlePage,
    pageBuilder: (BuildContext context, GoRouterState state) {
      return const MaterialPage(child: OnboardingScreen());
    },
  ),


  FeatureRoutes(
    name: 'Forbidden',
    path: PathApps.inbox,
    screenType: ScreenType.branch,
    pageBuilder: (BuildContext context, GoRouterState state) =>
        const MaterialPage(child: ForbiddenScreen()),
  ), */,
];
