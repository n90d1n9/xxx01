import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/widgets.dart';

import '../../../config/translations/app_localizations.dart';
import '../../../services/local_database/local_storage_service.dart';
import '../../../services/network/rest/rest_services.dart';
import '../../../config/config.dart';

import '../../models/auth/auth_response.dart';
import '../../models/auth/user.dart';
import '../../services/demo_profile_service.dart';
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
    final storedFirstTime = await LocalDBService.getPreference(
      key: isFirstTimeKey,
    );
    final storedToken = await LocalDBService.getSecret(key: tokenKey);

    final token = storedToken?.toString();
    final hasToken = token != null && token.isNotEmpty;

    if (offlineMode) {
      await _activateDemoProfile(
        isFirstTime: storedFirstTime is bool ? storedFirstTime : true,
      );
      return;
    }

    state = state.copyWith(
      token: token,
      loggedIn: hasToken,
      isFirstTime: storedFirstTime is bool ? storedFirstTime : true,
      isAuthenticated: hasToken,
      isLoading: false,
    );
  }

  Future<void> setFirstTimeCompleted() async {
    await LocalDBService.savePreference(key: isFirstTimeKey, value: false);
    state = state.copyWith(isFirstTime: false);
  }

  Future<void> _activateDemoProfile({
    required bool isFirstTime,
    bool rememberMe = true,
  }) async {
    final profile = await DemoProfileService.load();

    await LocalDBService.saveSecret(key: tokenKey, value: profile.token);
    if (profile.refreshToken != null && profile.refreshToken!.isNotEmpty) {
      await LocalDBService.saveSecret(
        key: refreshTokenKey,
        value: profile.refreshToken!,
      );
    }
    RestClientService.setAuthToken(profile.token);

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      loggedIn: true,
      rememberMe: rememberMe,
      token: profile.token,
      user: profile.user,
      isFirstTime: isFirstTime,
      hasErrorsInLogin: false,
      loginMessage: null,
    );
  }

  Future<void> signOut() async {
    await logout();
  }

  Future<void> signIn(String username, String password, bool rememberMe) async {
    try {
      state = state.copyWith(
        isLoading: true,
        rememberMe: rememberMe,
        loginMessage: null,
        hasErrorsInLogin: false,
      );

      if (offlineMode) {
        await _activateDemoProfile(
          isFirstTime: state.isFirstTime,
          rememberMe: rememberMe,
        );
        return;
      }

      final response = await RestClientService.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      final data = _asJsonMap(response);
      final token = data?['token']?.toString();

      if (token == null || token.isEmpty) {
        throw const FormatException('Login response did not include a token.');
      }

      final refreshToken =
          data?['refresh_token']?.toString() ??
          data?['refreshToken']?.toString();
      final user = _userFromPayload(data?['user']);

      await LocalDBService.saveSecret(key: tokenKey, value: token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await LocalDBService.saveSecret(
          key: refreshTokenKey,
          value: refreshToken,
        );
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: token,
        user: user,
        loggedIn: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        loggedIn: false,
        hasErrorsInLogin: true,
        loginMessage: 'Invalid credentials',
      );
    }
  }

  Future<void> refreshToken() async {
    if (state.token == null) return;

    if (offlineMode) {
      await _activateDemoProfile(
        isFirstTime: state.isFirstTime,
        rememberMe: state.rememberMe,
      );
      return;
    }

    try {
      final response = await RestClientService.post('/auth/refresh-token');
      final data = _asJsonMap(response);
      final refreshed = data == null ? null : AuthResponse.fromJson(data);

      if (refreshed?.token != null) {
        if (state.rememberMe) {
          await LocalDBService.saveSecret(
            key: tokenKey,
            value: refreshed!.token!,
          );
        }

        state = state.copyWith(
          token: refreshed!.token,
          user: refreshed.user ?? state.user,
          isAuthenticated: true,
          loggedIn: true,
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
    if (offlineMode) {
      return (await DemoProfileService.load()).user;
    }

    final response = await RestClientService.get('/users/profile');
    return _userFromPayload(response);
  }

  // Check if token is valid
  Future<bool> validateToken() async {
    try {
      await RestClientService.get('/auth/validate-token');
      return true;
    } catch (_) {
      return false;
    }
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
      state = state.copyWith(
        isLoading: true,
        hasErrorInForgotPassword: false,
        loginMessage: null,
      );

      if (offlineMode) {
        state = state.copyWith(
          isLoading: false,
          hasErrorInForgotPassword: false,
          loginMessage: null,
        );
        return;
      }

      await RestClientService.post(
        '/account/reset-password/init',
        data: {'email': email},
      );

      state = state.copyWith(
        isLoading: false,
        hasErrorInForgotPassword: false,
        loginMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasErrorInForgotPassword: true,
        loginMessage: 'Error resetting password',
      );
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);

      await RestClientService.post(
        '/register',
        data: {'username': username, 'email': email, 'password': password},
      );

      state = state.copyWith(isLoading: false, hasErrorsInLogin: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasErrorsInLogin: true,
        loginMessage: 'Error during registration',
      );
    }
  }

  Future<void> checkAuth() async {
    if (offlineMode) {
      await _activateDemoProfile(isFirstTime: state.isFirstTime);
      return;
    }

    try {
      final token = await LocalDBService.getSecret(key: tokenKey);
      if (token != null) {
        final response = await RestClientService.get('/account');
        final user = _userFromPayload(response);
        if (user != null) {
          state = state.copyWith(
            user: user,
            loggedIn: true,
            token: token.toString(),
            isAuthenticated: true,
          );
        }
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    await LocalDBService.deleteSecret(key: tokenKey);
    await LocalDBService.deleteSecret(key: refreshTokenKey);
    RestClientService.clearAuthToken();
    state = AuthenticationState(
      isFirstTime: state.isFirstTime,
      isLoading: false,
    );
  }

  String messagePassword(BuildContext context) {
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

  String? message(BuildContext context) {
    switch (state.errorMessage) {
      case "unauthorized":
        state.copyWith(
          errorMessage: AppLocalizations.of(context)!.errorUnauthorized,
        );
        return AppLocalizations.of(context)!.errorUnauthorized;
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

Map<String, dynamic>? _asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

User? _userFromPayload(dynamic value) {
  final data = _asJsonMap(value);
  if (data == null) return null;

  try {
    return User.fromMap(data);
  } catch (_) {
    return User.fromJson(data);
  }
}
