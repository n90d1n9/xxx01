import 'package:flutter_riverpod/legacy.dart';

import '../models/shopping_item.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>((ref) {
      return ShoppingListNotifier(ref.watch(storageProvider));
    });

// Enhanced ShoppingListNotifier
class ShoppingListNotifier extends StateNotifier<List<ShoppingItem>> {
  final StorageService storage;

  ShoppingListNotifier(this.storage) : super([]) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    state = await storage.loadShoppingList();
  }

  Future<void> addItem(
    String name,
    double price,
    int quantity,
    String category,
    String? notes,
    String? budgetCategory,
  ) async {
    state = [
      ...state,
      ShoppingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        price: price,
        quantity: quantity,
        purchased: false,
        category: category,
        notes: notes,
        addedDate: DateTime.now(),
        budgetCategory: budgetCategory,
      ),
    ];
    await storage.saveShoppingList(state);
  }

  Future<void> togglePurchased(String id) async {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(
            purchased: !item.purchased,
            purchasedDate: !item.purchased ? DateTime.now() : null,
          )
        else
          item,
    ];
    await storage.saveShoppingList(state);
  }

  // Get shopping items by date range
  List<ShoppingItem> getItemsByDateRange(DateTime start, DateTime end) {
    return state
        .where(
          (item) =>
              item.addedDate.isAfter(start.subtract(const Duration(days: 1))) &&
              item.addedDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  // Get shopping items by budget category
  List<ShoppingItem> getItemsByBudgetCategory(String budgetCategory) {
    return state
        .where((item) => item.budgetCategory == budgetCategory)
        .toList();
  }

  Future<void> updateItem(ShoppingItem updatedItem) async {
    state = [
      for (final item in state)
        if (item.id == updatedItem.id) updatedItem else item,
    ];
    await storage.saveShoppingList(state);
  }

  Future<void> deleteItem(String id) async {
    state = state.where((item) => item.id != id).toList();
    await storage.saveShoppingList(state);
  }

  Future<void> clearPurchased() async {
    state = state.where((item) => !item.purchased).toList();
    await storage.saveShoppingList(state);
  }
}
