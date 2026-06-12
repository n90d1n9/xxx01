import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inventory_movement_record.dart';
import '../models/inventory_stock_record.dart';
import 'inventory_stock_detail_actions.dart';
import 'inventory_stock_detail_header.dart';
import 'inventory_stock_detail_metrics.dart';
import 'inventory_stock_detail_movements.dart';
import 'inventory_stock_detail_state.dart';

class InventoryStockDetailSheet extends StatelessWidget {
  const InventoryStockDetailSheet({
    super.key,
    required this.record,
    required this.movements,
    this.onClose,
    this.onIncreaseStock,
    this.onDecreaseStock,
    this.onTransferStock,
    this.currencyFormat,
  });

  final InventoryStockRecord record;
  final List<InventoryMovementRecord> movements;
  final VoidCallback? onClose;
  final VoidCallback? onIncreaseStock;
  final VoidCallback? onDecreaseStock;
  final VoidCallback? onTransferStock;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 820),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              InventoryStockDetailHeader(record: record, onClose: onClose),
              const SizedBox(height: 18),
              InventoryStockDetailMetrics(
                record: record,
                currencyFormat: currencyFormat,
              ),
              const SizedBox(height: 14),
              InventoryStockDetailActions(
                onIncreaseStock: onIncreaseStock,
                onDecreaseStock: onDecreaseStock,
                onTransferStock: onTransferStock,
              ),
              const SizedBox(height: 18),
              InventoryStockDetailRecentMovements(
                movements: inventoryStockDetailRecentMovements(movements),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
