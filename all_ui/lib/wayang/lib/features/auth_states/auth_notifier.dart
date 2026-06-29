import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../config/config.dart';

import '../../core/network/rest/rest_services.dart';
import '../../core/persistent/secure_storage.dart/secure_storage_provider.dart';
import 'auth_state.dart';
import 'user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthenticationState>((
  ref,
) {
  return AuthNotifier(ref);
});

// Update the AuthNotifier with additional methods
class AuthNotifier extends StateNotifier<AuthenticationState> {
  final Ref _ref;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier(this._ref) : super(AuthenticationState.initial()) {
    _init();
  }

  Future<void> _init() async {
    //final prefs = await SharedPreferences.getInstance();
    //final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    //final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    final isFirstTime = true;
    final isAuthenticated = false;

    state = state.copyWith(
      isFirstTime: isFirstTime,
      isAuthenticated: isAuthenticated,
      isLoading: false,
    );
  }

  Future<void> setFirstTimeCompleted() async {
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.setBool('isFirstTime', false);
    state = state.copyWith(isFirstTime: false);
  }

  Future<void> signOut() async {
    state = state.copyWith(isAuthenticated: false);
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.setBool('isAuthenticated', false);
  }

  Future<void> signIn(String username, String password) async {
    try {
      //  state = state.copyWith(status: StateStatus.loading);

      //final dio = _ref.read(dioProvider);
      final response = await RestClient.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        await _storage.write(key: tokenKey, value: response.data['token']);
        await _storage.write(
          key: refreshTokenKey,
          value: response.data['refresh_token'],
        );

        final user = User.fromMap(response.data['user']);
        // await _dbHelper.insertUser(user);

        state = state.copyWith(
          //status: StateStatus.success,
          user: user,
          loggedIn: true,
        );

        state = state.copyWith(isAuthenticated: true);
        //final prefs = await SharedPreferences.getInstance();
        //await prefs.setBool('isAuthenticated', true);
      }
    } catch (e) {
      state = state.copyWith(
        // status: StateStatus.error,
        hasErrorsInLogin: true,
        loginMessage: 'Invalid credentials',
      );
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
      //  state = state.copyWith(status: StateStatus.loading);

      await RestClient.post(
        '/account/reset-password/init',
        data: {'email': email},
      );

      state = state.copyWith(
        // status: StateStatus.success,
        hasErrorInForgotPassword: false,
      );
    } catch (e) {
      state = state.copyWith(
        //status: StateStatus.error,
        hasErrorInForgotPassword: true,
        loginMessage: 'Error resetting password',
      );
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      //state = state.copyWith(status: StateStatus.loading);

      final response = await RestClient.post(
        '/register',
        data: {'username': username, 'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        state = state.copyWith(
          //status: StateStatus.success,
          hasErrorsInLogin: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        // status: StateStatus.error,
        hasErrorsInLogin: true,
        loginMessage: 'Error during registration',
      );
    }
  }

  Future<void> checkAuth() async {
    try {
      final token = await _ref.read(secureStorageProvider).read(key: tokenKey);
      if (token != null) {
        final response = await RestClient.fetch('/account');
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
    await _ref.read(secureStorageProvider).deleteAll();
    state = AuthenticationState.initial();
  }

  /*  String messagePassword(context) {
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
            errorMessage: AppLocalizations.of(context)!.errorUnauthorized);
        break;
      case "username":
        state.copyWith(
            errorMessage: AppLocalizations.of(context)!.errorUsername);
        return AppLocalizations.of(context)!.errorUsername;
      default:
        state.copyWith(
            errorMessage: AppLocalizations.of(context)!.errorNetwork);
        return AppLocalizations.of(context)!.errorNetwork;
    }
  } */
}
