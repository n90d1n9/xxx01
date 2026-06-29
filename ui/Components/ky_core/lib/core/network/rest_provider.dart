// lib/core/providers/dio_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/rest/rest_services.dart';
import '../persistent/secure_storage.dart/secure_storage_provider.dart';
import 'rest/rest_config.dart';

const _defaultAuthBaseUrl = String.fromEnvironment(
  'MIKU_AUTH_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

const _defaultAuthTokenKey = String.fromEnvironment(
  'MIKU_AUTH_TOKEN_KEY',
  defaultValue: 'auth_token',
);

const _defaultRefreshTokenKey = String.fromEnvironment(
  'MIKU_AUTH_REFRESH_TOKEN_KEY',
  defaultValue: 'refresh_token',
);

final restProvider = Provider<RestClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final config = ref.watch(restConfigProvider);
  return RestClient(secureStorage, config);
});

final restConfigProvider = Provider<RestConfig>((ref) {
  return RestConfig(
    baseUrl: _defaultAuthBaseUrl,
    tokenKey: _defaultAuthTokenKey,
    refreshTokenKey: _defaultRefreshTokenKey,
  );
});
