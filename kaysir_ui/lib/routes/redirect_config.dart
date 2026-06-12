import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/states/auth/auth_provider.dart';
import '../app/states/auth/auth_state.dart';

const String dashboardRoute = '/dashboard';
const String loginRoute = '/login';

FutureOr<String?> redirect(
  BuildContext context,
  GoRouterState state,
  WidgetRef ref,
) {
  final authState = ref.watch(authProvider);
  return resolveRedirectPath(authState, state.uri.path);
}

String? resolveRedirectPath(AuthenticationState authState, String path) {
  if (authState.isLoading) {
    return null;
  }

  final normalizedPath = path.isEmpty ? '/' : path;
  final isLogin = normalizedPath == loginRoute;

  if (authState.isAuthenticated) {
    if (isLogin) return dashboardRoute;
    return null;
  }

  return isLogin ? null : loginRoute;
}
