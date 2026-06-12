import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../models/customer.dart';
import '../models/invoice.dart';
import '../states/customer_provider.dart';
import 'invoice_detail_screen.dart';

class InvoiceListItem extends ConsumerWidget {
  final Invoice invoice;

  const InvoiceListItem({super.key, required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider3);
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final dueDate = invoice.dueDate;
    final invoiceLabel =
        invoice.invoiceNumber ?? invoice.reference ?? invoice.id;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailScreen(invoiceId: invoice.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusIndicator(invoice.status.name),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoiceLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatter.format(invoice.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  customersAsync.when(
                    loading: () => Text('Loading...'),
                    error: (err, stack) => Text('Error loading customer'),
                    data: (customers) {
                      final customer = customers.firstWhere(
                        (c) => c.id == invoice.customerId,
                        orElse:
                            () => Customer(
                              id: '',
                              name: 'Unknown Customer',
                              email: '',
                              phone: '',
                            ),
                      );
                      return Text(customer.name);
                    },
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dueDate == null
                            ? 'No due date'
                            : 'Due: ${DateFormat('MMM d, yyyy').format(dueDate)}',
                        style: TextStyle(
                          color:
                              invoice.isOverdue ? Colors.red : Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                      Text(
                        invoice.isOverdue
                            ? '${invoice.daysOverdue} days overdue'
                            : _getStatusText(invoice.status.name),
                        style: TextStyle(
                          color:
                              invoice.isOverdue ? Colors.red : Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  if (invoice.paidAmount > 0 && invoice.remainingAmount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: LinearProgressIndicator(
                        value:
                            invoice.amount == 0
                                ? 0
                                : invoice.paidAmount / invoice.amount,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status) {
      case 'paid':
        color = Colors.green;
        break;
      case 'partial':
      case 'partiallyPaid':
        color = Colors.blue;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'overdue':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 12.0,
      height: 12.0,
      margin: const EdgeInsets.only(top: 4.0),
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'partial':
      case 'partiallyPaid':
        return 'Partially Paid';
      case 'pending':
        return 'Pending Payment';
      case 'overdue':
        return 'Overdue';
      default:
        return status.toUpperCase();
    }
  }
}
