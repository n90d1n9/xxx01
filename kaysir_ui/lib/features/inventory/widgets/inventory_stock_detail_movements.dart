import 'package:flutter/material.dart';

import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_text_cluster.dart';
import '../models/inventory_movement_record.dart';
import 'inventory_movement_history_components.dart';
import 'inventory_separated_list.dart';
import 'inventory_stock_detail_state.dart';
import 'inventory_tile_surface.dart';

class InventoryStockDetailRecentMovements extends StatelessWidget {
  const InventoryStockDetailRecentMovements({
    super.key,
    required this.movements,
  });

  final List<InventoryMovementRecord> movements;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InventoryTileSurface(
      backgroundColor: colorScheme.surfaceContainerLow,
      borderColor: colorScheme.outlineVariant,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextCluster(
            title: 'Recent Movements',
            subtitle: inventoryStockDetailMovementSubtitle(movements.length),
          ),
          const SizedBox(height: 12),
          if (movements.isEmpty)
            const AppEmptyState(
              title: 'No related movements',
              message:
                  'Stock events for this product-location will appear here.',
              icon: Icons.timeline_rounded,
            )
          else
            InventorySeparatedList<InventoryMovementRecord>(
              items: movements,
              itemBuilder:
                  (context, movement, index) =>
                      InventoryMovementTimelineTile(record: movement),
            ),
        ],
      ),
    );
  }
}
