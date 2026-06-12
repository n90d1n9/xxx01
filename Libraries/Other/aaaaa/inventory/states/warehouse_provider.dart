import 'package:flutter_riverpod/legacy.dart';

import '../models/warehouse.dart';

final warehousesProvider =
    StateNotifierProvider<WarehousesNotifier, List<Warehouse>>((ref) {
      return WarehousesNotifier();
    });

class WarehousesNotifier extends StateNotifier<List<Warehouse>> {
  WarehousesNotifier()
    : super([
        Warehouse(id: '1', name: 'Main Warehouse', location: 'Jakarta'),
        Warehouse(id: '2', name: 'North Warehouse', location: 'Surabaya'),
        Warehouse(id: '3', name: 'South Warehouse', location: 'Bandung'),
      ]);

  void addWarehouse(Warehouse warehouse) {
    state = [...state, warehouse];
  }

  void updateWarehouse(Warehouse warehouse) {
    state = state.map((w) => w.id == warehouse.id ? warehouse : w).toList();
  }

  void deleteWarehouse(String id) {
    state = state.where((w) => w.id != id).toList();
  }
}
