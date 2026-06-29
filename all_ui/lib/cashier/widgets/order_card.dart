import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';
import 'status_button.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final Function(OrderStatus) onStatusChanged;

  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  String _getPaymentMethodString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.mobilePay:
        return 'Mobile Pay';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          order.id,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${dateFormat.format(order.dateTime)} • ${_getPaymentMethodString(order.paymentMethod)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStatusString(order.status),
                style: TextStyle(
                  color: _getStatusColor(order.status),
                  fontSize: 12,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${order.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Text('${item.quantity}x'),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.product.name)),
                        Text('\$${item.total.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total'),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Update Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusButton(
                      label: 'Pending',
                      color: Colors.orange,
                      isSelected: order.status == OrderStatus.pending,
                      onPressed: () => onStatusChanged(OrderStatus.pending),
                    ),
                    const SizedBox(width: 8),
                    StatusButton(
                      label: 'Completed',
                      color: Colors.green,
                      isSelected: order.status == OrderStatus.completed,
                      onPressed: () => onStatusChanged(OrderStatus.completed),
                    ),
                    const SizedBox(width: 8),
                    StatusButton(
                      label: 'Cancelled',
                      color: Colors.red,
                      isSelected: order.status == OrderStatus.cancelled,
                      onPressed: () => onStatusChanged(OrderStatus.cancelled),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
