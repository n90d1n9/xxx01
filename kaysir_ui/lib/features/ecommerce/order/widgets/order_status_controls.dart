import 'package:flutter/material.dart';

import '../../../../app/widgets/status_button.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_lifecycle.dart';
import '../models/order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final option = ecommerceOrderStatusFor(status);
    final color = ecommerceOrderStatusToneColor(context, option.tone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: Text(
        option.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class OrderStatusActionStrip extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final List<OrderStatusAction> actions;

  const OrderStatusActionStrip({
    super.key,
    required this.onChanged,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children:
          actions.map((action) {
            return Tooltip(
              message: action.description,
              child: StatusButton(
                label: action.label,
                color: ecommerceOrderStatusToneColor(context, action.tone),
                isSelected: false,
                onPressed: () => onChanged(action.value),
              ),
            );
          }).toList(),
    );
  }
}

Color ecommerceOrderStatusToneColor(
  BuildContext context,
  OrderStatusTone tone,
) {
  final colorScheme = Theme.of(context).colorScheme;

  return switch (tone) {
    OrderStatusTone.warning => Colors.orange,
    OrderStatusTone.progress => colorScheme.primary,
    OrderStatusTone.ready => Colors.teal,
    OrderStatusTone.success => Colors.green,
    OrderStatusTone.danger => Colors.red,
    OrderStatusTone.neutral => Colors.blueGrey,
  };
}
