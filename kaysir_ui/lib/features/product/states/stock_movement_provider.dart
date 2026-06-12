import 'package:flutter_riverpod/legacy.dart';

// Inventory Movements

import '../../inventory/models/movement_type.dart';
import '../../inventory/models/stock_movement.dart';

final stockMovementsProvider =
    StateNotifierProvider<StockMovementsNotifier, List<StockMovement>>((ref) {
      return StockMovementsNotifier();
    });

class StockMovementsNotifier extends StateNotifier<List<StockMovement>> {
  StockMovementsNotifier()
    : super([
        StockMovement(
          id: '1',
          productId: '1',
          sourceWarehouseId: '1',
          quantity: 5,
          type: MovementType.sale,
          date: DateTime.now().subtract(const Duration(days: 5)),
          reference: 'SO-001',
        ),
        StockMovement(
          id: '2',
          productId: '2',
          sourceWarehouseId: '1',
          quantity: 10,
          type: MovementType.purchase,
          date: DateTime.now().subtract(const Duration(days: 10)),
          reference: 'PO-001',
        ),
      ]);

  void addMovement(StockMovement movement) {
    state = [...state, movement];
  }
}
