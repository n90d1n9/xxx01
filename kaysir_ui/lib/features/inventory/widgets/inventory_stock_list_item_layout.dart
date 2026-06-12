import 'package:flutter/material.dart';

import '../models/inventory_stock_record.dart';
import 'inventory_stock_status_pill.dart';

class InventoryStockListItemLayout extends StatelessWidget {
  const InventoryStockListItemLayout({
    super.key,
    required this.isCompact,
    required this.productSummary,
    required this.details,
    required this.actions,
    required this.status,
  });

  final bool isCompact;
  final Widget productSummary;
  final Widget details;
  final Widget actions;
  final InventoryStockStatus status;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return InventoryStockCompactListItemLayout(
        productSummary: productSummary,
        details: details,
        actions: actions,
        status: status,
      );
    }

    return InventoryStockExpandedListItemLayout(
      productSummary: productSummary,
      details: details,
      actions: actions,
      status: status,
    );
  }
}

class InventoryStockCompactListItemLayout extends StatelessWidget {
  const InventoryStockCompactListItemLayout({
    super.key,
    required this.productSummary,
    required this.details,
    required this.actions,
    required this.status,
  });

  final Widget productSummary;
  final Widget details;
  final Widget actions;
  final InventoryStockStatus status;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: productSummary),
            const SizedBox(width: 10),
            InventoryStockStatusPill(status: status),
          ],
        ),
        const SizedBox(height: 12),
        details,
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerRight, child: actions),
      ],
    );
  }
}

class InventoryStockExpandedListItemLayout extends StatelessWidget {
  const InventoryStockExpandedListItemLayout({
    super.key,
    required this.productSummary,
    required this.details,
    required this.actions,
    required this.status,
  });

  final Widget productSummary;
  final Widget details;
  final Widget actions;
  final InventoryStockStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: productSummary),
        const SizedBox(width: 14),
        Flexible(flex: 2, child: details),
        const SizedBox(width: 12),
        InventoryStockStatusPill(status: status),
        const SizedBox(width: 6),
        actions,
      ],
    );
  }
}
