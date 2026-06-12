import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/stockopname.dart';

final stockOpnameProvider =
    StateNotifierProvider<StockOpnameNotifier, List<StockOpname>>((ref) {
      return StockOpnameNotifier();
    });

class StockOpnameNotifier extends StateNotifier<List<StockOpname>> {
  StockOpnameNotifier()
    : super([
        StockOpname(
          id: '1',
          warehouseId: '1',
          date: DateTime.now().subtract(const Duration(days: 30)),
          conductedBy: 'John Doe',
          status: StockOpnameStatus.completed,
          items: [
            StockOpnameItem(
              id: '1',
              productId: '1',
              systemQuantity: 20,
              actualQuantity: 18,
            ),
            StockOpnameItem(
              id: '2',
              productId: '2',
              systemQuantity: 15,
              actualQuantity: 15,
            ),
          ],
        ),
      ]);

  void addStockOpname(StockOpname stockOpname) {
    state = [...state, stockOpname];
  }

  void updateStockOpname(StockOpname stockOpname) {
    state = state.map((s) => s.id == stockOpname.id ? stockOpname : s).toList();
  }
}
