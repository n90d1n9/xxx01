// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_services.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<GoogleSignInAccount?>>(
        (ref) {
  return AuthStateNotifier(ref.watch(authServiceProvider));
});

class AuthStateNotifier
    extends StateNotifier<AsyncValue<GoogleSignInAccount?>> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signIn() async {
    state = const AsyncValue.loading();
    try {
      final account = await _authService.signIn();
      state = AsyncValue.data(account);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }
}
