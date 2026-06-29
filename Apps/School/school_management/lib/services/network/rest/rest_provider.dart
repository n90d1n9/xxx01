// lib/core/providers/dio_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rest_services.dart';

// Provider that initializes the RestClientService and returns a marker
// Since RestClientService is now static, we don't return the actual service
// but a marker to trigger initialization and for provider dependencies
final restServiceInitProvider = Provider<RestServiceInitialized>((ref) {
  // Watch the secure storage to keep the dependency,
  // even though it's not directly passed anymore

  // Initialize the static service
  RestClientService.initialize();

  // Return a marker to indicate the service is initialized
  return RestServiceInitialized();
});

// Simple marker class to indicate the service is initialized
class RestServiceInitialized {
  const RestServiceInitialized();
}

// Example of how to create providers for specific API endpoints
// using the static RestClientService
final usersApiProvider = Provider<UsersApi>((ref) {
  // Ensure RestClientService is initialized first
  ref.watch(restServiceInitProvider);
  return UsersApi();
});

// Example API class that uses RestClientService
class UsersApi {
  Future<List<dynamic>> getUsers() async {
    return await RestClientService.get('/users');
  }

  Future<dynamic> createUser(Map<String, dynamic> userData) async {
    return await RestClientService.post('/users', data: userData);
  }
}
