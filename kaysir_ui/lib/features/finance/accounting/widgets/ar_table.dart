import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../helper/ar_dash_data.dart';
import '../models/invoice.dart';
import '../states/ar_dash_provider.dart';
import 'add_payment_dialog.dart';

class ArInvoicesDataTable extends ConsumerWidget {
  final ARDashboardData arData;

  const ArInvoicesDataTable({required this.arData, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MM/dd/yyyy');
    final currencyFormat = NumberFormat('#,##0.00');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
          columns: const [
            DataColumn(label: Text('Invoice #')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Issue Date')),
            DataColumn(label: Text('Due Date')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Paid')),
            DataColumn(label: Text('Outstanding')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows:
              arData.invoices.map((invoice) {
                final customer = arData.getCustomerById(invoice.customerId!);
                final totalPaid = arData.getTotalPaidForInvoice(invoice.id);
                final outstanding = arData.getOutstandingAmountForInvoice(
                  invoice.id,
                );

                Color statusColor;
                switch (invoice.status) {
                  case InvoiceStatus.outstanding:
                    statusColor = Colors.orange;
                    break;
                  case InvoiceStatus.pending:
                    statusColor = Colors.blueGrey;
                    break;
                  case InvoiceStatus.partiallyPaid:
                    statusColor = Colors.blue;
                    break;
                  case InvoiceStatus.paid:
                    statusColor = Colors.green;
                    break;
                  case InvoiceStatus.overdue:
                    statusColor = Colors.red;
                    break;
                  case InvoiceStatus.disputed:
                    statusColor = Colors.deepPurple;
                    break;
                }

                return DataRow(
                  cells: [
                    DataCell(Text(_invoiceReference(invoice))),
                    DataCell(Text(customer?.name ?? 'Unknown')),
                    DataCell(
                      Text(dateFormat.format(_invoiceIssueDate(invoice))),
                    ),
                    DataCell(Text(dateFormat.format(invoice.dueDate!))),
                    DataCell(
                      Text('\$${currencyFormat.format(invoice.amount)}'),
                    ),
                    DataCell(Text('\$${currencyFormat.format(totalPaid)}')),
                    DataCell(Text('\$${currencyFormat.format(outstanding)}')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          invoice.status.toString().split('.').last,
                          style: TextStyle(color: statusColor),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.payment, size: 20),
                            tooltip: 'Record Payment',
                            onPressed: () {
                              _showAddPaymentDialog(context, ref, invoice);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 20),
                            tooltip: 'View Details',
                            onPressed: () {
                              _showInvoiceDetails(
                                context,
                                ref,
                                invoice,
                                arData,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  void _showAddPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    final outstanding = ref
        .read(arDashboardProvider)
        .getOutstandingAmountForInvoice(invoice.id);

    showDialog(
      context: context,
      builder: (context) {
        return AddPaymentDialog(
          invoice: invoice,
          outstandingAmount: outstanding,
        );
      },
    );
  }

  void _showInvoiceDetails(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
    ARDashboardData arData,
  ) {
    final customer = arData.getCustomerById(invoice.customerId!);
    final payments = arData.getPaymentsForInvoice(invoice.id);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invoice ${_invoiceReference(invoice)} Details'),
          content: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${customer?.name ?? "Unknown"}'),
                const SizedBox(height: 8),
                Text(
                  'Issue Date: ${DateFormat('MM/dd/yyyy').format(_invoiceIssueDate(invoice))}',
                ),
                Text(
                  'Due Date: ${DateFormat('MM/dd/yyyy').format(invoice.dueDate!)}',
                ),
                Text(
                  'Amount: \$${NumberFormat('#,##0.00').format(invoice.amount)}',
                ),
                Text('Status: ${invoice.status.toString().split('.').last}'),
                const SizedBox(height: 16),
                const Text(
                  'Payment History:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (payments.isEmpty)
                  const Text('No payments recorded.')
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        return ListTile(
                          title: Text(
                            'Payment: \$${NumberFormat('#,##0.00').format(payment.amount)}',
                          ),
                          subtitle: Text(
                            'Date: ${DateFormat('MM/dd/yyyy').format(payment.paymentDate!)}',
                          ),
                          trailing: Text('Ref: ${payment.reference}'),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _invoiceReference(Invoice invoice) {
    return invoice.reference ?? invoice.invoiceNumber ?? invoice.id;
  }

  DateTime _invoiceIssueDate(Invoice invoice) {
    return invoice.issueDate ?? invoice.invoiceDate ?? invoice.dueDate!;
  }
}
