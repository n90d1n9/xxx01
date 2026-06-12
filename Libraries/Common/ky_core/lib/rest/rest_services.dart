// lib/services/rest_client_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../config/app_config.dart';
import '../local_database/cache_policy.dart';
import '../local_database/local_storage_service.dart';
import '../network/network_checker.dart';
import '../utils/id_generator.dart';
import 'cache_keys.dart';
import 'cache_models.dart';
import 'rest_error_util.dart';

final log = Logger('RestServices');

class RestClientService {
  late Dio _dio;
  final AppConfig config;
  Completer<bool>? _refreshInFlight;
  final NetworkChecker _networkChecker = NetworkChecker();
  final SnowflakeIdGenerator _requestIdGenerator = SnowflakeIdGenerator(1);
  final Map<String, Future<Response>> _inFlightRequests = {};
  final Random _random = Random();
  late final _CircuitBreaker _circuitBreaker;

  /// The constructor receives the AppConfig object from the provider.
  /// This ensures that when the provider is re-created (due to config changes),
  /// a new RestClientService instance with the updated settings is created.
  RestClientService({required this.config}) {
    _circuitBreaker = _CircuitBreaker(
      failureThreshold: config.networkConfig.circuitBreakerFailureThreshold,
      successThreshold: config.networkConfig.circuitBreakerSuccessThreshold,
      cooldown: Duration(
        milliseconds: config.networkConfig.circuitBreakerCooldownMs,
      ),
    );
    _initialize();
  }

  /// Initializes the Dio instance with the current configuration.
  void _initialize() {
    String baseUrlToUse = _webBaseUrl;

    _dio =
        Dio(
            BaseOptions(
              baseUrl: baseUrlToUse,
              connectTimeout: Duration(
                milliseconds: config.networkConfig.timeoutConnection,
              ),
              receiveTimeout: Duration(
                milliseconds: config.networkConfig.timeoutReceive,
              ),

              // 👇 This fixes the 301 problem
              followRedirects: false,
              validateStatus: (status) {
                // Accept all <500, so Dio won’t throw on 301/302
                return status != null && status < 500;
              },
            ),
          )
          ..interceptors.clear()
          ..interceptors.add(
            LogInterceptor(
              requestBody: kDebugMode,
              request: kDebugMode,
              requestHeader: kDebugMode,
              responseHeader: kDebugMode,
              responseBody: kDebugMode,
            ),
          )
          ..interceptors.add(QueuedInterceptor());

    // Add common headers
    _dio.options.headers['Content-Type'] = config.contentType;
    _dio.options.headers['Accept'] = config.contentTypes.join(', ');

    if (kIsWeb) {
      _dio.options.headers['Access-Control-Allow-Origin'] = '*';
    }

    _setupInterceptors();
  }

  Future<Response> _handleRedirect(Response response) async {
    if (response.statusCode == 301 || response.statusCode == 302) {
      final redirectUrl = response.headers.value('location');
      if (redirectUrl != null) {
        return _dio.requestUri(
          Uri.parse(redirectUrl),
          data: response.data,
          options: Options(method: response.requestOptions.method),
        );
      }
    }
    return response;
  }

  /// A private getter to handle the web-specific URL logic.
  String get _webBaseUrl {
    if (kIsWeb) {
      // Use direct API URL - CORS should be configured on the backend.
      return config.baseUrl;
    }
    return config.baseUrl;
  }

  /// Set the authorization token for subsequent requests.
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Update the base URL at runtime (e.g., after config change).
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Update or add default headers applied to every request.
  void setDefaultHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Remove a default header key.
  void clearDefaultHeader(String header) {
    _dio.options.headers.remove(header);
  }

  /// Clear the authorization token.
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Set up interceptors for authentication, logging, and error handling.
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalDBService.getSecret(
            key: config.securityConfig.tokenKey,
          );
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['X-Request-Id'] =
              _requestIdGenerator.next().toString();
          options.extra['request_start_ms'] =
              DateTime.now().millisecondsSinceEpoch;
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final start = response.requestOptions.extra['request_start_ms'] as int?;
          if (start != null) {
            response.extra['elapsed_ms'] =
                DateTime.now().millisecondsSinceEpoch - start;
          }
          log.info(
            'RESPONSE[${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final start = error.requestOptions.extra['request_start_ms'] as int?;
          if (start != null) {
            error.response?.extra['elapsed_ms'] =
                DateTime.now().millisecondsSinceEpoch - start;
          }
          log.severe(DioErrorUtil.handleError(error));

          if (error.response?.statusCode == 401) {
            if (await _refreshTokenOnce()) {
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Attempt to refresh the authentication token.
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await LocalDBService.getSecret(
        key: config.securityConfig.refreshTokenKey /*  */,
      );
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
          key: config.securityConfig.tokenKey,
          value: response.data['token'],
        );
        await LocalDBService.saveSecret(
          key: config.securityConfig.refreshTokenKey,
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

  /// Ensure only one refresh token flow runs at a time.
  Future<bool> _refreshTokenOnce() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!.future;
    }
    _refreshInFlight = Completer<bool>();
    try {
      final success = await _refreshToken();
      _refreshInFlight?.complete(success);
      return success;
    } catch (e) {
      _refreshInFlight?.complete(false);
      return false;
    } finally {
      _refreshInFlight = null;
    }
  }

  /// Retry a failed request with the updated token.
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await LocalDBService.getSecret(
      key: config.securityConfig.tokenKey,
    );
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

  /// General request helper with optional retry.
  Future<Response> request(
    String uri, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? maxRetries,
    bool? failFastOffline,
    bool? dedupe,
    String? dedupeKey,
  }) async {
    final retries = maxRetries ?? config.networkConfig.maxRetries;
    var attempt = 0;
    final enableDedupe =
        dedupe ?? config.networkConfig.requestDeduplicationEnabled;
    final requestOptions = RequestOptions(
      path: uri,
      method: method,
      data: data,
      queryParameters: queryParameters,
    );

    Future<Response> runRequest() async {
      while (true) {
        try {
          if (config.networkConfig.circuitBreakerEnabled &&
              !_circuitBreaker.canAttempt()) {
            throw DioException.connectionError(
              requestOptions: requestOptions,
              reason: 'Circuit breaker open',
            );
          }

          final shouldFailFast =
              failFastOffline ?? config.networkConfig.failFastOffline;
          if (shouldFailFast) {
            final online = await _networkChecker.hasConnection();
            if (!online) {
              throw DioException.connectionError(
                requestOptions: requestOptions,
                reason: 'No network connectivity',
              );
            }
          }

          final response = await _dio.request(
            uri,
            data: data,
            queryParameters: queryParameters,
            options: options ?? Options(method: method),
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );

          final status = response.statusCode ?? 0;
          if (status == 429 && attempt < retries) {
            final delay = _retryDelayForResponse(response, attempt);
            attempt += 1;
            await Future.delayed(delay);
            continue;
          }

          _circuitBreaker.recordSuccess();
          return response;
        } on DioException catch (e) {
          _circuitBreaker.recordFailureIfNeeded(e);
          final shouldRetry = _shouldRetry(e) && attempt < retries;
          if (!shouldRetry) {
            rethrow;
          }
          final delay = _retryDelayFor(e, attempt);
          attempt += 1;
          await Future.delayed(delay);
        }
      }
    }

    if (!enableDedupe) {
      return runRequest();
    }

    final key = dedupeKey ??
        RestCacheKey.from(
          method: method,
          uri: uri,
          queryParameters: queryParameters,
          body: data,
        );
    final existing = _inFlightRequests[key];
    if (existing != null) {
      return await existing;
    }
    final future = runRequest();
    _inFlightRequests[key] = future;
    try {
      return await future;
    } finally {
      _inFlightRequests.remove(key);
    }
  }

  /// Request and parse JSON with cache + revalidation support.
  Future<CachedResponse<T>> requestJsonCached<T>(
    String uri, {
    required T Function(dynamic json) parser,
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? maxRetries,
    CacheOptions cacheOptions = const CacheOptions(),
    bool revalidate = true,
    bool staleWhileRevalidate = false,
    bool allowStaleOnError = true,
    String? cacheKey,
  }) async {
    final namespace = cacheOptions.namespace ?? 'rest_cache';
    final effectiveKey = cacheKey ??
        RestCacheKey.from(
          method: method,
          uri: uri,
          queryParameters: queryParameters,
          body: data,
        );

    final cachedRecord = await LocalDBService.getCacheRecord(
      key: effectiveKey,
      namespace: namespace,
      schemaVersion: cacheOptions.schemaVersion,
      decryptIfNeeded: cacheOptions.decryptIfNeeded,
      encryptionKey: cacheOptions.encryptionKey,
      allowExpired: true,
      cleanupExpired: false,
    );

    final cachedPayload = _parseCachePayload(cachedRecord);
    final cachedAt = cachedPayload?.cachedAt;
    final cachedData = cachedPayload?.data;
    final cachedEtag = cachedPayload?.etag;
    final cachedLastModified = cachedPayload?.lastModified;
    final cachedExpired = cachedPayload?.isExpired ?? false;

    if (cachedData != null && !cachedExpired && !staleWhileRevalidate) {
      return CachedResponse<T>(
        data: parser(cachedData),
        isFromCache: true,
        isStale: false,
        cachedAt: cachedAt,
        etag: cachedEtag,
        lastModified: cachedLastModified,
      );
    }

    if (cachedData != null && staleWhileRevalidate) {
      if (revalidate) {
        _fireAndForget(
          _refreshCache(
            uri,
            method: method,
            queryParameters: queryParameters,
            data: data,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
            maxRetries: maxRetries,
            cacheOptions: cacheOptions,
            cacheKey: effectiveKey,
            etag: cachedEtag,
            lastModified: cachedLastModified,
          ),
        );
      }
      return CachedResponse<T>(
        data: parser(cachedData),
        isFromCache: true,
        isStale: cachedExpired,
        cachedAt: cachedAt,
        etag: cachedEtag,
        lastModified: cachedLastModified,
      );
    }

    try {
      final response = await _requestWithConditionalHeaders(
        uri,
        method: method,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        maxRetries: maxRetries,
        etag: cachedEtag,
        lastModified: cachedLastModified,
      );

      final status = response.statusCode ?? 0;
      if (status == 304 && cachedData != null) {
        await LocalDBService.touchCache(key: effectiveKey);
        return CachedResponse<T>(
          data: parser(cachedData),
          isFromCache: true,
          isStale: false,
          cachedAt: cachedAt,
          etag: cachedEtag,
          lastModified: cachedLastModified,
        );
      }

      final decoded = _decodeJsonBody(response.data);
      await _storeCachePayload(
        key: effectiveKey,
        namespace: namespace,
        data: decoded,
        etag: response.headers.value('etag'),
        lastModified: response.headers.value('last-modified'),
        cacheOptions: cacheOptions,
      );
      return CachedResponse<T>(
        data: parser(decoded),
        isFromCache: false,
        isStale: false,
      );
    } catch (e) {
      if (allowStaleOnError && cachedData != null) {
        return CachedResponse<T>(
          data: parser(cachedData),
          isFromCache: true,
          isStale: true,
          cachedAt: cachedAt,
          etag: cachedEtag,
          lastModified: cachedLastModified,
        );
      }
      rethrow;
    }
  }

  /// Request cached JSON list and map each item with a parser.
  Future<CachedResponse<List<T>>> requestJsonCachedListParsed<T>(
    String uri, {
    required T Function(Map<String, dynamic> json) parser,
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? maxRetries,
    CacheOptions cacheOptions = const CacheOptions(),
    bool revalidate = true,
    bool staleWhileRevalidate = false,
    bool allowStaleOnError = true,
    String? cacheKey,
  }) async {
    final cached = await requestJsonCached<dynamic>(
      uri,
      parser: (json) => json,
      method: method,
      queryParameters: queryParameters,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      maxRetries: maxRetries,
      cacheOptions: cacheOptions,
      revalidate: revalidate,
      staleWhileRevalidate: staleWhileRevalidate,
      allowStaleOnError: allowStaleOnError,
      cacheKey: cacheKey,
    );
    final list = parseJsonList(cached.data);
    final mapped = list.map(parser).toList();
    return CachedResponse<List<T>>(
      data: mapped,
      isFromCache: cached.isFromCache,
      isStale: cached.isStale,
      cachedAt: cached.cachedAt,
      etag: cached.etag,
      lastModified: cached.lastModified,
    );
  }

  /// Request and parse the response as JSON (Map/List), with safe fallbacks.
  Future<dynamic> requestJson(
    String uri, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? maxRetries,
  }) async {
    final response = await request(
      uri,
      method: method,
      queryParameters: queryParameters,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      maxRetries: maxRetries,
    );
    return _decodeJsonBody(response.data);
  }

  /// Request and parse JSON, then map to a typed model.
  Future<T> requestJsonParsed<T>(
    String uri, {
    required T Function(dynamic json) parser,
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? maxRetries,
  }) async {
    final json = await requestJson(
      uri,
      method: method,
      queryParameters: queryParameters,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      maxRetries: maxRetries,
    );
    return parser(json);
  }

  /// Request and parse JSON list, then map each item with a parser.
  Future<List<T>> requestJsonListParsed<T>(
    String uri, {
    required T Function(Map<String, dynamic> json) parser,
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? maxRetries,
  }) async {
    final json = await requestJson(
      uri,
      method: method,
      queryParameters: queryParameters,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      maxRetries: maxRetries,
    );
    final list = parseJsonList(json);
    return list.map(parser).toList();
  }

  /// Parse a response payload into a `Map<String, dynamic>`.
  Map<String, dynamic> parseJsonMap(dynamic body) {
    final decoded = _decodeJsonBody(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw FormatException(
      'Expected JSON object but got ${decoded.runtimeType}',
    );
  }

  /// Parse a response payload into a `List<Map<String, dynamic>>`.
  List<Map<String, dynamic>> parseJsonList(dynamic body) {
    final decoded = _decodeJsonBody(body);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    throw FormatException(
      'Expected JSON list but got ${decoded.runtimeType}',
    );
  }

  dynamic _decodeJsonBody(dynamic body) {
    if (body == null) {
      return null;
    }
    if (body is Map || body is List) {
      return body;
    }
    if (body is String) {
      final trimmed = body.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      return jsonDecode(trimmed);
    }
    return body;
  }

  bool _shouldRetry(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        return status >= 500 || status == 429;
      default:
        return false;
    }
  }

  Duration _retryDelayFor(DioException error, int attempt) {
    final status = error.response?.statusCode;
    if (status == 429) {
      final retryAfter = error.response?.headers.value('retry-after');
      final seconds = int.tryParse(retryAfter ?? '');
      if (seconds != null && seconds >= 0) {
        final ms = seconds * 1000;
        final max = config.networkConfig.retryMaxDelayMs;
        return Duration(milliseconds: ms > max ? max : ms);
      }
    }
    return _retryDelay(attempt);
  }

  Duration _retryDelayForResponse(Response response, int attempt) {
    final retryAfter = response.headers.value('retry-after');
    final seconds = int.tryParse(retryAfter ?? '');
    if (seconds != null && seconds >= 0) {
      final ms = seconds * 1000;
      final max = config.networkConfig.retryMaxDelayMs;
      return Duration(milliseconds: ms > max ? max : ms);
    }
    return _retryDelay(attempt);
  }

  Duration _retryDelay(int attempt) {
    final base = config.networkConfig.retryBaseDelayMs;
    final max = config.networkConfig.retryMaxDelayMs;
    final delayMs = base * (1 << attempt);
    final jitterPct = config.networkConfig.retryJitterPct.clamp(0.0, 1.0);
    final jitter = 1 + ((_random.nextDouble() * 2 - 1) * jitterPct);
    final adjusted = (delayMs * jitter).toInt();
    return Duration(milliseconds: adjusted > max ? max : adjusted);
  }

  Future<Response> _requestWithConditionalHeaders(
    String uri, {
    required String method,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? maxRetries,
    String? etag,
    String? lastModified,
  }) {
    final mergedHeaders = <String, dynamic>{};
    if (options?.headers != null) {
      mergedHeaders.addAll(options!.headers!);
    }
    if (etag != null && etag.isNotEmpty) {
      mergedHeaders['If-None-Match'] = etag;
    }
    if (lastModified != null && lastModified.isNotEmpty) {
      mergedHeaders['If-Modified-Since'] = lastModified;
    }
    final nextOptions = (options ?? Options()).copyWith(
      method: method,
      headers: mergedHeaders.isEmpty ? null : mergedHeaders,
    );
    return request(
      uri,
      method: method,
      queryParameters: queryParameters,
      data: data,
      options: nextOptions,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      maxRetries: maxRetries,
    );
  }

  _CachePayload? _parseCachePayload(Map<String, dynamic>? record) {
    if (record == null) return null;
    final isExpired = record['is_expired'] == true;
    final raw = record['value'];
    if (raw == null) return null;
    try {
      final decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        return _CachePayload(
          data: map['data'],
          etag: map['etag']?.toString(),
          lastModified: map['last_modified']?.toString(),
          cachedAt: DateTime.tryParse(map['cached_at']?.toString() ?? ''),
          isExpired: isExpired,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<void> _storeCachePayload({
    required String key,
    required String namespace,
    required dynamic data,
    required CacheOptions cacheOptions,
    String? etag,
    String? lastModified,
  }) {
    final payload = {
      'data': data,
      'etag': etag,
      'last_modified': lastModified,
      'cached_at': DateTime.now().toIso8601String(),
    };
    return LocalDBService.cacheJson(
      key: key,
      value: payload,
      expiration: cacheOptions.expiration,
      encrypted: cacheOptions.encrypted,
      encryptionKey: cacheOptions.encryptionKey,
      schemaVersion: cacheOptions.schemaVersion,
      namespace: namespace,
      maxValueBytes: cacheOptions.maxValueBytes,
      maxNamespaceBytes: cacheOptions.maxNamespaceBytes,
      maxTotalBytes: cacheOptions.maxTotalBytes,
      pinned: cacheOptions.pinned,
      priority: cacheOptions.priority,
    );
  }

  Future<void> _refreshCache(
    String uri, {
    required String method,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? maxRetries,
    CacheOptions cacheOptions = const CacheOptions(),
    required String cacheKey,
    String? etag,
    String? lastModified,
  }) async {
    try {
      final response = await _requestWithConditionalHeaders(
        uri,
        method: method,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        maxRetries: maxRetries,
        etag: etag,
        lastModified: lastModified,
      );
      final status = response.statusCode ?? 0;
      if (status == 304) {
        await LocalDBService.touchCache(key: cacheKey);
        return;
      }
      final decoded = _decodeJsonBody(response.data);
      final namespace = cacheOptions.namespace ?? 'rest_cache';
      await _storeCachePayload(
        key: cacheKey,
        namespace: namespace,
        data: decoded,
        etag: response.headers.value('etag'),
        lastModified: response.headers.value('last-modified'),
        cacheOptions: cacheOptions,
      );
    } catch (_) {}
  }

  void _fireAndForget(Future<void> future) {}

  /// Make a GET request.
  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    int? maxRetries,
  }) async {
    try {
      final response = await request(
        uri,
        method: 'GET',
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        maxRetries: maxRetries,
      );
      return response;
    } on DioException catch (e) {
      log.warning('GET request error for $uri: ${DioErrorUtil.handleError(e)}');
      rethrow;
    } catch (e) {
      log.severe('Unexpected error during GET request for $uri: $e');
      rethrow;
    }
  }

  /// Make a POST request.
  Future<Response> post(
    String uri, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? maxRetries,
  }) async {
    try {
      final response = await request(
        uri,
        method: 'POST',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        maxRetries: maxRetries,
      );
      return _handleRedirect(response);
    } on DioException catch (e) {
      log.warning('POST request error for $uri: ${DioErrorUtil.handleError(e)}');
      rethrow;
    } catch (e) {
      log.severe('Unexpected error during POST request for $uri: $e');
      rethrow;
    }
  }

  /// Make a DELETE request.
  Future<Response> delete(String uri, {dynamic data}) async {
    try {
      final response = await request(
        uri,
        method: 'DELETE',
        data: data,
      );
      return response;
    } on DioException catch (e) {
      log.warning(
        'DELETE request error for $uri: ${DioErrorUtil.handleError(e)}',
      );
      rethrow;
    } catch (e) {
      log.severe('Unexpected error during DELETE request for $uri: $e');
      rethrow;
    }
  }

  /// Make a PUT request.
  Future<Response> put(
    String uri, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? maxRetries,
  }) async {
    try {
      final response = await request(
        uri,
        method: 'PUT',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        maxRetries: maxRetries,
      );
      return response;
    } on DioException catch (e) {
      log.warning('PUT request error for $uri: ${DioErrorUtil.handleError(e)}');
      rethrow;
    } catch (e) {
      log.severe('Unexpected error during PUT request for $uri: $e');
      rethrow;
    }
  }

  /// Make a PATCH request.
  Future<Response> patch(
    String uri, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? maxRetries,
  }) async {
    try {
      final response = await request(
        uri,
        method: 'PATCH',
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        maxRetries: maxRetries,
      );
      return response;
    } on DioException catch (e) {
      log.warning(
        'PATCH request error for $uri: ${DioErrorUtil.handleError(e)}',
      );
      rethrow;
    } catch (e) {
      log.severe('Unexpected error during PATCH request for $uri: $e');
      rethrow;
    }
  }

  /// Make a GET request without any interceptors or auth headers (for public endpoints).
  Future<Response> getPublic(
    String uri, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final dio = Dio(); // New instance, no interceptors, no auth.
    try {
      final response = await dio.get(uri, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      log.warning(
        'GET PUBLIC request error for $uri: ${DioErrorUtil.handleError(e)}',
      );
      rethrow;
    } catch (e) {
      log.severe('Unexpected error during GET PUBLIC request for $uri: $e');
      rethrow;
    }
  }

  /// Save authentication tokens to secure storage.
  Future<void> saveAuthTokens({
    required String token,
    required String refreshToken,
  }) async {
    await LocalDBService.saveSecret(
      key: config.securityConfig.tokenKey,
      value: token,
    );
    await LocalDBService.saveSecret(
      key: config.securityConfig.refreshTokenKey,
      value: refreshToken,
    );
    setAuthToken(token);
  }

  /// Clear all authentication tokens.
  Future<void> clearAllTokens() async {
    await LocalDBService.deleteSecret(key: config.securityConfig.tokenKey);
    await LocalDBService.deleteSecret(
      key: config.securityConfig.refreshTokenKey,
    );
    clearAuthToken();
  }
}

class _CircuitBreaker {
  final int failureThreshold;
  final int successThreshold;
  final Duration cooldown;
  int _failures = 0;
  int _successes = 0;
  DateTime? _openedAt;

  _CircuitBreaker({
    required this.failureThreshold,
    required this.successThreshold,
    required this.cooldown,
  });

  bool canAttempt() {
    if (_openedAt == null) {
      return true;
    }
    final elapsed = DateTime.now().difference(_openedAt!);
    if (elapsed >= cooldown) {
      _successes = 0;
      return true;
    }
    return false;
  }

  void recordSuccess() {
    if (_openedAt != null) {
      _successes += 1;
      if (_successes >= successThreshold) {
        _reset();
      }
      return;
    }
    _failures = 0;
  }

  void recordFailureIfNeeded(DioException e) {
    if (!_shouldCountFailure(e)) {
      return;
    }
    if (_openedAt != null) {
      _openedAt = DateTime.now();
      _successes = 0;
      return;
    }
    _failures += 1;
    if (_failures >= failureThreshold) {
      _openedAt = DateTime.now();
      _successes = 0;
    }
  }

  bool _shouldCountFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        return status >= 500;
      default:
        return false;
    }
  }

  void _reset() {
    _openedAt = null;
    _failures = 0;
    _successes = 0;
  }
}

class _CachePayload {
  final dynamic data;
  final String? etag;
  final String? lastModified;
  final DateTime? cachedAt;
  final bool isExpired;

  _CachePayload({
    required this.data,
    required this.etag,
    required this.lastModified,
    required this.cachedAt,
    required this.isExpired,
  });
}
