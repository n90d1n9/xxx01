import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../models/dashboard_item.dart';
import '../services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

final dashboardItemsProvider =
    StateNotifierProvider<DashboardItemsNotifier, List<DashboardItem>>((ref) {
      final dashboardService = ref.watch(dashboardServiceProvider);
      return DashboardItemsNotifier(dashboardService);
    });

class DashboardItemsNotifier extends StateNotifier<List<DashboardItem>> {
  final DashboardService _dashboardService;
  final Uuid _uuid = const Uuid();

  DashboardItemsNotifier(this._dashboardService) : super([]) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final items = await _dashboardService.getDashboardItems();
      state = items;
    } catch (e) {
      // Handle error
      state = [];
    }
  }

  Future<void> refreshData() async {
    await loadItems();
  }

  void addItem(
    String title,
    DashboardItemType type,
    Map<String, dynamic> data, {
    int gridWidth = 1,
    int gridHeight = 1,
  }) {
    final newItem = DashboardItem(
      id: _uuid.v4(),
      title: title,
      type: type,
      data: data,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
    );

    state = [...state, newItem];
    _dashboardService.saveDashboardItems(state);
  }

  void updateItem(DashboardItem updatedItem) {
    state =
        state.map((item) {
          if (item.id == updatedItem.id) {
            return updatedItem;
          }
          return item;
        }).toList();

    _dashboardService.saveDashboardItems(state);
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
    _dashboardService.saveDashboardItems(state);
  }

  void reorderItems(List<DashboardItem> newOrder) {
    state = newOrder;
    _dashboardService.saveDashboardItems(state);
  }
}
