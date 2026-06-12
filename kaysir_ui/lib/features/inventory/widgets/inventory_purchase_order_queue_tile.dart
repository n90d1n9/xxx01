import 'package:flutter/material.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_purchase_order_workspace.dart';
import 'inventory_purchase_order_queue_metrics.dart';
import 'inventory_purchase_order_queue_status.dart';

class InventoryPurchaseOrderTile extends StatelessWidget {
  const InventoryPurchaseOrderTile({
    super.key,
    required this.record,
    this.onOpen,
  });

  final InventoryPurchaseOrderRecord record;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = inventoryPurchaseOrderStatusColor(record.status);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 860;
        final summary = InventoryPurchaseOrderQueueSummary(record: record);
        final status = InventoryPurchaseOrderQueueStatusPill(record: record);
        final metrics = InventoryPurchaseOrderQueueMetricStrip(record: record);
        final content =
            isCompact
                ? _CompactInventoryPurchaseOrderTile(
                  summary: summary,
                  status: status,
                  metrics: metrics,
                )
                : _ExpandedInventoryPurchaseOrderTile(
                  summary: summary,
                  status: status,
                  metrics: metrics,
                );

        return Material(
          color: statusColor.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onOpen,
            child: Padding(padding: const EdgeInsets.all(12), child: content),
          ),
        );
      },
    );
  }
}

class InventoryPurchaseOrderQueueSummary extends StatelessWidget {
  const InventoryPurchaseOrderQueueSummary({super.key, required this.record});

  final InventoryPurchaseOrderRecord record;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      icon: Icons.receipt_long_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      title: record.id,
      subtitle:
          '${record.supplierLabel} | ${record.itemCount} items | ${inventoryPurchaseOrderExpectedLabel(record)}',
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      padding: EdgeInsets.zero,
    );
  }
}

class InventoryPurchaseOrderQueueStatusPill extends StatelessWidget {
  const InventoryPurchaseOrderQueueStatusPill({
    super.key,
    required this.record,
  });

  final InventoryPurchaseOrderRecord record;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: record.isOverdue ? 'Overdue' : record.statusLabel,
      icon:
          record.isOverdue
              ? Icons.warning_amber_rounded
              : inventoryPurchaseOrderStatusIcon(record.status),
      color:
          record.isOverdue
              ? Colors.red.shade700
              : inventoryPurchaseOrderStatusColor(record.status),
      maxWidth: 140,
    );
  }
}

class _CompactInventoryPurchaseOrderTile extends StatelessWidget {
  const _CompactInventoryPurchaseOrderTile({
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

class _ExpandedInventoryPurchaseOrderTile extends StatelessWidget {
  const _ExpandedInventoryPurchaseOrderTile({
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
