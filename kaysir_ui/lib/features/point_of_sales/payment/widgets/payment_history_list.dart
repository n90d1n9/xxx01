import 'package:flutter/material.dart';

import '../../cashier/utils/pos_formatters.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../../order/models/order.dart';
import 'payment_method_icon.dart';

class PaymentHistoryList extends StatelessWidget {
  final Order order;

  const PaymentHistoryList({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Previous payments',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: POSUiTokens.gap),
        POSSurface(
          border: Border.all(color: theme.dividerColor),
          child: Column(
            children:
                order.payments.map((payment) {
                  return ListTile(
                    dense: true,
                    leading: Icon(paymentMethodIcon(payment.method)),
                    title: Text(payment.method),
                    subtitle: Text(
                      payment.reference,
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Text(
                      formatPOSCurrency(payment.amount),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
