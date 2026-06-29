// lib/core/providers/dio_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/rest/rest_services.dart';
import '../persistent/secure_storage.dart/secure_storage_provider.dart';

final restProvider = Provider<RestClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return RestClient(secureStorage);
});
