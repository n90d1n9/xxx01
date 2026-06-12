import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OpenidService {
  final Dio _dio = Dio();
  final String _baseUrl;
  final String _realm;
  final String _clientId;
  final String _clientSecret;

  OpenidService({
    required String baseUrl,
    required String realm,
    required String clientId,
    required String clientSecret,
  }) : _baseUrl = baseUrl,
       _realm = realm,
       _clientId = clientId,
       _clientSecret = clientSecret {
    // Configure Dio instance
    //http://localhost:8180/realms/quarkus-app/protocol/openid-connect/token"
    _dio.options.baseUrl = '$_baseUrl/realms/$_realm/protocol/openid-connect';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Login with username and password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      /* print(_dio.options.baseUrl);
      print('username: $username');
      print('password: $password');
      final response = await http.post(
        Uri.parse('$_baseUrl/realms/$_realm/protocol/openid-connect/token'),
        body: {
          'grant_type': 'password',
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'username': username,
          'password': password,
        },
      ); */
      final response = await _dio.post(
        '/token',
        data: {
          'grant_type': 'password',
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'username': username,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
      print('Response: ${response.statusCode}');
      // print('Response body: ${response.body}');
      //return {};
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        debugPrint('Keycloak error: $errorData');

        if (errorData is Map && errorData['error'] == 'invalid_grant') {
          // Handle specific error cases
          if (errorData['error_description'] == 'Account is not fully set up') {
            throw AccountNotFullySetUpException(
              message: errorData['error_description'],
              requiredActions: _parseRequiredActions(errorData),
            );
          } else if (errorData['error_description'].contains(
            'Account is not fully set up',
          )) {
            throw AccountNotFullySetUpException(
              message: errorData['error_description'],
              requiredActions: _parseRequiredActions(errorData),
            );
          }
        }

        throw Exception(
          'Login failed: ${errorData['error_description'] ?? 'Unknown error'}',
        );
      } else {
        debugPrint('Keycloak error: ${e.message}');
        throw Exception('Network error during login');
      }
    }
  }

  List<String> _parseRequiredActions(Map<dynamic, dynamic> errorData) {
    // Parse any required actions from the error response
    // This might require custom logic based on your Keycloak setup
    final description = errorData['error_description'] ?? '';

    if (description.contains('verify email')) {
      return ['VERIFY_EMAIL'];
    } else if (description.contains('update password')) {
      return ['UPDATE_PASSWORD'];
    } else if (description.contains('configure OTP')) {
      return ['CONFIGURE_TOTP'];
    }

    return [];
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/token',
        data: {
          'grant_type': 'refresh_token',
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('Keycloak refresh error: ${e.response?.data}');
        throw Exception(
          'Token refresh failed: ${e.response?.data['error_description']}',
        );
      } else {
        debugPrint('Keycloak refresh error: ${e.message}');
        throw Exception('Network error during token refresh');
      }
    }
  }

  // Get user info
  Future<Map<String, dynamic>> getUserInfo(String accessToken) async {
    try {
      final response = await _dio.get(
        '/userinfo',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('Keycloak userinfo error: ${e.response?.data}');
        throw Exception(
          'Failed to get user info: ${e.response?.data['error_description']}',
        );
      } else {
        debugPrint('Keycloak userinfo error: ${e.message}');
        throw Exception('Network error during user info request');
      }
    }
  }

  // Logout
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(
        '/logout',
        data: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('Keycloak logout error: ${e.response?.data}');
      } else {
        debugPrint('Keycloak logout error: ${e.message}');
      }
      // Even if logout fails, we might want to proceed
    }
  }
}

class AccountNotFullySetUpException implements Exception {
  final String message;
  final List<String> requiredActions;

  AccountNotFullySetUpException({
    required this.message,
    this.requiredActions = const [],
  });

  @override
  String toString() => 'AccountNotFullySetUpException: $message';
}
