// State Notifiers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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
  final ApiGatewayService _apiService;

  EndpointsNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadEndpoints();
  }

  Future<void> loadEndpoints() async {
    try {
      state = const AsyncValue.loading();
      final endpoints = await _apiService.getEndpoints();
      state = AsyncValue.data(endpoints);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addEndpoint(ApiEndpoint endpoint) async {
    try {
      await _apiService.addEndpoint(endpoint);
      state.whenData((endpoints) {
        state = AsyncValue.data([...endpoints, endpoint]);
      });
    } catch (e, stackTrace) {
      // Handle error but don't change state
      debugPrint('Error adding endpoint: $e');
    }
  }

  Future<void> updateEndpoint(ApiEndpoint updatedEndpoint) async {
    try {
      await _apiService.updateEndpoint(updatedEndpoint);
      state.whenData((endpoints) {
        final updatedEndpoints =
            endpoints.map((endpoint) {
              if (endpoint.id == updatedEndpoint.id) {
                return updatedEndpoint;
              }
              return endpoint;
            }).toList();

        state = AsyncValue.data(updatedEndpoints);
      });
    } catch (e, stackTrace) {
      debugPrint('Error updating endpoint: $e');
    }
  }

  Future<void> deleteEndpoint(String endpointId) async {
    try {
      await _apiService.deleteEndpoint(endpointId);
      state.whenData((endpoints) {
        final updatedEndpoints =
            endpoints.where((endpoint) => endpoint.id != endpointId).toList();
        state = AsyncValue.data(updatedEndpoints);
      });
    } catch (e, stackTrace) {
      debugPrint('Error deleting endpoint: $e');
    }
  }

  void updateEndpointStatus(String endpointId, bool isActive) {
    state.whenData((endpoints) {
      final updatedEndpoints =
          endpoints.map((endpoint) {
            if (endpoint.id == endpointId) {
              final updatedEndpoint = endpoint.copyWith(isActive: isActive);
              // Perform API call asynchronously
              _apiService.updateEndpointStatus(endpointId, isActive).catchError(
                (e) {
                  debugPrint('Error updating endpoint status: $e');
                  // Revert state on error
                  loadEndpoints();
                },
              );
              return updatedEndpoint;
            }
            return endpoint;
          }).toList();

      state = AsyncValue.data(updatedEndpoints);
    });
  }
}
