import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../services/local_database/local_storage_service.dart';
import '../../../services/network/rest/rest_services.dart';
import '../../../config/config.dart';

import '../../models/auth/auth_response.dart';
import '../../models/auth/user.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthenticationState>((
  ref,
) {
  return AuthNotifier(ref);
});

// Update the AuthNotifier with additional methods
class AuthNotifier extends StateNotifier<AuthenticationState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthenticationState.initial()) {
    _init();
  }

  Future<void> _init() async {
    await LocalDBService.initialize(encryptionPassword: 'your-secure-password');
    final isFirstTime =
        await LocalDBService.getPreference(key: isFirstTimeKey) ?? true;

    final isAuthenticated =
        await LocalDBService.getSecret(key: tokenKey) ?? true;

    state = state.copyWith(
      isFirstTime: isFirstTime,
      isAuthenticated: isAuthenticated,
      isLoading: false,
    );
  }

  Future<void> setFirstTimeCompleted() async {
    state = state.copyWith(isFirstTime: false);
  }

  Future<void> signOut() async {
    state = state.copyWith(isAuthenticated: false);
  }

  Future<void> signIn(String username, String password, bool rememberMe) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await RestClientService.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        LocalDBService.saveSecret(key: tokenKey, value: response.data['token']);
        LocalDBService.saveSecret(
          key: refreshTokenKey,
          value: response.data['refresh_token'],
        );

        final user = User.fromMap(response.data['user']);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          loggedIn: true,
        );

        state = state.copyWith(isAuthenticated: true);
      }
    } catch (e) {
      state = state.copyWith(
        hasErrorsInLogin: true,
        loginMessage: 'Invalid credentials',
      );
    }
  }

  Future<void> refreshToken() async {
    if (state.token == null) return;

    try {
      final response = await RestClientService.post('/auth/refresh-token');

      if (response.statusCode == 200) {
        AuthResponse.fromJson(response.data);
      }

      if (response != null && response.token != null) {
        if (state.rememberMe) {
          await LocalDBService.saveSecret(
            key: tokenKey,
            value: response.token!,
          );
        }

        state = state.copyWith(
          token: response.token,
          user: response.user ?? state.user,
        );
      } else {
        // If refresh fails, logout the user
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  // Get user profile
  Future<User?> getUserProfile() async {
    final response = await RestClientService.get('/users/profile');

    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    }
    return null;
  }

  // Check if token is valid
  Future<bool> validateToken() async {
    final response = await RestClientService.get('/auth/validate-token');
    return response.statusCode == 200;
  }

  void updateUsername(String username) {
    state = state.copyWith(
      username: username,
      loginMessage: null,
      hasErrorsInLogin: false,
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      password: password,
      passwordMessage: null,
      hasErrorsInLogin: false,
    );
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordMessage: null,
    );
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  Future<void> forgotPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true);

      await RestClientService.post(
        '/account/reset-password/init',
        data: {'email': email},
      );

      state = state.copyWith(isLoading: false, hasErrorInForgotPassword: false);
    } catch (e) {
      state = state.copyWith(
        hasErrorInForgotPassword: true,
        loginMessage: 'Error resetting password',
      );
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await RestClientService.post(
        '/register',
        data: {'username': username, 'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        state = state.copyWith(isLoading: false, hasErrorsInLogin: false);
      }
    } catch (e) {
      state = state.copyWith(
        hasErrorsInLogin: true,
        loginMessage: 'Error during registration',
      );
    }
  }

  Future<void> checkAuth() async {
    try {
      final token = await LocalDBService.getSecret(key: tokenKey);
      if (token != null) {
        final response = await RestClientService.get('/account');
        if (response.statusCode == 200) {
          final user = User.fromMap(response.data);
          state = state.copyWith(user: user, loggedIn: true, token: token);
        }
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    await LocalDBService.deleteSecret(key: tokenKey);
    state = AuthenticationState.initial();
  }

  String messagePassword(context) {
    switch (state.passwordMessage) {
      case "confirm":
        return AppLocalizations.of(context)!.passwordConfirm;
      case "empty":
        return AppLocalizations.of(context)!.passwordEmpty;
      case "length":
        return AppLocalizations.of(context)!.passwordLength;
      case "match":
        return AppLocalizations.of(context)!.passwordMatch;
      default:
        return "";
    }
  }

  message(context) {
    switch (state.errorMessage) {
      case "unauthorized":
        state.copyWith(
          errorMessage: AppLocalizations.of(context)!.errorUnauthorized,
        );
        break;
      case "username":
        state.copyWith(
          errorMessage: AppLocalizations.of(context)!.errorUsername,
        );
        return AppLocalizations.of(context)!.errorUsername;
      default:
        state.copyWith(
          errorMessage: AppLocalizations.of(context)!.errorNetwork,
        );
        return AppLocalizations.of(context)!.errorNetwork;
    }
  }
}
