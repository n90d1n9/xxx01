import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_purchase_order_detail.dart';
import 'inventory_purchase_order_detail_status_styles.dart';

class InventoryPurchaseOrderActionsPanel extends StatelessWidget {
  const InventoryPurchaseOrderActionsPanel({
    super.key,
    required this.detail,
    this.onReceive,
    this.onCancel,
  });

  final InventoryPurchaseOrderDetail detail;
  final VoidCallback? onReceive;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContentPanel(
      title: detail.isClosed ? 'Order Closed' : 'Receiving Actions',
      subtitle: detail.receivingGuidance,
      leadingIcon:
          detail.isClosed ? Icons.verified_rounded : Icons.task_alt_rounded,
      child:
          detail.isClosed
              ? _ClosedPurchaseOrderActionState(detail: detail)
              : _OpenPurchaseOrderActions(
                detail: detail,
                onReceive: onReceive,
                onCancel: onCancel,
                errorColor: colorScheme.error,
              ),
    );
  }
}

class _ClosedPurchaseOrderActionState extends StatelessWidget {
  const _ClosedPurchaseOrderActionState({required this.detail});

  final InventoryPurchaseOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    final color = purchaseOrderDetailStatusColor(
      detail.status,
      detail.isOverdue,
    );

    return AppInfoRow(
      title: detail.statusLabel,
      subtitle: 'No further receiving actions are available.',
      icon: purchaseOrderDetailStatusIcon(detail.status),
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
    );
  }
}

class _OpenPurchaseOrderActions extends StatelessWidget {
  const _OpenPurchaseOrderActions({
    required this.detail,
    required this.errorColor,
    this.onReceive,
    this.onCancel,
  });

  final InventoryPurchaseOrderDetail detail;
  final Color errorColor;
  final VoidCallback? onReceive;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: detail.canReceive ? onReceive : null,
          icon: const Icon(Icons.inventory_rounded),
          label: const Text('Mark as Received'),
        ),
        OutlinedButton.icon(
          onPressed: detail.canCancel ? onCancel : null,
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancel Order'),
          style: OutlinedButton.styleFrom(
            foregroundColor: errorColor,
            side: BorderSide(color: errorColor.withValues(alpha: 0.45)),
          ),
        ),
      ],
    );
  }
}
