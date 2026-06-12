import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inventory_stock_record.dart';
import 'inventory_separated_list.dart';
import 'inventory_stock_list_item.dart';

class InventoryStockList extends StatelessWidget {
  const InventoryStockList({
    super.key,
    required this.records,
    this.onViewDetails,
    this.onIncreaseStock,
    this.onDecreaseStock,
    this.onTransferStock,
    this.currencyFormat,
  });

  final List<InventoryStockRecord> records;
  final ValueChanged<InventoryStockRecord>? onViewDetails;
  final ValueChanged<InventoryStockRecord>? onIncreaseStock;
  final ValueChanged<InventoryStockRecord>? onDecreaseStock;
  final ValueChanged<InventoryStockRecord>? onTransferStock;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    return InventorySeparatedList<InventoryStockRecord>(
      items: records,
      itemBuilder: (context, record, index) {
        return InventoryStockListItem(
          record: record,
          onViewDetails:
              onViewDetails == null ? null : () => onViewDetails!(record),
          onIncreaseStock:
              onIncreaseStock == null ? null : () => onIncreaseStock!(record),
          onDecreaseStock:
              onDecreaseStock == null ? null : () => onDecreaseStock!(record),
          onTransferStock:
              onTransferStock == null ? null : () => onTransferStock!(record),
          currencyFormat: currencyFormat,
        );
      },
    );
  }
}
