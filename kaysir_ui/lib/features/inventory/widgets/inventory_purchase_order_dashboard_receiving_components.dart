import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_info_row.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_purchase_order_workspace.dart';
import '../utils/inventory_formatters.dart';

class InventoryPurchaseOrderReceivingPanel extends StatelessWidget {
  const InventoryPurchaseOrderReceivingPanel({
    super.key,
    required this.records,
    this.onOpenOrder,
  });

  final List<InventoryPurchaseOrderRecord> records;
  final ValueChanged<InventoryPurchaseOrderRecord>? onOpenOrder;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Receiving Queue',
      subtitle: '${records.length} purchase orders waiting for receiving',
      leadingIcon: Icons.local_shipping_rounded,
      child:
          records.isEmpty
              ? const AppEmptyState(
                title: 'No purchase orders waiting',
                message:
                    'Pending and confirmed purchase orders will appear here.',
                icon: Icons.check_circle_rounded,
              )
              : Column(
                children: [
                  for (var index = 0; index < records.length; index += 1) ...[
                    InventoryPurchaseOrderReceivingTile(
                      record: records[index],
                      onTap:
                          onOpenOrder == null
                              ? null
                              : () => onOpenOrder!(records[index]),
                    ),
                    if (index != records.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
    );
  }
}

class InventoryPurchaseOrderReceivingTile extends StatelessWidget {
  const InventoryPurchaseOrderReceivingTile({
    super.key,
    required this.record,
    this.onTap,
  });

  final InventoryPurchaseOrderRecord record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        record.isOverdue ? Colors.red.shade700 : Colors.indigo.shade700;
    final expectedLabel = _expectedDeliveryLabel(record);

    return AppInfoRow(
      title: record.id,
      subtitle:
          '${record.supplierLabel} | ${record.totalUnits} units | $expectedLabel',
      icon:
          record.isOverdue
              ? Icons.report_rounded
              : Icons.local_shipping_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      onTap: onTap,
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: record.isOverdue ? 'Overdue' : record.statusLabel,
            color: color,
            icon:
                record.isOverdue
                    ? Icons.priority_high_rounded
                    : Icons.schedule_rounded,
            maxWidth: 120,
          ),
          Text(
            formatInventoryCurrency(record.totalAmount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

String _expectedDeliveryLabel(InventoryPurchaseOrderRecord record) {
  final expectedDate = record.expectedDeliveryDate;
  if (expectedDate == null) return 'No expected date';
  final formatted = formatInventoryDate(expectedDate);
  if (record.isOverdue) return 'Expected $formatted';
  final days = record.daysUntilExpected;
  if (days == null) return 'Expected $formatted';
  if (days == 0) return 'Due today';
  if (days == 1) return 'Due tomorrow';
  if (days > 1) return 'Due in $days days';
  return 'Expected $formatted';
}
