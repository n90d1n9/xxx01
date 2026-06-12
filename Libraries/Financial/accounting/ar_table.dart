import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Models
class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });
}

class Invoice {
  final String id;
  final String customerId;
  final DateTime issueDate;
  final DateTime dueDate;
  final double amount;
  final String reference;
  final InvoiceStatus status;

  Invoice({
    required this.id,
    required this.customerId,
    required this.issueDate,
    required this.dueDate,
    required this.amount,
    required this.reference,
    this.status = InvoiceStatus.outstanding,
  });

  Invoice copyWith({
    String? id,
    String? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    double? amount,
    String? reference,
    InvoiceStatus? status,
  }) {
    return Invoice(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      reference: reference ?? this.reference,
      status: status ?? this.status,
    );
  }
}

class Payment {
  final String id;
  final String invoiceId;
  final DateTime paymentDate;
  final double amount;
  final String reference;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.paymentDate,
    required this.amount,
    required this.reference,
  });
}

enum InvoiceStatus { outstanding, partiallyPaid, paid, overdue }

// Providers
final customersProvider =
    StateNotifierProvider<CustomersNotifier, List<Customer>>((ref) {
      return CustomersNotifier();
    });

final invoicesProvider = StateNotifierProvider<InvoicesNotifier, List<Invoice>>(
  (ref) {
    return InvoicesNotifier();
  },
);

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, List<Payment>>(
  (ref) {
    return PaymentsNotifier();
  },
);

// Combined data provider for AR dashboard
final arDashboardProvider = Provider<ARDashboardData>((ref) {
  final customers = ref.watch(customersProvider);
  final invoices = ref.watch(invoicesProvider);
  final payments = ref.watch(paymentsProvider);

  return ARDashboardData(
    customers: customers,
    invoices: invoices,
    payments: payments,
  );
});

class ARDashboardData {
  final List<Customer> customers;
  final List<Invoice> invoices;
  final List<Payment> payments;

  ARDashboardData({
    required this.customers,
    required this.invoices,
    required this.payments,
  });

  // Helper method to get customer by ID
  Customer? getCustomerById(String id) {
    try {
      return customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get payments for an invoice
  List<Payment> getPaymentsForInvoice(String invoiceId) {
    return payments.where((payment) => payment.invoiceId == invoiceId).toList();
  }

  // Helper method to calculate total paid amount for an invoice
  double getTotalPaidForInvoice(String invoiceId) {
    return getPaymentsForInvoice(
      invoiceId,
    ).fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // Helper method to calculate outstanding amount for an invoice
  double getOutstandingAmountForInvoice(String invoiceId) {
    final invoice = invoices.firstWhere((inv) => inv.id == invoiceId);
    final totalPaid = getTotalPaidForInvoice(invoiceId);
    return invoice.amount - totalPaid;
  }

  // Calculate total outstanding AR
  double get totalOutstandingAR {
    return invoices.fold(0.0, (sum, invoice) {
      return sum + getOutstandingAmountForInvoice(invoice.id);
    });
  }

  // Get invoices grouped by status
  Map<InvoiceStatus, List<Invoice>> get invoicesByStatus {
    Map<InvoiceStatus, List<Invoice>> result = {};
    for (var status in InvoiceStatus.values) {
      result[status] = invoices
          .where((invoice) => invoice.status == status)
          .toList();
    }
    return result;
  }

  // Get overdue invoices
  List<Invoice> get overdueInvoices {
    final now = DateTime.now();
    return invoices
        .where(
          (invoice) =>
              invoice.status != InvoiceStatus.paid &&
              invoice.dueDate.isBefore(now),
        )
        .toList();
  }
}

// Notifiers
class CustomersNotifier extends StateNotifier<List<Customer>> {
  CustomersNotifier()
    : super([
        Customer(
          id: '1',
          name: 'Acme Corp',
          email: 'billing@acme.com',
          phone: '123-456-7890',
        ),
        Customer(
          id: '2',
          name: 'TechStart Inc',
          email: 'accounts@techstart.com',
          phone: '987-654-3210',
        ),
        Customer(
          id: '3',
          name: 'Global Services Ltd',
          email: 'finance@globalservices.com',
          phone: '555-555-5555',
        ),
      ]);

  void addCustomer(Customer customer) {
    state = [...state, customer];
  }

  void updateCustomer(Customer updatedCustomer) {
    state = state.map((customer) {
      if (customer.id == updatedCustomer.id) {
        return updatedCustomer;
      }
      return customer;
    }).toList();
  }

  void removeCustomer(String id) {
    state = state.where((customer) => customer.id != id).toList();
  }
}

class InvoicesNotifier extends StateNotifier<List<Invoice>> {
  InvoicesNotifier()
    : super([
        Invoice(
          id: '1',
          customerId: '1',
          issueDate: DateTime.now().subtract(const Duration(days: 30)),
          dueDate: DateTime.now().subtract(const Duration(days: 15)),
          amount: 2500.00,
          reference: 'INV-2025-001',
          status: InvoiceStatus.overdue,
        ),
        Invoice(
          id: '2',
          customerId: '2',
          issueDate: DateTime.now().subtract(const Duration(days: 15)),
          dueDate: DateTime.now().add(const Duration(days: 15)),
          amount: 1800.00,
          reference: 'INV-2025-002',
          status: InvoiceStatus.partiallyPaid,
        ),
        Invoice(
          id: '3',
          customerId: '3',
          issueDate: DateTime.now().subtract(const Duration(days: 5)),
          dueDate: DateTime.now().add(const Duration(days: 25)),
          amount: 3200.00,
          reference: 'INV-2025-003',
          status: InvoiceStatus.outstanding,
        ),
        Invoice(
          id: '4',
          customerId: '1',
          issueDate: DateTime.now().subtract(const Duration(days: 60)),
          dueDate: DateTime.now().subtract(const Duration(days: 30)),
          amount: 1200.00,
          reference: 'INV-2025-004',
          status: InvoiceStatus.paid,
        ),
      ]);

  void addInvoice(Invoice invoice) {
    state = [...state, invoice];
  }

  void updateInvoice(Invoice updatedInvoice) {
    state = state.map((invoice) {
      if (invoice.id == updatedInvoice.id) {
        return updatedInvoice;
      }
      return invoice;
    }).toList();
  }

  void updateInvoiceStatus(String id, InvoiceStatus status) {
    state = state.map((invoice) {
      if (invoice.id == id) {
        return invoice.copyWith(status: status);
      }
      return invoice;
    }).toList();
  }

  void removeInvoice(String id) {
    state = state.where((invoice) => invoice.id != id).toList();
  }
}

class PaymentsNotifier extends StateNotifier<List<Payment>> {
  PaymentsNotifier()
    : super([
        Payment(
          id: '1',
          invoiceId: '2',
          paymentDate: DateTime.now().subtract(const Duration(days: 5)),
          amount: 1000.00,
          reference: 'PAY-2025-001',
        ),
        Payment(
          id: '2',
          invoiceId: '4',
          paymentDate: DateTime.now().subtract(const Duration(days: 35)),
          amount: 1200.00,
          reference: 'PAY-2025-002',
        ),
      ]);

  void addPayment(Payment payment) {
    state = [...state, payment];
  }

  void updatePayment(Payment updatedPayment) {
    state = state.map((payment) {
      if (payment.id == updatedPayment.id) {
        return updatedPayment;
      }
      return payment;
    }).toList();
  }

  void removePayment(String id) {
    state = state.where((payment) => payment.id != id).toList();
  }
}

// UI
void main() {
  runApp(const ProviderScope(child: AccountsReceivableApp()));
}

class AccountsReceivableApp extends StatelessWidget {
  const AccountsReceivableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accounts Receivable',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ARDashboardScreen(),
    );
  }
}

class ARDashboardScreen extends ConsumerWidget {
  const ARDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arData = ref.watch(arDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts Receivable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddInvoiceDialog(context, ref);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Outstanding',
                    '\$${NumberFormat('#,##0.00').format(arData.totalOutstandingAR)}',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Overdue',
                    '${arData.overdueInvoices.length} invoices',
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Customers',
                    '${arData.customers.length}',
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Invoices Table
            const Text(
              'Invoices',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ArInvoicesDataTable(arData: arData),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInvoiceDialog(BuildContext context, WidgetRef ref) {
    final customers = ref.read(customersProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AddInvoiceDialog(customers: customers);
      },
    );
  }
}

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
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
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
          rows: arData.invoices.map((invoice) {
            final customer = arData.getCustomerById(invoice.customerId);
            final totalPaid = arData.getTotalPaidForInvoice(invoice.id);
            final outstanding = invoice.amount - totalPaid;

            Color statusColor;
            switch (invoice.status) {
              case InvoiceStatus.outstanding:
                statusColor = Colors.orange;
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
            }

            return DataRow(
              cells: [
                DataCell(Text(invoice.reference)),
                DataCell(Text(customer?.name ?? 'Unknown')),
                DataCell(Text(dateFormat.format(invoice.issueDate))),
                DataCell(Text(dateFormat.format(invoice.dueDate))),
                DataCell(Text('\$${currencyFormat.format(invoice.amount)}')),
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
                          _showInvoiceDetails(context, ref, invoice, arData);
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
    final totalPaid = ref
        .read(arDashboardProvider)
        .getTotalPaidForInvoice(invoice.id);
    final outstanding = invoice.amount - totalPaid;

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
    final customer = arData.getCustomerById(invoice.customerId);
    final payments = arData.getPaymentsForInvoice(invoice.id);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invoice ${invoice.reference} Details'),
          content: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${customer?.name ?? "Unknown"}'),
                const SizedBox(height: 8),
                Text(
                  'Issue Date: ${DateFormat('MM/dd/yyyy').format(invoice.issueDate)}',
                ),
                Text(
                  'Due Date: ${DateFormat('MM/dd/yyyy').format(invoice.dueDate)}',
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
                            'Date: ${DateFormat('MM/dd/yyyy').format(payment.paymentDate)}',
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
}

class AddInvoiceDialog extends ConsumerStatefulWidget {
  final List<Customer> customers;

  const AddInvoiceDialog({required this.customers, super.key});

  @override
  ConsumerState<AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends ConsumerState<AddInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCustomerId;
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Invoice'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Customer'),
                value: selectedCustomerId,
                items: widget.customers.map((customer) {
                  return DropdownMenuItem<String>(
                    value: customer.id,
                    child: Text(customer.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCustomerId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a customer';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Invoice Reference',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an invoice reference';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Issue Date'),
                      subtitle: Text(
                        DateFormat('MM/dd/yyyy').format(_issueDate),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _issueDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            _issueDate = date;
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Due Date'),
                      subtitle: Text(DateFormat('MM/dd/yyyy').format(_dueDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            _dueDate = date;
                          });
                        }
                      },
                    ),
                  ),
                ],
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
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate() &&
                selectedCustomerId != null) {
              final invoiceNotifier = ref.read(invoicesProvider.notifier);

              final newInvoice = Invoice(
                id: const Uuid().v4(),
                customerId: selectedCustomerId!,
                issueDate: _issueDate,
                dueDate: _dueDate,
                amount: double.parse(_amountController.text),
                reference: _referenceController.text,
                status: InvoiceStatus.outstanding,
              );

              invoiceNotifier.addInvoice(newInvoice);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class AddPaymentDialog extends ConsumerStatefulWidget {
  final Invoice invoice;
  final double outstandingAmount;

  const AddPaymentDialog({
    required this.invoice,
    required this.outstandingAmount,
    super.key,
  });

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Default to the full outstanding amount
    _amountController.text = widget.outstandingAmount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Record Payment for ${widget.invoice.reference}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Outstanding Amount: \$${NumberFormat('#,##0.00').format(widget.outstandingAmount)}',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a payment amount';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Please enter a valid number';
                }
                if (amount <= 0) {
                  return 'Amount must be greater than zero';
                }
                if (amount > widget.outstandingAmount) {
                  return 'Amount cannot exceed outstanding balance';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Payment Reference',
                hintText: 'e.g., Check #, Transaction ID',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a payment reference';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Payment Date'),
              subtitle: Text(DateFormat('MM/dd/yyyy').format(_paymentDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _paymentDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    _paymentDate = date;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Add payment
              final paymentAmount = double.parse(_amountController.text);
              final paymentsNotifier = ref.read(paymentsProvider.notifier);
              final invoicesNotifier = ref.read(invoicesProvider.notifier);

              // Create new payment
              final payment = Payment(
                id: const Uuid().v4(),
                invoiceId: widget.invoice.id,
                paymentDate: _paymentDate,
                amount: paymentAmount,
                reference: _referenceController.text,
              );

              paymentsNotifier.addPayment(payment);

              // Update invoice status
              InvoiceStatus newStatus;
              if (paymentAmount >= widget.outstandingAmount) {
                newStatus = InvoiceStatus.paid;
              } else if (widget.outstandingAmount - paymentAmount <
                  widget.invoice.amount) {
                newStatus = InvoiceStatus.partiallyPaid;
              } else {
                newStatus = widget.invoice.status;
              }

              invoicesNotifier.updateInvoiceStatus(
                widget.invoice.id,
                newStatus,
              );

              Navigator.of(context).pop();
            }
          },
          child: const Text('Record Payment'),
        ),
      ],
    );
  }
}
