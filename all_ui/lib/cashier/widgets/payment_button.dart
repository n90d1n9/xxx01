import 'package:flutter/material.dart';

import '../models/app_theme.dart';
import '../models/order.dart';

class PaymentButtons extends StatelessWidget {
  final Function(PaymentMethod) onPaymentSelected;

  const PaymentButtons({super.key, required this.onPaymentSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.payment),
            label: const Text('Pay with Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeCashier.primaryColor,
            ),
            onPressed: () => onPaymentSelected(PaymentMethod.card),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.attach_money),
            label: const Text('Pay with Cash'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => onPaymentSelected(PaymentMethod.cash),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.smartphone),
            label: const Text('Mobile Payment'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => onPaymentSelected(PaymentMethod.mobilePay),
          ),
        ],
      ),
    );
  }
}
