// lib/core/providers/dio_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../config/app_config_provider.dart';
import 'rest_services.dart';

// The fixed provider definition.
// It will be re-created automatically whenever appConfigProvider changes.
final restClientProvider = Provider<RestClientService>((ref) {
  // Watch the appConfigProvider here.
  // When the AppConfig object changes, this provider will be marked as "dirty"
  // and will be re-created with the new configuration.
  final config = ref.watch(appConfigProvider);

  // Create the service instance with the current config.
  // The service itself no longer needs to know about `ref`.
  return RestClientService(config: config);
});
