import 'package:flutter_riverpod/legacy.dart';

import '../models/inventory_item.dart';

class InventoryNotifier extends StateNotifier<List<InventoryItem>> {
  InventoryNotifier()
    : super([
        // Some initial dummy data
        InventoryItem(
          id: '1',
          name: 'Tomatoes',
          quantity: 5.0,
          unit: 'kg',
          price: 2.5,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
        ),
        InventoryItem(
          id: '2',
          name: 'Chicken',
          quantity: 10.0,
          unit: 'kg',
          price: 8.0,
          expiryDate: DateTime.now().add(const Duration(days: 3)),
        ),
      ]);

  void addItem(InventoryItem item) {
    state = [...state, item];
  }

  void updateItem(InventoryItem updatedItem) {
    state = state
        .map((item) => item.id == updatedItem.id ? updatedItem : item)
        .toList();
  }

  void deleteItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateQuantity(String id, double newQuantity) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
  }

  List<InventoryItem> getLowStockItems() {
    // Example threshold, could be adjusted per item in a real app
    return state.where((item) => item.quantity < 2.0).toList();
  }

  List<InventoryItem> getExpiringItems() {
    final nextWeek = DateTime.now().add(const Duration(days: 7));
    return state.where((item) => item.expiryDate.isBefore(nextWeek)).toList();
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, List<InventoryItem>>(
      (ref) => InventoryNotifier(),
    );
