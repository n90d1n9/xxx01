import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/api_gateway_config.dart';
import '../services/api_gateway_service.dart';
import 'api_provider.dart';

class ConfigNotifier extends StateNotifier<AsyncValue<ApiGatewayConfig>> {
  final ApiGatewayService _service;

  ConfigNotifier(this._service) : super(const AsyncValue.loading()) {
    loadConfig();
  }

  Future<void> loadConfig() async {
    state = const AsyncValue.loading();
    try {
      final config = await _service.getConfig();
      state = AsyncValue.data(config);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> updateConfig(ApiGatewayConfig config) async {
    try {
      final success = await _service.updateConfig(config);
      if (success) {
        state = AsyncValue.data(config);
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

class DeploymentNotifier extends StateNotifier<AsyncValue<bool>> {
  final ApiGatewayService _apiService;

  DeploymentNotifier(this._apiService) : super(const AsyncValue.data(true)) {
    checkDeploymentStatus();
  }

  Future<bool> deployChanges() async {
    state = const AsyncValue.loading();
    try {
      final success = await _apiService.deployGatewayChanges();
      state = AsyncValue.data(success);
      return success;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> checkDeploymentStatus() async {
    try {
      state = const AsyncValue.loading();
      final isDeployed = await _apiService.isDeployed();
      state = AsyncValue.data(isDeployed);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deploy() async {
    try {
      state = const AsyncValue.loading();
      await _apiService.deployChanges();
      state = const AsyncValue.data(true);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      // After a delay, revert to previous state
      Future.delayed(const Duration(seconds: 3), () {
        checkDeploymentStatus();
      });
    }
  }
}

final configProvider =
    StateNotifierProvider<ConfigNotifier, AsyncValue<ApiGatewayConfig>>((ref) {
      return ConfigNotifier(ref.read(apiServiceProvider));
    });

final deploymentProvider =
    StateNotifierProvider<DeploymentNotifier, AsyncValue<bool>>((ref) {
      return DeploymentNotifier(ref.read(apiServiceProvider));
    });

final endpointLogsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) {
      return ref.read(apiServiceProvider).getEndpointLogs(id);
    });

final endpointAnalyticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) {
      return ref.read(apiServiceProvider).getAnalytics(id);
    });
