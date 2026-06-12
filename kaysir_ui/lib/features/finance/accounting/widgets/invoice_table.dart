import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/invoice.dart';
import '../models/vendor.dart';
import '../states/invoice_provider.dart';
import '../states/vendor_provider.dart';
import 'payable_payment_dialog.dart';

class InvoicesTable extends ConsumerWidget {
  const InvoicesTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredInvoices = ref.watch(payableInvoicesProvider);
    final vendors = ref.watch(vendorsProvider);
    final dateFormat = DateFormat('MM/dd/yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),

        Expanded(
          child:
              filteredInvoices.isEmpty
                  ? const AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No bills found',
                    message:
                        'Adjust filters or create a vendor bill to start payables.',
                  )
                  : ListView.builder(
                    itemCount: filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = filteredInvoices[index];
                      final vendor = vendors.firstWhere(
                        (v) => v.id == invoice.vendorId,
                        orElse:
                            () => Vendor(
                              id: '',
                              name: 'Unknown',
                              email: '',
                              phone: '',
                            ),
                      );

                      return _buildInvoiceRow(
                        context,
                        ref,
                        invoice,
                        vendor,
                        dateFormat,
                        currencyFormat,
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w800,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: DefaultTextStyle.merge(
          style: headerStyle,
          child: const Row(
            children: [
              Expanded(flex: 2, child: Text('Vendor')),
              Expanded(flex: 2, child: Text('Invoice #')),
              Expanded(flex: 1, child: Text('Date')),
              Expanded(flex: 1, child: Text('Due Date')),
              Expanded(
                flex: 1,
                child: Text('Amount', textAlign: TextAlign.right),
              ),
              Expanded(
                flex: 1,
                child: Text('Status', textAlign: TextAlign.center),
              ),
              Expanded(
                flex: 2,
                child: Text('Actions', textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
    Vendor vendor,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPastDue =
        invoice.dueDate!.isBefore(DateTime.now()) &&
        invoice.status != InvoiceStatus.paid;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(vendor.name, overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: Text(
                invoice.invoiceNumber!,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(dateFormat.format(invoice.invoiceDate!)),
            ),
            Expanded(
              flex: 1,
              child: Text(
                dateFormat.format(invoice.dueDate!),
                style: TextStyle(
                  color: isPastDue ? colorScheme.error : null,
                  fontWeight: isPastDue ? FontWeight.w700 : null,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                currencyFormat.format(invoice.amount),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(child: _buildStatusPill(invoice.status)),
            ),
            Expanded(flex: 2, child: _buildActions(context, ref, invoice)),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, Invoice invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIconActionButton(
          icon: Icons.edit_outlined,
          tooltip: 'Edit bill',
          size: 34,
          iconSize: 18,
          variant: AppIconActionButtonVariant.outlined,
          onPressed: () => _showEditInvoiceDialog(context, ref, invoice),
        ),
        const SizedBox(width: 8),
        AppIconActionButton(
          icon: Icons.payments_outlined,
          tooltip: 'Post bill payment',
          size: 34,
          iconSize: 18,
          variant: AppIconActionButtonVariant.tonal,
          onPressed:
              invoice.remainingAmount <= 0
                  ? null
                  : () => _showPayablePaymentDialog(context, invoice),
        ),
        const SizedBox(width: 8),
        AppIconActionButton(
          icon: Icons.delete_outline,
          tooltip: 'Delete bill',
          size: 34,
          iconSize: 18,
          variant: AppIconActionButtonVariant.outlined,
          onPressed: () => _showDeleteInvoiceDialog(context, ref, invoice),
        ),
      ],
    );
  }

  Widget _buildStatusPill(InvoiceStatus status) {
    final style = _styleForStatus(status);

    return AppStatusPill(
      label: style.label,
      color: style.color,
      icon: style.icon,
      maxWidth: 120,
    );
  }

  _InvoiceStatusStyle _styleForStatus(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.pending:
        return const _InvoiceStatusStyle(
          label: 'Pending',
          color: Colors.blue,
          icon: Icons.schedule_outlined,
        );
      case InvoiceStatus.partiallyPaid:
        return _InvoiceStatusStyle(
          label: 'Partial',
          color: Colors.amber.shade700,
          icon: Icons.timelapse_outlined,
        );
      case InvoiceStatus.paid:
        return const _InvoiceStatusStyle(
          label: 'Paid',
          color: Colors.green,
          icon: Icons.done_rounded,
        );
      case InvoiceStatus.overdue:
        return const _InvoiceStatusStyle(
          label: 'Overdue',
          color: Colors.red,
          icon: Icons.warning_amber_rounded,
        );
      case InvoiceStatus.disputed:
        return const _InvoiceStatusStyle(
          label: 'Disputed',
          color: Colors.deepPurple,
          icon: Icons.report_problem_outlined,
        );
      case InvoiceStatus.outstanding:
        return const _InvoiceStatusStyle(
          label: 'Outstanding',
          color: Colors.orange,
          icon: Icons.pending_actions_outlined,
        );
    }
  }

  void _showDeleteInvoiceDialog(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Invoice'),
          content: Text(
            'Are you sure you want to delete invoice ${invoice.invoiceNumber}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(invoicesProvider.notifier).removeInvoice(invoice.id);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _statusLabel(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.disputed:
        return 'Disputed';
      case InvoiceStatus.outstanding:
        return 'Outstanding';
    }
  }

  void _showEditInvoiceDialog(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    final formKey = GlobalKey<FormState>();
    final vendors = ref.read(vendorsProvider);

    String vendorId = invoice.vendorId!;
    String invoiceNumber = invoice.invoiceNumber!;
    DateTime invoiceDate = invoice.invoiceDate!;
    DateTime dueDate = invoice.dueDate!;
    double amount = invoice.amount;
    String description = invoice.description;
    InvoiceStatus status = invoice.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Invoice ${invoice.invoiceNumber}'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Vendor dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Vendor',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: vendorId,
                    items:
                        vendors.map((vendor) {
                          return DropdownMenuItem<String>(
                            value: vendor.id,
                            child: Text(vendor.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        vendorId = value;
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a vendor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Invoice number
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Invoice Number',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: invoiceNumber,
                    onChanged: (value) {
                      invoiceNumber = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an invoice number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Invoice date picker
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Invoice Date',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: DateFormat('yyyy-MM-dd').format(invoiceDate),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: invoiceDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        invoiceDate = date;
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Due date picker
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: DateFormat('yyyy-MM-dd').format(dueDate),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dueDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        dueDate = date;
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    initialValue: amount.toString(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      amount = double.tryParse(value) ?? amount;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: description,
                    maxLines: 3,
                    onChanged: (value) {
                      description = value;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status dropdown
                  DropdownButtonFormField<InvoiceStatus>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: status,
                    items:
                        InvoiceStatus.values.map((s) {
                          return DropdownMenuItem<InvoiceStatus>(
                            value: s,
                            child: Text(_formatInvoiceStatus(s)),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        status = value;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Update the invoice
                  final updatedInvoice = Invoice(
                    id: invoice.id,
                    vendorId: vendorId,
                    customerId: invoice.customerId,
                    invoiceNumber: invoiceNumber,
                    invoiceDate: invoiceDate,
                    dueDate: dueDate,
                    amount: amount,
                    description: description,
                    issueDate: invoice.issueDate,
                    reference: invoice.reference,
                    status: status,
                    vendorName: invoice.vendorName,
                    isPaid: status == InvoiceStatus.paid,
                    payments: invoice.payments,
                    expenseAccountId: invoice.expenseAccountId,
                  );

                  ref
                      .read(invoicesProvider.notifier)
                      .updateInvoice(updatedInvoice);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _showPayablePaymentDialog(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => PayablePaymentDialog(bill: invoice),
    );
  }

  String _formatInvoiceStatus(InvoiceStatus status) {
    return _statusLabel(status);
  }
}

class _InvoiceStatusStyle {
  const _InvoiceStatusStyle({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}
