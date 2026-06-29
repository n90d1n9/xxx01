import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/alert.dart';
import '../services/api_gateway_service.dart';
import 'api_provider.dart';

class AlertsNotifier extends StateNotifier<AsyncValue<List<Alert>>> {
  final ApiGatewayService _apiService;

  AlertsNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    try {
      state = const AsyncValue.loading();
      final alerts = await _apiService.getAlerts();
      state = AsyncValue.data(alerts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void markAlertAsRead(String alertId) {
    state.whenData((alerts) {
      final updatedAlerts =
          alerts.map((alert) {
            if (alert.id == alertId) {
              return alert.copyWith(isRead: true);
            }
            return alert;
          }).toList();

      state = AsyncValue.data(updatedAlerts);
      _apiService.markAlertAsRead(alertId);
    });
  }

  void clearAllAlerts() {
    state.whenData((alerts) {
      final updatedAlerts =
          alerts.map((alert) {
            return alert.copyWith(isRead: true);
          }).toList();

      state = AsyncValue.data(updatedAlerts);
      _apiService.clearAllAlerts();
    });
  }
}

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, AsyncValue<List<Alert>>>((ref) {
      final apiService = ref.read(apiServiceProvider);
      return AlertsNotifier(apiService);
    });
