import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/payment.dart';

class PaymentListItem extends StatelessWidget {
  final Payment payment;
  final String invoiceNumber;
  final VoidCallback onTap;

  const PaymentListItem({
    super.key,
    required this.payment,
    required this.invoiceNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final paymentDate = payment.paymentDate;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.green[100],
        child: const Icon(Icons.attach_money, color: Colors.green),
      ),
      title: const Text(
        'Payment received',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4.0),
          Text(
            'Invoice #$invoiceNumber',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Date: ${paymentDate == null ? 'Not recorded' : DateFormat('MMM d, yyyy').format(paymentDate)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Method: ${payment.method ?? 'Unspecified'}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: Text(
        formatter.format(payment.amount),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
          color: Colors.green,
        ),
      ),
    );
  }
}
