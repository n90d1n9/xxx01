import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/navigation_provider.dart';
import '../../features/auth_states/auth_notifier.dart';
import 'all_path.dart';

FutureOr<String?> redirect(
  BuildContext context,
  GoRouterState state,
  Ref ref,
) async {
  final authState = ref.watch(authProvider);

  // Delay navigation state update until after build phase
  Future.microtask(() {
    ref.read(navigationProvider.notifier).setCurrentPath(state.matchedLocation);
  });

  // Onboarding: if first time, always go to onboarding unless already there
  /*   if (authState.isFirstTime && state.fullPath != PathApps.onboard) {
    return PathApps.onboard;
  }
  if (!authState.isFirstTime && state.fullPath == PathApps.onboard) {
    return PathApps.home;
  }
 */
  /*   final isOnboardingOrSplashOrGuest = [
    PathApps.splash,
    PathApps.onboard,
    PathApps.guest,
  ].contains(state.fullPath); */

  // If not authenticated and not on onboarding/splash/guest, redirect to guest
  /*   if (!authState.isAuthenticated && !isOnboardingOrSplashOrGuest) {
    return PathApps.guest;
  } */

  // Authenticated, trying to access login or onboard
  if (authState.isAuthenticated &&
      (state.fullPath == PathAuth.login ||
          state.fullPath == PathApps.onboard)) {
    return PathApps.home;
  }

  // Otherwise, no redirect
  return null;
}
