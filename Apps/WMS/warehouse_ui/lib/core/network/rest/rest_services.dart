import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../../utils/config.dart';
import 'rest_error_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as db;

final log = Logger('RestServices');

class DioClient {
  late Dio _dio;
  final db.FlutterSecureStorage _storage;

  DioClient(this._storage) {
    _dio = Dio()
      ..options.baseUrl = baseURL
      ..options.connectTimeout = const Duration(milliseconds: timeoutConnection)
      ..options.receiveTimeout = const Duration(milliseconds: timeoutReceive)
      ..interceptors.clear()
      ..interceptors.add(LogInterceptor(
          requestBody: false,
          request: false,
          requestHeader: false,
          responseHeader: false,
          responseBody: true))
      ..interceptors.add(QueuedInterceptor());
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: tokenKey);
          if (token != null) {
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
      final refreshToken =
          await _storage.read(key: refreshTokenKey);
      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
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
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _storage.read(key: tokenKey);
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

  // GET
  get(String uri) async {
    Response response = await _dio.get(uri);
    return response.data;
  }

  // POST
  post(String uri, {dynamic data}) async {
    Object response = await _dio
        .post(uri, data: data)
        .then((value) => value.data)
        .onError((error, stackTrace) => error.toString());
    return response;
  }

  // DELETE
  delete(String uri, [dynamic id]) async {
    Response response = await _dio.delete(uri, data: id);
    return response.data;
  }

  // PUT
  update(String uri, dynamic data) async {
    Response response = await _dio.put(uri, data: data);
    return response.data;
  }
}
