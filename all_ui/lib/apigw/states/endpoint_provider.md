// State Notifiers
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_endpoint.dart';
import '../services/api_gateway_service.dart';
import 'api_provider.dart';

final endpointsProvider =
    StateNotifierProvider<EndpointsNotifier, AsyncValue<List<ApiEndpoint>>>((
      ref,
    ) {
      return EndpointsNotifier(ref.read(apiServiceProvider));
    });

class EndpointsNotifier extends StateNotifier<AsyncValue<List<ApiEndpoint>>> {
  final ApiGatewayService _service;

  EndpointsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadEndpoints();
  }

  Future<void> loadEndpoints() async {
    state = const AsyncValue.loading();
    try {
      final endpoints = await _service.getEndpoints();
      state = AsyncValue.data(endpoints);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> updateEndpoint(ApiEndpoint endpoint) async {
    try {
      final success = await _service.updateEndpoint(endpoint);
      if (success) {
        loadEndpoints();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteEndpoint(String id) async {
    try {
      final success = await _service.deleteEndpoint(id);
      if (success) {
        loadEndpoints();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<ApiEndpoint?> createEndpoint(ApiEndpoint endpoint) async {
    try {
      final newEndpoint = await _service.createEndpoint(endpoint);
      loadEndpoints();
      return newEndpoint;
    } catch (e) {
      return null;
    }
  }

  Future<bool> toggleEndpointStatus(String id) async {
    try {
      final success = await _service.toggleEndpointStatus(id);
      if (success) {
        loadEndpoints();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void updateEndpointStatus(String endpointId, bool isActive) {}
}
