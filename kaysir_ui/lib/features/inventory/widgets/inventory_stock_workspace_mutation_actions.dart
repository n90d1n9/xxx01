import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/inventory_stock_mutation_application_service.dart';
import '../services/inventory_stock_mutation_service.dart';
import '../states/inventory_item_provider.dart';
import '../states/inventory_movement_provider.dart';

void applyInventoryStockWorkspaceMutation({
  required WidgetRef ref,
  required InventoryStockMutation mutation,
}) {
  InventoryStockMutationApplication(
    addInventoryItem:
        ref.read(inventoryItemsProvider.notifier).addInventoryItem,
    updateQuantity: ref.read(inventoryItemsProvider.notifier).updateQuantity,
    addMovement: ref.read(inventoryMovementsProvider.notifier).addMovement,
  ).apply(mutation);
}
