// MAIN.DART
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ProviderScope(child: AccountsPayableApp()));
}

/* class AccountsPayableApp extends StatelessWidget {
  const AccountsPayableApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accounts Payable',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AppNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
} */

class AccountsPayableApp extends StatelessWidget {
  const AccountsPayableApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accounts Payable',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AccountsPayableDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// MODELS
class Vendor {
  final String id;
  final String name;
  final String email;
  final String phone;

  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });
}

class Invoice {
  final String id;
  final String vendorId;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final double amount;
  final String description;
  final InvoiceStatus status;

  Invoice({
    required this.id,
    required this.vendorId,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.amount,
    required this.description,
    required this.status,
  });

  Invoice copyWith({
    String? id,
    String? vendorId,
    String? invoiceNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    double? amount,
    String? description,
    InvoiceStatus? status,
  }) {
    return Invoice(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}

enum InvoiceStatus { pending, partiallyPaid, paid, overdue, disputed }

// PROVIDERS
final vendorsProvider = StateNotifierProvider<VendorsNotifier, List<Vendor>>((
  ref,
) {
  return VendorsNotifier();
});

class VendorsNotifier extends StateNotifier<List<Vendor>> {
  VendorsNotifier()
    : super([
        Vendor(
          id: '1',
          name: 'ABC Supplies',
          email: 'accounts@abcsupplies.com',
          phone: '+1-555-123-4567',
        ),
        Vendor(
          id: '2',
          name: 'XYZ Services',
          email: 'billing@xyzservices.com',
          phone: '+1-555-987-6543',
        ),
        Vendor(
          id: '3',
          name: 'Metro Office Furniture',
          email: 'ar@metrofurniture.com',
          phone: '+1-555-456-7890',
        ),
        Vendor(
          id: '4',
          name: 'Tech Innovations Ltd',
          email: 'payments@techinnovations.com',
          phone: '+1-555-222-3333',
        ),
        Vendor(
          id: '5',
          name: 'Global Logistics Inc',
          email: 'invoices@globallogistics.com',
          phone: '+1-555-789-0123',
        ),
      ]);

  void addVendor(Vendor vendor) {
    state = [...state, vendor];
  }

  void updateVendor(Vendor updatedVendor) {
    state = [
      for (final vendor in state)
        if (vendor.id == updatedVendor.id) updatedVendor else vendor,
    ];
  }

  void removeVendor(String id) {
    state = state.where((vendor) => vendor.id != id).toList();
  }
}

final invoicesProvider = StateNotifierProvider<InvoicesNotifier, List<Invoice>>(
  (ref) {
    return InvoicesNotifier();
  },
);

class InvoicesNotifier extends StateNotifier<List<Invoice>> {
  InvoicesNotifier()
    : super([
        Invoice(
          id: '1',
          vendorId: '1',
          invoiceNumber: 'INV-2025-001',
          invoiceDate: DateTime.now().subtract(const Duration(days: 20)),
          dueDate: DateTime.now().add(const Duration(days: 10)),
          amount: 2500.00,
          description: 'Office supplies',
          status: InvoiceStatus.pending,
        ),
        Invoice(
          id: '2',
          vendorId: '2',
          invoiceNumber: 'INV-2025-002',
          invoiceDate: DateTime.now().subtract(const Duration(days: 45)),
          dueDate: DateTime.now().subtract(const Duration(days: 15)),
          amount: 4750.00,
          description: 'Consulting services',
          status: InvoiceStatus.overdue,
        ),
        Invoice(
          id: '3',
          vendorId: '3',
          invoiceNumber: 'INV-2025-003',
          invoiceDate: DateTime.now().subtract(const Duration(days: 10)),
          dueDate: DateTime.now().add(const Duration(days: 20)),
          amount: 1850.00,
          description: 'Office furniture',
          status: InvoiceStatus.partiallyPaid,
        ),
        Invoice(
          id: '4',
          vendorId: '4',
          invoiceNumber: 'INV-2025-004',
          invoiceDate: DateTime.now().subtract(const Duration(days: 60)),
          dueDate: DateTime.now().subtract(const Duration(days: 30)),
          amount: 3200.00,
          description: 'Software licenses',
          status: InvoiceStatus.paid,
        ),
        Invoice(
          id: '5',
          vendorId: '5',
          invoiceNumber: 'INV-2025-005',
          invoiceDate: DateTime.now().subtract(const Duration(days: 15)),
          dueDate: DateTime.now().add(const Duration(days: 15)),
          amount: 5750.00,
          description: 'Shipping services',
          status: InvoiceStatus.disputed,
        ),
      ]);

  void addInvoice(Invoice invoice) {
    state = [...state, invoice];
  }

  void updateInvoice(Invoice updatedInvoice) {
    state = [
      for (final invoice in state)
        if (invoice.id == updatedInvoice.id) updatedInvoice else invoice,
    ];
  }

  void updateInvoiceStatus(String id, InvoiceStatus status) {
    state = [
      for (final invoice in state)
        if (invoice.id == id) invoice.copyWith(status: status) else invoice,
    ];
  }

  void removeInvoice(String id) {
    state = state.where((invoice) => invoice.id != id).toList();
  }
}

// Filter provider for invoices
final invoiceFilterProvider = StateProvider<InvoiceFilter>((ref) {
  return InvoiceFilter();
});

class InvoiceFilter {
  final InvoiceStatus? status;
  final String? vendorId;
  final bool showOverdueOnly;

  InvoiceFilter({this.status, this.vendorId, this.showOverdueOnly = false});

  InvoiceFilter copyWith({
    InvoiceStatus? status,
    String? vendorId,
    bool? showOverdueOnly,
  }) {
    return InvoiceFilter(
      status: status ?? this.status,
      vendorId: vendorId ?? this.vendorId,
      showOverdueOnly: showOverdueOnly ?? this.showOverdueOnly,
    );
  }
}

// Filtered invoices provider
final filteredInvoicesProvider = Provider<List<Invoice>>((ref) {
  final invoices = ref.watch(invoicesProvider);
  final filter = ref.watch(invoiceFilterProvider);

  return invoices.where((invoice) {
    if (filter.status != null && invoice.status != filter.status) {
      return false;
    }
    if (filter.vendorId != null && invoice.vendorId != filter.vendorId) {
      return false;
    }
    if (filter.showOverdueOnly && invoice.status != InvoiceStatus.overdue) {
      return false;
    }
    return true;
  }).toList();
});

// Summary providers
final totalOutstandingProvider = Provider<double>((ref) {
  final invoices = ref.watch(invoicesProvider);
  return invoices
      .where((invoice) => invoice.status != InvoiceStatus.paid)
      .fold(0, (sum, invoice) => sum + invoice.amount);
});

final overdueInvoicesCountProvider = Provider<int>((ref) {
  final invoices = ref.watch(invoicesProvider);
  return invoices
      .where((invoice) => invoice.status == InvoiceStatus.overdue)
      .length;
});

final upcomingDueInvoicesProvider = Provider<List<Invoice>>((ref) {
  final invoices = ref.watch(invoicesProvider);
  final now = DateTime.now();
  final nextWeek = now.add(const Duration(days: 7));

  return invoices.where((invoice) {
    return invoice.status != InvoiceStatus.paid &&
        invoice.dueDate.isAfter(now) &&
        invoice.dueDate.isBefore(nextWeek);
  }).toList();
});

// UI COMPONENTS
class AccountsPayableDashboard extends ConsumerWidget {
  const AccountsPayableDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalOutstanding = ref.watch(totalOutstandingProvider);
    final overdueCount = ref.watch(overdueInvoicesCountProvider);
    final upcomingDue = ref.watch(upcomingDueInvoicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts Payable Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Outstanding',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${NumberFormat('#,##0.00').format(totalOutstanding)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overdue Invoices',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            overdueCount.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: overdueCount > 0
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Due Within 7 Days',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            upcomingDue.length.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Filter controls
            _buildFilterSection(ref),

            const SizedBox(height: 16),

            // Invoices table
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InvoicesTable(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add new invoice
          _showAddInvoiceDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection(WidgetRef ref) {
    final filter = ref.watch(invoiceFilterProvider);
    final vendors = ref.watch(vendorsProvider);

    return Row(
      children: [
        // Status filter
        Expanded(
          child: DropdownButtonFormField<InvoiceStatus?>(
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            value: filter.status,
            items: [
              const DropdownMenuItem<InvoiceStatus?>(
                value: null,
                child: Text('All Statuses'),
              ),
              ...InvoiceStatus.values.map((status) {
                return DropdownMenuItem<InvoiceStatus?>(
                  value: status,
                  child: Text(_formatStatus(status)),
                );
              }).toList(),
            ],
            onChanged: (value) {
              ref.read(invoiceFilterProvider.notifier).state = filter.copyWith(
                status: value,
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // Vendor filter
        Expanded(
          child: DropdownButtonFormField<String?>(
            decoration: const InputDecoration(
              labelText: 'Vendor',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            value: filter.vendorId,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Vendors'),
              ),
              ...vendors.map((vendor) {
                return DropdownMenuItem<String?>(
                  value: vendor.id,
                  child: Text(vendor.name),
                );
              }).toList(),
            ],
            onChanged: (value) {
              ref.read(invoiceFilterProvider.notifier).state = filter.copyWith(
                vendorId: value,
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // Overdue filter
        Expanded(
          child: CheckboxListTile(
            title: const Text('Show Overdue Only'),
            value: filter.showOverdueOnly,
            onChanged: (value) {
              if (value != null) {
                ref.read(invoiceFilterProvider.notifier).state = filter
                    .copyWith(showOverdueOnly: value);
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            dense: true,
          ),
        ),

        const SizedBox(width: 16),

        // Reset filters button
        ElevatedButton.icon(
          onPressed: () {
            ref.read(invoiceFilterProvider.notifier).state = InvoiceFilter();
          },
          icon: const Icon(Icons.clear),
          label: const Text('Reset Filters'),
        ),
      ],
    );
  }

  void _showAddInvoiceDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final vendors = ref.read(vendorsProvider);

    String? selectedVendorId = vendors.isNotEmpty ? vendors.first.id : null;
    String invoiceNumber = '';
    DateTime invoiceDate = DateTime.now();
    DateTime dueDate = DateTime.now().add(const Duration(days: 30));
    double amount = 0.0;
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Invoice'),
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
                    value: selectedVendorId,
                    items: vendors.map((vendor) {
                      return DropdownMenuItem<String>(
                        value: vendor.id,
                        child: Text(vendor.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedVendorId = value;
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

                  // Invoice date picker (simplified for this example)
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

                  // Due date picker (simplified for this example)
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      amount = double.tryParse(value) ?? 0.0;
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
                    maxLines: 3,
                    onChanged: (value) {
                      description = value;
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
                if (formKey.currentState!.validate() &&
                    selectedVendorId != null) {
                  // Add the invoice
                  final newInvoice = Invoice(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    vendorId: selectedVendorId!,
                    invoiceNumber: invoiceNumber,
                    invoiceDate: invoiceDate,
                    dueDate: dueDate,
                    amount: amount,
                    description: description,
                    status: InvoiceStatus.pending,
                  );

                  ref.read(invoicesProvider.notifier).addInvoice(newInvoice);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Invoice'),
            ),
          ],
        );
      },
    );
  }

  String _formatStatus(InvoiceStatus status) {
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
    }
  }
}

class InvoicesTable extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredInvoices = ref.watch(filteredInvoicesProvider);
    final vendors = ref.watch(vendorsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'Vendor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'Invoice #',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Text(
                  'Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Text(
                  'Due Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Text(
                  'Amount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              const Expanded(
                flex: 1,
                child: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        // Table body
        Expanded(
          child: filteredInvoices.isEmpty
              ? const Center(child: Text('No invoices found.'))
              : ListView.builder(
                  itemCount: filteredInvoices.length,
                  itemBuilder: (context, index) {
                    final invoice = filteredInvoices[index];
                    final vendor = vendors.firstWhere(
                      (v) => v.id == invoice.vendorId,
                      orElse: () =>
                          Vendor(id: '', name: 'Unknown', email: '', phone: ''),
                    );

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(vendor.name)),
                          Expanded(flex: 2, child: Text(invoice.invoiceNumber)),
                          Expanded(
                            flex: 1,
                            child: Text(
                              DateFormat(
                                'MM/dd/yyyy',
                              ).format(invoice.invoiceDate),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              DateFormat('MM/dd/yyyy').format(invoice.dueDate),
                              style: TextStyle(
                                color:
                                    invoice.dueDate.isBefore(DateTime.now()) &&
                                        invoice.status != InvoiceStatus.paid
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '\$${NumberFormat('#,##0.00').format(invoice.amount)}',
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: _buildStatusChip(invoice.status),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  tooltip: 'Edit',
                                  onPressed: () {
                                    // Show edit dialog
                                    _showEditInvoiceDialog(
                                      context,
                                      ref,
                                      invoice,
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.payment,
                                    size: 20,
                                    color: invoice.status == InvoiceStatus.paid
                                        ? Colors.grey
                                        : Colors.green,
                                  ),
                                  tooltip: 'Mark as Paid',
                                  onPressed:
                                      invoice.status == InvoiceStatus.paid
                                      ? null
                                      : () {
                                          ref
                                              .read(invoicesProvider.notifier)
                                              .updateInvoiceStatus(
                                                invoice.id,
                                                InvoiceStatus.paid,
                                              );
                                        },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    // Show confirmation dialog
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
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      invoicesProvider.notifier,
                                                    )
                                                    .removeInvoice(invoice.id);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Delete'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(InvoiceStatus status) {
    Color chipColor;
    String label;

    switch (status) {
      case InvoiceStatus.pending:
        chipColor = Colors.blue;
        label = 'Pending';
        break;
      case InvoiceStatus.partiallyPaid:
        chipColor = Colors.amber;
        label = 'Partial';
        break;
      case InvoiceStatus.paid:
        chipColor = Colors.green;
        label = 'Paid';
        break;
      case InvoiceStatus.overdue:
        chipColor = Colors.red;
        label = 'Overdue';
        break;
      case InvoiceStatus.disputed:
        chipColor = Colors.deepPurple;
        label = 'Disputed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        border: Border.all(color: chipColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(color: chipColor, fontSize: 12)),
    );
  }

  void _showEditInvoiceDialog(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) {
    final formKey = GlobalKey<FormState>();
    final vendors = ref.read(vendorsProvider);

    String vendorId = invoice.vendorId;
    String invoiceNumber = invoice.invoiceNumber;
    DateTime invoiceDate = invoice.invoiceDate;
    DateTime dueDate = invoice.dueDate;
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
                    value: vendorId,
                    items: vendors.map((vendor) {
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
                    value: status,
                    items: InvoiceStatus.values.map((s) {
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
                    invoiceNumber: invoiceNumber,
                    invoiceDate: invoiceDate,
                    dueDate: dueDate,
                    amount: amount,
                    description: description,
                    status: status,
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

  String _formatInvoiceStatus(InvoiceStatus status) {
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
    }
  }
}

// Let's add a Vendor Management screen
class VendorManagementScreen extends ConsumerWidget {
  const VendorManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendors = ref.watch(vendorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            const Text(
              'Manage Vendors',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Vendors list
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: vendors.length,
                    itemBuilder: (context, index) {
                      final vendor = vendors[index];
                      return ListTile(
                        title: Text(
                          vendor.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${vendor.email}'),
                            Text('Phone: ${vendor.phone}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditVendorDialog(context, ref, vendor);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteVendorDialog(context, ref, vendor);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddVendorDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddVendorDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String phone = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Vendor'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Vendor Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a vendor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    phone = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
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
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newVendor = Vendor(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    email: email,
                    phone: phone,
                  );

                  ref.read(vendorsProvider.notifier).addVendor(newVendor);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Vendor'),
            ),
          ],
        );
      },
    );
  }

  void _showEditVendorDialog(
    BuildContext context,
    WidgetRef ref,
    Vendor vendor,
  ) {
    final formKey = GlobalKey<FormState>();
    String name = vendor.name;
    String email = vendor.email;
    String phone = vendor.phone;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${vendor.name}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Vendor Name',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: name,
                  onChanged: (value) {
                    name = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a vendor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: email,
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: phone,
                  onChanged: (value) {
                    phone = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
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
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedVendor = Vendor(
                    id: vendor.id,
                    name: name,
                    email: email,
                    phone: phone,
                  );

                  ref
                      .read(vendorsProvider.notifier)
                      .updateVendor(updatedVendor);
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

  void _showDeleteVendorDialog(
    BuildContext context,
    WidgetRef ref,
    Vendor vendor,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Vendor'),
          content: Text(
            'Are you sure you want to delete vendor ${vendor.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(vendorsProvider.notifier).removeVendor(vendor.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}

// Dashboard Navigator
class AppNavigator extends StatefulWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation rail for large screens
          NavigationRail(
            extended: MediaQuery.of(context).size.width >= 1200,
            minExtendedWidth: 180,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                label: Text('Vendors'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.description),
                label: Text('Invoices'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.paid),
                label: Text('Payments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),

          // Main content area
          Expanded(child: _buildScreen()),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    switch (_selectedIndex) {
      case 0:
        return const AccountsPayableDashboard();
      case 1:
        return const VendorManagementScreen();
      case 2:
        return const AccountsPayableDashboard(); // We'll keep using the same screen for now
      default:
        return Center(
          child: Text('Screen $_selectedIndex not implemented yet'),
        );
    }
  }
}

// Let's update the main app to use the navigator

// Payment processing class
class PaymentProcessor {
  final String id;
  final String name;
  final double processingFee;
  final int processingTime; // in days

  PaymentProcessor({
    required this.id,
    required this.name,
    required this.processingFee,
    required this.processingTime,
  });
}

// Payment
class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime paymentDate;
  final String referenceNumber;
  final String processorId;
  final String notes;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    required this.referenceNumber,
    required this.processorId,
    this.notes = '',
  });
}

// Payment providers
final paymentProcessorsProvider = StateProvider<List<PaymentProcessor>>((ref) {
  return [
    PaymentProcessor(
      id: '1',
      name: 'Bank Transfer',
      processingFee: 0.00,
      processingTime: 2,
    ),
    PaymentProcessor(
      id: '2',
      name: 'Credit Card',
      processingFee: 2.75,
      processingTime: 0,
    ),
    PaymentProcessor(
      id: '3',
      name: 'PayPal',
      processingFee: 1.50,
      processingTime: 1,
    ),
    PaymentProcessor(
      id: '4',
      name: 'Check',
      processingFee: 0.00,
      processingTime: 5,
    ),
  ];
});

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, List<Payment>>(
  (ref) {
    return PaymentsNotifier();
  },
);

class PaymentsNotifier extends StateNotifier<List<Payment>> {
  PaymentsNotifier() : super([]);

  void addPayment(Payment payment) {
    state = [...state, payment];
  }

  void removePayment(String id) {
    state = state.where((payment) => payment.id != id).toList();
  }

  List<Payment> getPaymentsForInvoice(String invoiceId) {
    return state.where((payment) => payment.invoiceId == invoiceId).toList();
  }

  double getTotalPaidForInvoice(String invoiceId) {
    return state
        .where((payment) => payment.invoiceId == invoiceId)
        .fold(0, (sum, payment) => sum + payment.amount);
  }
}

// Function to recalculate invoice status based on payments
void recalculateInvoiceStatus(WidgetRef ref, String invoiceId) {
  final invoices = ref.read(invoicesProvider);
  final invoice = invoices.firstWhere((inv) => inv.id == invoiceId);
  final totalPaid = ref
      .read(paymentsProvider.notifier)
      .getTotalPaidForInvoice(invoiceId);

  // Calculate the new status
  InvoiceStatus newStatus;
  if (totalPaid >= invoice.amount) {
    newStatus = InvoiceStatus.paid;
  } else if (totalPaid > 0) {
    newStatus = InvoiceStatus.partiallyPaid;
  } else if (invoice.dueDate.isBefore(DateTime.now())) {
    newStatus = InvoiceStatus.overdue;
  } else {
    newStatus = InvoiceStatus.pending;
  }

  // Only update if status has changed
  if (newStatus != invoice.status) {
    ref
        .read(invoicesProvider.notifier)
        .updateInvoiceStatus(invoiceId, newStatus);
  }
}
