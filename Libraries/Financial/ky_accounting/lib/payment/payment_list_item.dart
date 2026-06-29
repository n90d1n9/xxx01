import 'package:flutter/material.dart';

class PaymentListItem extends StatelessWidget {
  final Payment payment;
  final String invoiceNumber;
  final VoidCallback onTap;

  const PaymentListItem({
    Key? key,
    required this.payment,
    required this.invoiceNumber,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        backgroundColor: Colors.green[100],
        child: Icon(Icons.attach_money, color: Colors.green),
      ),
      title: Text(
        'Payment received',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.0),
          Text(
            'Invoice #${invoiceNumber}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 4.0),
          Text(
            'Date: ${DateFormat('MMM d, yyyy').format(payment.date)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 4.0),
          Text(
            'Method: ${payment.method}',
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
