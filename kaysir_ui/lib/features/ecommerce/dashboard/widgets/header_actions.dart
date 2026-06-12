import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'action_button.dart';

class HeaderActions extends StatelessWidget {
  const HeaderActions({
    required this.onOpenCheckout,
    required this.onOpenOrders,
    this.alignment = WrapAlignment.end,
    super.key,
  });

  final VoidCallback onOpenCheckout;
  final VoidCallback onOpenOrders;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      alignment: alignment,
      children: [
        ActionButton(
          icon: Icons.point_of_sale_outlined,
          label: 'Open checkout',
          onPressed: onOpenCheckout,
          variant: ActionButtonVariant.primary,
        ),
        ActionButton(
          icon: Icons.receipt_long_outlined,
          label: 'Review orders',
          onPressed: onOpenOrders,
        ),
      ],
    );
  }
}
