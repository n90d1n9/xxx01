import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StoreStatus { active, inactive, pending, error }

class StoreSyncState {
  final Map<String, StoreStatus> storeStatuses;
  final Map<String, DateTime> lastSyncTimes;
  final Set<String> syncingStores;
  final Map<String, String> syncErrors;

  StoreSyncState({
    required this.storeStatuses,
    required this.lastSyncTimes,
    required this.syncingStores,
    required this.syncErrors,
  });

  StoreSyncState copyWith({
    Map<String, StoreStatus>? storeStatuses,
    Map<String, DateTime>? lastSyncTimes,
    Set<String>? syncingStores,
    Map<String, String>? syncErrors,
  }) {
    return StoreSyncState(
      storeStatuses: storeStatuses ?? this.storeStatuses,
      lastSyncTimes: lastSyncTimes ?? this.lastSyncTimes,
      syncingStores: syncingStores ?? this.syncingStores,
      syncErrors: syncErrors ?? this.syncErrors,
    );
  }
}

// Assuming these providers exist elsewhere in the codebase
final storeSyncServiceProvider = Provider<StoreSyncService>(
  (ref) => throw UnimplementedError(),
);
final networkServiceProvider = Provider<NetworkService>(
  (ref) => throw UnimplementedError(),
);

// lib/features/multi_store/providers/store_sync_provider.dart
final storeSyncProvider =
    StateNotifierProvider<StoreSyncNotifier, StoreSyncState>((ref) {
      final syncService = ref.watch(storeSyncServiceProvider);
      final networkService = ref.watch(networkServiceProvider);
      return StoreSyncNotifier(syncService, networkService);
    });

class StoreSyncNotifier extends StateNotifier<StoreSyncState> {
  final StoreSyncService _syncService;
  final NetworkService _networkService;
  Timer? _syncTimer;

  StoreSyncNotifier(this._syncService, this._networkService)
    : super(
        StoreSyncState(
          storeStatuses: {},
          lastSyncTimes: {},
          syncingStores: {},
          syncErrors: {},
        ),
      ) {
    _initializeSync();
  }

  void _initializeSync() {
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncAllStores(),
    );
  }

  Future<void> syncAllStores() async {
    for (final storeId in state.storeStatuses.keys) {
      if (!state.syncingStores.contains(storeId)) {
        await syncStore(storeId);
      }
    }
  }

  Future<void> syncStore(String storeId) async {
    if (!_networkService.isOnline) {
      _updateSyncError(storeId, 'No network connection');
      return;
    }

    state = state.copyWith(syncingStores: {...state.syncingStores, storeId});

    try {
      await _syncService.syncStoreData(storeId);

      state = state.copyWith(
        syncingStores: state.syncingStores.difference({storeId}),
        lastSyncTimes: {...state.lastSyncTimes, storeId: DateTime.now()},
        syncErrors: {...state.syncErrors}..remove(storeId),
      );
    } catch (e) {
      _updateSyncError(storeId, e.toString());
    }
  }

  void _updateSyncError(String storeId, String error) {
    state = state.copyWith(
      syncingStores: state.syncingStores.difference({storeId}),
      syncErrors: {...state.syncErrors, storeId: error},
    );
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}

// Service interfaces that would be implemented elsewhere
abstract class StoreSyncService {
  Future<void> syncStoreData(String storeId);
}

abstract class NetworkService {
  bool get isOnline;
}
