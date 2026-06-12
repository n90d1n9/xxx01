import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/payment.dart';
import '../states/customer_provider.dart';
import '../states/invoice_provider.dart';
import '../widgets/invoice_create.dart';
import '../widgets/invoice_detail_screen.dart';
import '../widgets/invoice_list_item.dart';
import '../widgets/payment_list_item.dart';

class _CustomerPayment {
  final Invoice invoice;
  final Payment payment;

  const _CustomerPayment({required this.invoice, required this.payment});
}

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider3);
    final invoices =
        ref
            .watch(invoicesProvider)
            .invoices
            .where((invoice) => invoice.customerId == customerId)
            .toList()
          ..sort((a, b) {
            final aDate =
                a.dueDate ??
                a.issueDate ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final bDate =
                b.dueDate ??
                b.issueDate ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          customersAsync.maybeWhen(
            data: (customers) {
              final customer = _findCustomer(customers);
              if (customer == null) {
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit customer',
                    onPressed:
                        () => _showEditCustomerDialog(context, ref, customer),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(
                          context,
                          ref,
                          customer,
                          invoices,
                        );
                      }
                    },
                    itemBuilder:
                        (context) => const [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Delete Customer',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshCustomer(ref),
        child: customersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (customers) {
            final customer = _findCustomer(customers);
            if (customer == null) {
              return _buildMissingCustomer(context);
            }

            final payments = _customerPayments(invoices);

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileCard(context, customer),
                const SizedBox(height: 16.0),
                _buildAccountSummary(context, invoices, formatter),
                const SizedBox(height: 16.0),
                _buildInvoicesSection(context, customer, invoices),
                if (payments.isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  _buildPaymentHistory(context, payments),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_chart),
        label: const Text('Invoice'),
        onPressed: () => _openCreateInvoice(context, customerId),
      ),
    );
  }

  Customer? _findCustomer(List<Customer> customers) {
    for (final customer in customers) {
      if (customer.id == customerId) {
        return customer;
      }
    }
    return null;
  }

  Future<void> _refreshCustomer(WidgetRef ref) async {
    ref.invalidate(customersProvider3);
    ref.invalidate(customersProvider);
    ref.invalidate(invoicesProvider);
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Widget _buildMissingCustomer(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.person_off_rounded,
                  size: 48,
                  color: Colors.grey[500],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Customer not found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'This customer may have been deleted.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, Customer customer) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    customer.name.isEmpty
                        ? '?'
                        : customer.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      _buildContactRow(Icons.email, customer.email),
                      const SizedBox(height: 4.0),
                      _buildContactRow(Icons.phone, customer.phone),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  icon: Icons.email,
                  label: 'Email',
                  onPressed:
                      () => _copyContact(context, 'Email', customer.email),
                ),
                _buildActionButton(
                  icon: Icons.phone,
                  label: 'Call',
                  onPressed:
                      () => _copyContact(context, 'Phone', customer.phone),
                ),
                _buildActionButton(
                  icon: Icons.message,
                  label: 'Message',
                  onPressed:
                      () => _copyContact(
                        context,
                        'Message number',
                        customer.phone,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6.0),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSummary(
    BuildContext context,
    List<Invoice> invoices,
    NumberFormat formatter,
  ) {
    final totalAmount = invoices.fold(
      0.0,
      (sum, invoice) => sum + invoice.amount,
    );
    final totalPaid = invoices.fold(
      0.0,
      (sum, invoice) => sum + invoice.paidAmount,
    );
    final totalDue = invoices.fold(
      0.0,
      (sum, invoice) => sum + invoice.remainingAmount,
    );
    final overdueAmount = invoices
        .where((invoice) => invoice.isOverdue)
        .fold(0.0, (sum, invoice) => sum + invoice.remainingAmount);
    final nextDueDate = _nextDueDate(invoices);
    final collectionRate = totalAmount == 0 ? 0 : totalPaid / totalAmount;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Summary',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth =
                    constraints.maxWidth >= 640
                        ? (constraints.maxWidth - 24) / 4
                        : (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSummaryTile(
                      'Invoiced',
                      formatter.format(totalAmount),
                      tileWidth,
                    ),
                    _buildSummaryTile(
                      'Paid',
                      formatter.format(totalPaid),
                      tileWidth,
                    ),
                    _buildSummaryTile(
                      'Due',
                      formatter.format(totalDue),
                      tileWidth,
                      isHighlighted: totalDue > 0,
                    ),
                    _buildSummaryTile(
                      'Collection',
                      '${(collectionRate * 100).toStringAsFixed(1)}%',
                      tileWidth,
                    ),
                  ],
                );
              },
            ),
            if (overdueAmount > 0 || nextDueDate != null) ...[
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: overdueAmount > 0 ? Colors.red[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      overdueAmount > 0 ? Icons.warning : Icons.event_available,
                      color: overdueAmount > 0 ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        overdueAmount > 0
                            ? 'Overdue amount: ${formatter.format(overdueAmount)}'
                            : 'Next due: ${DateFormat('MMM d, yyyy').format(nextDueDate!)}',
                        style: TextStyle(
                          color:
                              overdueAmount > 0 ? Colors.red : Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(
    String label,
    String value,
    double width, {
    bool isHighlighted = false,
  }) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13.0, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4.0),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? _nextDueDate(List<Invoice> invoices) {
    final dueDates =
        invoices
            .where(
              (invoice) =>
                  invoice.remainingAmount > 0 && invoice.dueDate != null,
            )
            .map((invoice) => invoice.dueDate!)
            .toList()
          ..sort();
    return dueDates.isEmpty ? null : dueDates.first;
  }

  Widget _buildInvoicesSection(
    BuildContext context,
    Customer customer,
    List<Invoice> invoices,
  ) {
    if (invoices.isEmpty) {
      return Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16.0),
                Text(
                  'No invoices yet',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create Invoice'),
                  onPressed: () => _openCreateInvoice(context, customer.id),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Invoices',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _openCreateInvoice(context, customer.id),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoices.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return InvoiceListItem(invoice: invoices[index]);
            },
          ),
        ),
      ],
    );
  }

  List<_CustomerPayment> _customerPayments(List<Invoice> invoices) {
    final payments = <_CustomerPayment>[];
    for (final invoice in invoices) {
      for (final payment in invoice.payments ?? const <Payment>[]) {
        if (payment.paymentDate != null) {
          payments.add(_CustomerPayment(invoice: invoice, payment: payment));
        }
      }
    }
    payments.sort(
      (a, b) => b.payment.paymentDate!.compareTo(a.payment.paymentDate!),
    );
    return payments;
  }

  Widget _buildPaymentHistory(
    BuildContext context,
    List<_CustomerPayment> payments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment History',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = payments[index];
              return PaymentListItem(
                payment: item.payment,
                invoiceNumber: _invoiceNumber(item.invoice),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              InvoiceDetailScreen(invoiceId: item.invoice.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _invoiceNumber(Invoice invoice) {
    return invoice.invoiceNumber ?? invoice.reference ?? invoice.id;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 4.0),
            Text(label, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Future<void> _copyContact(
    BuildContext context,
    String label,
    String value,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openCreateInvoice(BuildContext context, String customerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateInvoiceScreen(customerId: customerId),
      ),
    );
  }

  Future<void> _showEditCustomerDialog(
    BuildContext context,
    WidgetRef ref,
    Customer customer,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: customer.name);
    final emailController = TextEditingController(text: customer.email);
    final phoneController = TextEditingController(text: customer.phone);

    try {
      await showDialog<void>(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('Edit Customer'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      validator: _requiredValidator,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save'),
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    final updated = Customer(
                      id: customer.id,
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                    );
                    ref
                        .read(customersProvider3.notifier)
                        .updateCustomer(updated);
                    ref
                        .read(customersProvider.notifier)
                        .updateCustomer(updated);
                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            ),
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    }
  }

  String? _requiredValidator(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Customer customer,
    List<Invoice> invoices,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Customer'),
            content: Text(
              invoices.isEmpty
                  ? 'Delete ${customer.name}? This action cannot be undone.'
                  : '${customer.name} has ${invoices.length} invoices. Delete the customer profile and keep invoice records?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  ref
                      .read(customersProvider3.notifier)
                      .removeCustomer(customer.id);
                  ref
                      .read(customersProvider.notifier)
                      .removeCustomer(customer.id);
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }
}
