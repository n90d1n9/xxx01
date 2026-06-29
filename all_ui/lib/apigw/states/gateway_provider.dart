import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/gateway_status.dart';
import '../services/api_gateway_service.dart';
import 'api_provider.dart';

// The enhanced provider
final gatewayStatusProvider =
    StateNotifierProvider<GatewayStatusNotifier, GatewayStatusState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      final notifier = GatewayStatusNotifier(apiService);
      // Auto-refresh every 30 seconds
      notifier.startPeriodicRefresh(const Duration(seconds: 30));
      return notifier;
    });

// Additional provider to get just the status data
final gatewayStatusDataProvider = Provider<GatewayStatus?>((ref) {
  return ref.watch(gatewayStatusProvider).data;
});

// Gateway status notifier with proper error handling and refresh capability
class GatewayStatusNotifier extends StateNotifier<GatewayStatusState> {
  final ApiGatewayService _apiService;
  Timer? _refreshTimer;

  GatewayStatusNotifier(this._apiService)
    : super(GatewayStatusState(isLoading: true)) {
    fetchStatus(); // Initial fetch
  }

  Future<void> fetchStatus() async {
    if (state.isLoading) return; // Prevent concurrent requests

    state = state.copyWith(isLoading: true);

    try {
      final status = await _apiService.getGatewayStatus();
      state = GatewayStatusState(
        isLoading: false,
        data: status,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = GatewayStatusState(
        isLoading: false,
        data: state.data, // Keep old data if available
        errorMessage: e.toString(),
        lastUpdated: state.lastUpdated,
      );
    }
  }

  // Set up automatic refresh
  void startPeriodicRefresh(Duration interval) {
    stopPeriodicRefresh();
    _refreshTimer = Timer.periodic(interval, (_) => fetchStatus());
  }

  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopPeriodicRefresh();
    super.dispose();
  }
}

class GatewayStatusState {
  final bool isLoading;
  final GatewayStatus data;
  final String? errorMessage;
  final DateTime? lastUpdated;

  GatewayStatusState({
    this.isLoading = false,
    GatewayStatus? data,
    this.errorMessage,
    this.lastUpdated,
  }) : data = data ?? GatewayStatus(successRate: 0);

  GatewayStatusState copyWith({
    bool? isLoading,
    GatewayStatus? data,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return GatewayStatusState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
