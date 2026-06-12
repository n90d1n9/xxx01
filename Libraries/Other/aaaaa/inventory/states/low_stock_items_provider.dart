import 'package:flutter_riverpod/legacy.dart';

import '../models/inventory_item.dart';
import 'inventory_item_provider.dart';

final lowStockItemsProvider = Provider<List<InventoryItem>>((ref) {
  final inventoryItems = ref.watch(inventoryItemsProvider);
  return inventoryItems.where((item) => item.needsReorder).toList();
});
