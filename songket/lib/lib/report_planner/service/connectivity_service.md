// Connectivity Service
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/agenda_item.dart';
import '../state/agenda_items_provider.dart';
import '../state/filter_items_provider.dart';
import 'auth_service.dart';
import 'cloud_service.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get isOnline => _connectivity.onConnectivityChanged.map(
    (result) => result != ConnectivityResult.none,
  );

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

// Providers
final authServiceProvider = Provider((ref) => AuthService());
final cloudSyncServiceProvider = Provider((ref) => CloudSyncService());
final connectivityServiceProvider = Provider((ref) => ConnectivityService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).isOnline;
});

final lastSyncTimeProvider = StateProvider<DateTime?>((ref) => null);
final paginationLimitProvider = StateProvider<int>((ref) => 50);

final paginatedItemsProvider = Provider<List<AgendaItem>>((ref) {
  final allItems = ref.watch(filteredItemsProvider);
  final limit = ref.watch(paginationLimitProvider);

  return allItems.take(limit).toList();
});

// Cache Provider for expensive computations
final categoryCacheProvider = Provider<Map<String, CategoryStats>>((ref) {
  final items = ref.read(agendaItemsProvider).value ?? [];
  final cache = <String, CategoryStats>{};

  for (final item in items) {
    if (!cache.containsKey(item.category)) {
      cache[item.category] = CategoryStats(
        category: item.category,
        totalEvents: 0,
        completedEvents: 0,
        totalHours: 0,
      );
    }

    final stats = cache[item.category]!;
    stats.totalEvents++;
    if (item.isCompleted) stats.completedEvents++;
    stats.totalHours += item.endTime.difference(item.startTime).inHours;
  }

  return cache;
});

class CategoryStats {
  final String category;
  int totalEvents;
  int completedEvents;
  double totalHours;

  CategoryStats({
    required this.category,
    required this.totalEvents,
    required this.completedEvents,
    required this.totalHours,
  });
}
