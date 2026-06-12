import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_purchase_order_workspace.dart';
import 'inventory_purchase_order_empty_state.dart';
import 'inventory_purchase_order_queue_tile.dart';

/// Panel that presents the filtered purchase-order queue and recovery states.
class InventoryPurchaseOrderPanel extends StatelessWidget {
  const InventoryPurchaseOrderPanel({
    super.key,
    required this.records,
    this.hasActiveFilters = false,
    this.onOpen,
    this.onClearFilters,
    this.onCreateOrder,
  });

  final List<InventoryPurchaseOrderRecord> records;
  final bool hasActiveFilters;
  final ValueChanged<InventoryPurchaseOrderRecord>? onOpen;
  final VoidCallback? onClearFilters;
  final VoidCallback? onCreateOrder;

  @override
  Widget build(BuildContext context) {
    final overdueCount = records.where((record) => record.isOverdue).length;

    return AppContentPanel(
      title: 'Purchase Order Queue',
      subtitle: 'Supplier commitments, receiving status, and expected arrivals',
      leadingIcon: Icons.assignment_turned_in_rounded,
      trailing:
          records.isEmpty
              ? null
              : AppStatusPill(
                label: _queueStatusLabel(
                  visibleCount: records.length,
                  overdueCount: overdueCount,
                ),
                tooltip:
                    '${records.length} visible purchase orders, $overdueCount overdue',
                icon:
                    overdueCount == 0
                        ? Icons.check_circle_rounded
                        : Icons.warning_amber_rounded,
                color:
                    overdueCount == 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                maxWidth: 190,
              ),
      child:
          records.isEmpty
              ? InventoryPurchaseOrderEmptyState(
                hasActiveFilters: hasActiveFilters,
                onClearFilters: onClearFilters,
                onCreateOrder: onCreateOrder,
              )
              : _InventoryPurchaseOrderQueueList(
                records: records,
                onOpen: onOpen,
              ),
    );
  }
}

String _queueStatusLabel({
  required int visibleCount,
  required int overdueCount,
}) {
  return '$visibleCount visible, $overdueCount overdue';
}

/// Vertical list of purchase-order queue tiles with stable row spacing.
class _InventoryPurchaseOrderQueueList extends StatelessWidget {
  const _InventoryPurchaseOrderQueueList({required this.records, this.onOpen});

  final List<InventoryPurchaseOrderRecord> records;
  final ValueChanged<InventoryPurchaseOrderRecord>? onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < records.length; index += 1) ...[
          InventoryPurchaseOrderTile(
            record: records[index],
            onOpen: onOpen == null ? null : () => onOpen!(records[index]),
          ),
          if (index != records.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
