import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_purchase_order_detail.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_purchase_order_detail_status_pill.dart';
import 'inventory_purchase_order_detail_status_styles.dart';

class InventoryPurchaseOrderOverviewPanel extends StatelessWidget {
  const InventoryPurchaseOrderOverviewPanel({super.key, required this.detail});

  final InventoryPurchaseOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Order Overview',
      subtitle: 'Supplier, delivery, and receiving context',
      leadingIcon: Icons.receipt_long_rounded,
      trailing: InventoryPurchaseOrderDetailStatusPill(detail: detail),
      child: Column(
        children: [
          AppInfoRow(
            title: 'Supplier',
            subtitle: detail.supplierLabel,
            icon: Icons.business_rounded,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
          ),
          const SizedBox(height: 10),
          AppInfoRow(
            title: 'Order date',
            subtitle: formatInventoryDate(detail.orderDate),
            icon: Icons.calendar_month_rounded,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            trailing: Text(
              detail.id,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          AppInfoRow(
            title: 'Expected delivery',
            subtitle: purchaseOrderDetailExpectedDateLabel(detail),
            icon:
                detail.isOverdue
                    ? Icons.report_rounded
                    : Icons.local_shipping_rounded,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor:
                detail.isOverdue ? Colors.red.withValues(alpha: 0.12) : null,
            iconForegroundColor: detail.isOverdue ? Colors.red.shade700 : null,
          ),
          if (detail.notes != null) ...[
            const SizedBox(height: 10),
            AppInfoRow(
              title: 'Notes',
              subtitle: detail.notes,
              icon: Icons.notes_rounded,
              iconStyle: AppInfoRowIconStyle.badge,
              contained: true,
              subtitleMaxLines: 4,
            ),
          ],
        ],
      ),
    );
  }
}
