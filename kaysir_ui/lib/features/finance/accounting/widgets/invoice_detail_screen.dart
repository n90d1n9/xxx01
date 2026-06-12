import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../models/customer.dart';
import '../models/invoice.dart';
import '../states/customer_provider.dart';
import '../states/invoice_provider.dart';
import 'add_payment_dialog.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider).invoices;
    final customersAsync = ref.watch(customersProvider3);
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Invoice Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  break;
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
                case 'send':
                  _showSendConfirmation(context);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit Invoice'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'send',
                    child: Row(
                      children: [
                        Icon(Icons.send, size: 18),
                        SizedBox(width: 8),
                        Text('Send Reminder'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Delete Invoice',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final invoice = _findInvoice(invoices, invoiceId);
          if (invoice == null) {
            return const Center(child: Text('Invoice not found'));
          }
          final payments = invoice.payments ?? const [];
          final paymentProgress = _paymentProgress(invoice);

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              // Invoice Header Card
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            invoice.id,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildStatusChip(invoice.status.name),
                        ],
                      ),
                      SizedBox(height: 16.0),
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                customer.name,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                customer.email,
                                style: TextStyle(fontSize: 14.0),
                              ),
                              SizedBox(height: 2.0),
                              Text(
                                customer.phone,
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // Invoice Details Card
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice Details',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      _buildDetailRow(
                        'Total Amount',
                        formatter.format(invoice.amount),
                      ),
                      _buildDetailRow(
                        'Issued Date',
                        _formatDate(invoice.issueDate),
                      ),
                      _buildDetailRow('Due Date', _formatDate(invoice.dueDate)),
                      _buildDetailRow(
                        'Status',
                        _getFullStatusText(invoice.status.name),
                      ),
                      if (invoice.isOverdue)
                        _buildDetailRow(
                          'Days Overdue',
                          '${invoice.daysOverdue}',
                          isAlert: true,
                        ),
                      _buildDetailRow(
                        'Amount Paid',
                        formatter.format(invoice.paidAmount),
                      ),
                      _buildDetailRow(
                        'Amount Due',
                        formatter.format(invoice.remainingAmount),
                      ),

                      if (invoice.paidAmount > 0 && invoice.remainingAmount > 0)
                        Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Progress',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8.0),
                              LinearProgressIndicator(
                                value: paymentProgress,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                                minHeight: 10.0,
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                '${(paymentProgress * 100).toStringAsFixed(1)}% paid',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // Payments Card
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment History',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (invoice.remainingAmount > 0)
                            FilledButton.icon(
                              icon: const Icon(Icons.payments_outlined),
                              label: const Text('Record Payment'),
                              onPressed: () {
                                _showRecordPaymentDialog(context, invoice);
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      payments.isEmpty
                          ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'No payments recorded',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: payments.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (context, index) {
                              final payment = payments[index];
                              final paymentMethod =
                                  payment.method ?? 'bank_transfer';
                              final paymentReference =
                                  payment.reference ??
                                  payment.referenceNumber ??
                                  'No reference';
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(formatter.format(payment.amount)),
                                subtitle: Text(
                                  '${_capitalizeMethod(paymentMethod)} - $paymentReference',
                                ),
                                trailing: Text(
                                  _formatShortDate(payment.paymentDate),
                                ),
                                leading: Icon(
                                  _getPaymentIcon(paymentMethod),
                                  color: Colors.green,
                                ),
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Invoice? _findInvoice(List<Invoice> invoices, String invoiceId) {
    for (final invoice in invoices) {
      if (invoice.id == invoiceId) {
        return invoice;
      }
    }
    return null;
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not set';
    }
    return DateFormat('MMMM d, yyyy').format(date);
  }

  String _formatShortDate(DateTime? date) {
    if (date == null) {
      return 'No date';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  double _paymentProgress(Invoice invoice) {
    if (invoice.amount <= 0) {
      return 0;
    }
    return (invoice.paidAmount / invoice.amount).clamp(0.0, 1.0).toDouble();
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'paid':
        color = Colors.green;
        label = 'Paid';
        break;
      case 'partiallyPaid':
        color = Colors.blue;
        label = 'Partial';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'overdue':
        color = Colors.red;
        label = 'Overdue';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 4.0),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAlert = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14.0),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isAlert ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getFullStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
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

  String _capitalizeMethod(String method) {
    return method
        .split('_')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'credit_card':
        return Icons.credit_card;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'cash':
        return Icons.money;
      case 'check':
        return Icons.receipt_long;
      default:
        return Icons.payment;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Invoice'),
            content: Text(
              'Are you sure you want to delete this invoice? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  // TODO: Implement delete functionality
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to invoices list
                },
              ),
            ],
          ),
    );
  }

  void _showSendConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Send Payment Reminder'),
            content: Text('Send a payment reminder to the customer?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Send'),
                onPressed: () {
                  // TODO: Implement send functionality
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment reminder sent')),
                  );
                },
              ),
            ],
          ),
    );
  }

  void _showRecordPaymentDialog(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder:
          (context) => AddPaymentDialog(
            invoice: invoice,
            outstandingAmount: invoice.remainingAmount,
          ),
    );
  }
}
