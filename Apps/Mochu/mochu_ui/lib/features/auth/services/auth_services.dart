import 'dart:convert';

import '../../../core/storage/secure_storage/secure_db_service.dart';
import '../models/auth_token.dart';
import '../models/user.dart';

class AuthService {
  AuthService();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';
  static const _rememberMeKey = 'remember_me';

  static Future<void> saveTokens(AuthTokens tokens) async {
    await SecureDBService.write(
        key: _accessTokenKey, value: tokens.accessToken);
    await SecureDBService.write(
        key: _refreshTokenKey, value: tokens.refreshToken);
  }

  static Future<AuthTokens?> getTokens() async {
    final accessToken = await SecureDBService.read(key: _accessTokenKey);
    final refreshToken = await SecureDBService.read(key: _refreshTokenKey);

    if (accessToken != null && refreshToken != null) {
      return AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );
    }
    return null;
  }

  static Future<void> saveUser(User user) async {
    await SecureDBService.write(
      key: _userDataKey,
      value: jsonEncode({
        'id': user.id,
        'email': user.email,
        'name': user.username,
      }),
    );
  }

  static Future<User?> getUser() async {
    final userData = await SecureDBService.read(key: _userDataKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  static Future<void> setRememberMe(bool value) async {
    await SecureDBService.write(key: _rememberMeKey, value: value.toString());
  }

  static Future<bool> getRememberMe() async {
    final value = await SecureDBService.read(key: _rememberMeKey);
    return value == 'true';
  }

  static Future<void> clearStorage() async {
    final rememberMe = await getRememberMe();
    await SecureDBService.deleteAll();
    if (rememberMe) {
      await setRememberMe(true);
    }
  }
}
