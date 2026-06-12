import 'package:flutter_riverpod/legacy.dart';

import '../models/inventory_movement.dart';

final inventoryMovementsProvider =
    StateNotifierProvider<InventoryMovementsNotifier, List<InventoryMovement>>((
      ref,
    ) {
      return InventoryMovementsNotifier();
    });

class InventoryMovementsNotifier
    extends StateNotifier<List<InventoryMovement>> {
  InventoryMovementsNotifier()
    : super([
        InventoryMovement(
          id: '1',
          productId: '1',
          sourceWarehouseId: '1',
          quantity: 5,
          type: MovementType.sale,
          date: DateTime.now().subtract(const Duration(days: 5)),
          reference: 'SO-001',
        ),
        InventoryMovement(
          id: '2',
          productId: '2',
          sourceWarehouseId: '1',
          quantity: 10,
          type: MovementType.purchase,
          date: DateTime.now().subtract(const Duration(days: 10)),
          reference: 'PO-001',
        ),
      ]);

  void addMovement(InventoryMovement movement) {
    state = [...state, movement];
  }
}
