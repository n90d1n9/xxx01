import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config_provider.dart';
import '../utils/id_generator.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: Duration(
        milliseconds: config.networkConfig.timeoutConnection,
      ),
      receiveTimeout: Duration(
        milliseconds: config.networkConfig.timeoutReceive,
      ),
      headers: {
        'Content-Type': config.contentType,
        'Accept': config.contentTypes.join(', '),
      },
    ),
  );

  final idGen = SnowflakeIdGenerator(1);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final requestId = idGen.next().toString();
        options.headers['X-Request-Id'] = requestId;
        options.extra['request_start_ms'] =
            DateTime.now().millisecondsSinceEpoch;
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final start = response.requestOptions.extra['request_start_ms'] as int?;
        if (start != null) {
          final ms = DateTime.now().millisecondsSinceEpoch - start;
          response.extra['elapsed_ms'] = ms;
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        final start = error.requestOptions.extra['request_start_ms'] as int?;
        if (start != null) {
          final ms = DateTime.now().millisecondsSinceEpoch - start;
          error.response?.extra['elapsed_ms'] = ms;
        }
        return handler.next(error);
      },
    ),
  );
  return dio;
});
