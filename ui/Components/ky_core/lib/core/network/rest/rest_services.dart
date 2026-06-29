import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import 'rest_config.dart';
import 'rest_error_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as db;

final log = Logger('RestServices');

@Deprecated('Use RestClientService from package:miku_core/rest/rest_services.dart')
class RestClient {
  static Dio? _dio;
  static RestConfig? _lastConfig;
  final db.FlutterSecureStorage _storage;
  final RestConfig config;

  RestClient(this._storage, this.config) {
    _ensureInitialized();
    _setupInterceptors();
  }

  void _ensureInitialized() {
    if (_dio != null && _lastConfig == config) {
      return;
    }
    _lastConfig = config;
    _dio = Dio()
      ..options.baseUrl = config.baseUrl
      ..options.connectTimeout = Duration(
        milliseconds: config.timeoutConnection,
      )
      ..options.receiveTimeout = Duration(milliseconds: config.timeoutReceive)
      ..options.headers['Content-Type'] = 'application/json'
      ..options.headers['Accept'] = 'application/json'
      ..interceptors.clear()
      ..interceptors.add(
        LogInterceptor(
          requestBody: false,
          request: false,
          requestHeader: false,
          responseHeader: false,
          responseBody: true,
        ),
      )
      ..interceptors.add(QueuedInterceptor());
  }

  void _setupInterceptors() {
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final tokenKey = config.tokenKey;
          final token = tokenKey == null ? null : await _storage.read(key: tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          log.severe(DioErrorUtil.handleError(error));

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

  Future<bool> _refreshToken() async {
    try {
      final refreshTokenKey = config.refreshTokenKey;
      final tokenKey = config.tokenKey;
      if (refreshTokenKey == null || tokenKey == null) {
        return false;
      }

      final refreshToken = await _storage.read(key: refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }
      final response = await _dio!.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      if (response.statusCode == 200) {
        await _storage.write(
          key: tokenKey,
          value: response.data['token'],
        );
        await _storage.write(
          key: refreshTokenKey,
          value: response.data['refresh_token'],
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final tokenKey = config.tokenKey;
    final token = tokenKey == null ? null : await _storage.read(key: tokenKey);
    if (token != null && token.isNotEmpty) {
      requestOptions.headers['Authorization'] = 'Bearer $token';
    }
    return _dio!.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }

  static Future<Response<dynamic>> request(
    String uri, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (_dio == null) {
      throw StateError('RestClient is not initialized. Call restProvider first.');
    }
    return _dio!.request<dynamic>(
      uri,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(method: method),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // GET
  static Future<Response<dynamic>> fetch(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return request(
      uri,
      method: 'GET',
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // POST
  static Future<Response<dynamic>> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request(
      uri,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // DELETE
  static Future<Response<dynamic>> delete(
    String uri, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return request(
      uri,
      method: 'DELETE',
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // PUT
  static Future<Response<dynamic>> update(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request(
      uri,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
