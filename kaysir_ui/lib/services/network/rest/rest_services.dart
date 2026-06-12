import 'package:dio/dio.dart';
import 'package:kaysir/services/local_database/local_storage_service.dart';
import 'package:logging/logging.dart';

import '../../../config/config.dart';
import 'rest_error_util.dart';

final log = Logger('RestServices');

class RestClientService {
  static late Dio _dio;
  static bool _isInitialized = false;

  /// Initialize the RestClientService with default settings
  static void initialize() {
    if (_isInitialized) return;

    _dio =
        Dio()
          ..options.baseUrl = baseURL
          ..options.connectTimeout = const Duration(
            milliseconds: timeoutConnection,
          )
          ..options.receiveTimeout = const Duration(
            milliseconds: timeoutReceive,
          )
          ..interceptors.clear()
          ..interceptors.add(
            LogInterceptor(
              requestBody: false,
              request: false,
              requestHeader: false,
              error: false,
              responseHeader: false,
              responseBody: true,
            ),
          )
          ..interceptors.add(QueuedInterceptor());

    _setupInterceptors();
    _isInitialized = true;
  }

  /// Set the authorization token for subsequent requests
  static void setAuthToken(String token) {
    _ensureInitialized();
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear the authorization token
  static void clearAuthToken() {
    _ensureInitialized();
    _dio.options.headers.remove('Authorization');
  }

  /// Set up interceptors for authentication, logging, and error handling
  static void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalDBService.getSecret(key: tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log.info(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          _logDioError(error);

          if (error.response?.statusCode == 401) {
            if (await _refreshToken()) {
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  static void _logDioError(DioException error) {
    final message = DioErrorUtil.handleError(error);
    if (_isRecoverableNetworkError(error)) {
      log.warning(message);
      return;
    }

    log.severe(message);
  }

  static bool _isRecoverableNetworkError(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.unknown:
        return true;
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
        return false;
    }
  }

  /// Attempt to refresh the authentication token
  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await LocalDBService.getSecret(key: refreshTokenKey);
      if (refreshToken == null) {
        log.warning('Refresh token not found in storage');
        return false;
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        await LocalDBService.saveSecret(
          key: tokenKey,
          value: response.data['token'],
        );
        await LocalDBService.saveSecret(
          key: refreshTokenKey,
          value: response.data['refresh_token'],
        );
        log.info('Token refreshed successfully');
        return true;
      }

      log.warning('Failed to refresh token: ${response.statusCode}');
      return false;
    } catch (e) {
      log.severe('Error refreshing token: $e');
      return false;
    }
  }

  /// Retry a failed request with updated token
  static Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await LocalDBService.getSecret(key: tokenKey);
    requestOptions.headers['Authorization'] = 'Bearer $token';

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }

  /// Make a GET request
  static Future<dynamic> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
  }) async {
    _ensureInitialized();
    try {
      final response = await _dio.get(uri, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      log.warning('GET request error for $uri: ${e.message}');
      rethrow;
    } catch (e) {
      log.severe('Unexpected error during GET request for $uri: $e');
      rethrow;
    }
  }

  /// Make a POST request
  static Future<dynamic> post(String uri, {dynamic data}) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(uri, data: data);
      return response.data;
    } on DioException catch (e) {
      log.warning('POST request error for $uri: ${e.message}');
      rethrow;
    } catch (e) {
      log.severe('Unexpected error during POST request for $uri: $e');
      rethrow;
    }
  }

  /// Make a DELETE request
  static Future<dynamic> delete(String uri, {dynamic data}) async {
    _ensureInitialized();
    try {
      final response = await _dio.delete(uri, data: data);
      return response.data;
    } on DioException catch (e) {
      log.warning('DELETE request error for $uri: ${e.message}');
      rethrow;
    } catch (e) {
      log.severe('Unexpected error during DELETE request for $uri: $e');
      rethrow;
    }
  }

  /// Make a PUT request
  static Future<dynamic> put(
    String uri,
    String jsonEncode, {
    dynamic data,
  }) async {
    _ensureInitialized();
    try {
      final response = await _dio.put(uri, data: data);
      return response.data;
    } on DioException catch (e) {
      log.warning('PUT request error for $uri: ${e.message}');
      rethrow;
    } catch (e) {
      log.severe('Unexpected error during PUT request for $uri: $e');
      rethrow;
    }
  }

  /// Make a PATCH request
  static Future<dynamic> patch(String uri, {dynamic data}) async {
    _ensureInitialized();
    try {
      final response = await _dio.patch(uri, data: data);
      return response.data;
    } on DioException catch (e) {
      log.warning('PATCH request error for $uri: ${e.message}');
      rethrow;
    } catch (e) {
      log.severe('Unexpected error during PATCH request for $uri: $e');
      rethrow;
    }
  }

  /// Ensure the service is initialized before use
  static void _ensureInitialized() {
    if (!_isInitialized) {
      initialize();
    }
  }

  /// Save authentication tokens to secure storage
  static Future<void> saveAuthTokens({
    required String token,
    required String refreshToken,
  }) async {
    await LocalDBService.saveSecret(key: tokenKey, value: token);
    await LocalDBService.saveSecret(key: refreshTokenKey, value: refreshToken);
    setAuthToken(token);
  }

  /// Clear all authentication tokens
  static Future<void> clearAllTokens() async {
    await LocalDBService.deleteSecret(key: tokenKey);
    await LocalDBService.deleteSecret(key: refreshTokenKey);
    clearAuthToken();
  }
}
