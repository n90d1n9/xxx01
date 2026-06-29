import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:golok/models/general_status.dart';
import 'package:golok/core/persistent/local_database/db_services.dart';

import '../../../core/network/rest/rest_services.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/utils/config.dart';
import '../models/auth_model.dart';
import '../models/user.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthenticationState>((ref) {
  return AuthNotifier(ref);
});

// Update the AuthNotifier with additional methods
class AuthNotifier extends StateNotifier<AuthenticationState> {
  final Ref _ref;
  late final DioClient _dioClient;
  //final DatabaseServices _dbHelper = DatabaseServices();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier(this._ref) : super(AuthenticationState.initial()) {
    //_dioClient = _ref.read(dioProvider);
     _init();
  }


  Future<void> _init() async {
    //final prefs = await SharedPreferences.getInstance();
    //final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    //final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    final isFirstTime =  true;
    final isAuthenticated =  false;
    
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
      state = state.copyWith(status: StateStatus.loading);

      final dio = _ref.read(dioProvider);
      final response = await dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        await _storage.write(
          key: tokenKey,
          value: response.data['token'],
        );
        await _storage.write(
          key: refreshTokenKey,
          value: response.data['refresh_token'],
        );

        final user = User.fromMap(response.data['user']);
       // await _dbHelper.insertUser(user);

        state = state.copyWith(
          status: StateStatus.success,
          user: user,
          loggedIn: true,
        );

        state = state.copyWith(isAuthenticated: true);
        //final prefs = await SharedPreferences.getInstance();
        //await prefs.setBool('isAuthenticated', true);
      }
    } catch (e) {
      state = state.copyWith(
        status: StateStatus.error,
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
      state = state.copyWith(status: StateStatus.loading);

      await _dioClient.post('/account/reset-password/init', data: {
        'email': email,
      });

      state = state.copyWith(
        status: StateStatus.success,
        hasErrorInForgotPassword: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: StateStatus.error,
        hasErrorInForgotPassword: true,
        loginMessage: 'Error resetting password',
      );
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      state = state.copyWith(status: StateStatus.loading);

      final response = await _dioClient.post('/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        state = state.copyWith(
          status: StateStatus.success,
          hasErrorsInLogin: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: StateStatus.error,
        hasErrorsInLogin: true,
        loginMessage: 'Error during registration',
      );
    }
  }

  Future<void> checkAuth() async {
    try {
      final token = await _ref
          .read(secureStorageProvider)
          .read(key: tokenKey);
      if (token != null) {
        final response = await _dioClient.get('/account');
        if (response.statusCode == 200) {
          final user = User.fromMap(response.data);
          state = state.copyWith(
            user: user,
            loggedIn: true,
            token: token,
          );
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
}
