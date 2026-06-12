import 'package:flutter/material.dart';

/// Responsive layout for a low-stock report line tile.
class InventoryLowStockReportTileLayout extends StatelessWidget {
  const InventoryLowStockReportTileLayout({
    super.key,
    required this.isCompact,
    required this.summary,
    required this.status,
    required this.metrics,
  });

  final bool isCompact;
  final Widget summary;
  final Widget status;
  final Widget metrics;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return InventoryLowStockReportCompactTileLayout(
        summary: summary,
        status: status,
        metrics: metrics,
      );
    }

    return InventoryLowStockReportExpandedTileLayout(
      summary: summary,
      status: status,
      metrics: metrics,
    );
  }
}

/// Compact stacked layout for narrow low-stock report tiles.
class InventoryLowStockReportCompactTileLayout extends StatelessWidget {
  const InventoryLowStockReportCompactTileLayout({
    super.key,
    required this.summary,
    required this.status,
    required this.metrics,
  });

  final Widget summary;
  final Widget status;
  final Widget metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        summary,
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerLeft, child: status),
        const SizedBox(height: 12),
        metrics,
      ],
    );
  }
}

/// Expanded horizontal layout for wide low-stock report tiles.
class InventoryLowStockReportExpandedTileLayout extends StatelessWidget {
  const InventoryLowStockReportExpandedTileLayout({
    super.key,
    required this.summary,
    required this.status,
    required this.metrics,
  });

  final Widget summary;
  final Widget status;
  final Widget metrics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: summary),
        const SizedBox(width: 14),
        Flexible(flex: 2, child: metrics),
        const SizedBox(width: 12),
        status,
      ],
    );
  }
}
