import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/warehouse.dart';
import 'inventory_branch_provider.dart';

final warehousesProvider =
    StateNotifierProvider<WarehousesNotifier, List<Warehouse>>((ref) {
      return WarehousesNotifier();
    });

class WarehousesNotifier extends StateNotifier<List<Warehouse>> {
  WarehousesNotifier()
    : super([
        Warehouse(
          id: '1',
          name: 'Main Warehouse',
          branchId: inventoryBranchJakartaCentralId,
          branchName: 'Jakarta Central',
          location: 'Jakarta',
        ),
        Warehouse(
          id: '2',
          name: 'North Warehouse',
          branchId: inventoryBranchSurabayaNorthId,
          branchName: 'Surabaya North',
          location: 'Surabaya',
        ),
        Warehouse(
          id: '3',
          name: 'South Warehouse',
          branchId: inventoryBranchBandungSouthId,
          branchName: 'Bandung South',
          location: 'Bandung',
        ),
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

  void updateBranchLabel({
    required String branchId,
    required String branchName,
  }) {
    state =
        state
            .map(
              (warehouse) =>
                  warehouse.branchId == branchId
                      ? warehouse.copyWith(branchName: branchName)
                      : warehouse,
            )
            .toList();
  }
}
