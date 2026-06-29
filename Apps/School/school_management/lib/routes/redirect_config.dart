import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/states/auth/auth_provider.dart';

FutureOr<String?> redirect(
  BuildContext context,
  GoRouterState state,
  WidgetRef ref,
) {
  // Get authentication state
  final authState = ref.watch(authProvider);

  print(state.fullPath);
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
}
