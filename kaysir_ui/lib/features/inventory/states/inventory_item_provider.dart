import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/inventory_item.dart';

final inventoryItemsProvider =
    StateNotifierProvider<InventoryItemsNotifier, List<InventoryItem>>((ref) {
      return InventoryItemsNotifier();
    });

class InventoryItemsNotifier extends StateNotifier<List<InventoryItem>> {
  InventoryItemsNotifier()
    : super([
        InventoryItem(
          id: '1',
          productId: '1',
          warehouseId: '1',
          currentQuantity: 15,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
        InventoryItem(
          id: '2',
          productId: '1',
          warehouseId: '2',
          currentQuantity: 8,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
        InventoryItem(
          id: '3',
          productId: '2',
          warehouseId: '1',
          currentQuantity: 20,
          reorderPoint: 10,
          reorderQuantity: 15,
        ),
        InventoryItem(
          id: '4',
          productId: '3',
          warehouseId: '1',
          currentQuantity: 4,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
      ]);

  void addInventoryItem(InventoryItem item) {
    state = [...state, item];
  }

  void updateInventoryItem(InventoryItem item) {
    state = state.map((i) => i.id == item.id ? item : i).toList();
  }

  void deleteInventoryItem(String id) {
    state = state.where((i) => i.id != id).toList();
  }

  void updateQuantity(String id, int newQuantity) {
    state =
        state
            .map(
              (i) => i.id == id ? i.copyWith(currentQuantity: newQuantity) : i,
            )
            .toList();
  }
}
