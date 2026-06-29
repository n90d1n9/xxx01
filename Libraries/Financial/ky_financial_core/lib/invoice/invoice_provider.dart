import 'package:flutter_riverpod/legacy.dart';

import '../payment/payment.dart';
import 'invoice.dart';

// Providers
final invoicesProvider = StateNotifierProvider<InvoiceNotifier, List<Invoice>>((
  ref,
) {
  return InvoiceNotifier();
});

final filteredInvoicesProvider = StateProvider<String>((ref) => 'all');

final displayedInvoicesProvider = Provider<List<Invoice>>((ref) {
  final filter = ref.watch(filteredInvoicesProvider);
  final invoices = ref.watch(invoicesProvider);

  switch (filter) {
    case 'pending':
      return invoices.where((invoice) => invoice.status == 'pending').toList();
    case 'overdue':
      return invoices.where((invoice) => invoice.status == 'overdue').toList();
    case 'paid':
      return invoices.where((invoice) => invoice.status == 'paid').toList();
    default:
      return invoices;
  }
});

final selectedPeriodProvider = StateProvider<String>((ref) => 'This Month');

// Notifiers
class InvoiceNotifier extends StateNotifier<List<Invoice>> {
  InvoiceNotifier()
    : super([
        Invoice(
          id: 'INV-001',
          vendorName: 'Tech Solutions Inc.',
          amount: 2500.00,
          dueDate: DateTime.now().add(const Duration(days: 15)),
          status: 'pending',
        ),
        Invoice(
          id: 'INV-002',
          vendorName: 'Office Supplies Co.',
          amount: 750.50,
          dueDate: DateTime.now().add(const Duration(days: -5)),
          status: 'overdue',
        ),
        Invoice(
          id: 'INV-003',
          vendorName: 'Marketing Agency',
          amount: 4200.00,
          dueDate: DateTime.now().add(const Duration(days: 20)),
          status: 'pending',
        ),
        Invoice(
          id: 'INV-004',
          vendorName: 'Cloud Services Ltd.',
          amount: 1200.00,
          dueDate: DateTime.now().add(const Duration(days: -10)),
          status: 'overdue',
        ),
        Invoice(
          id: 'INV-005',
          vendorName: 'Tech Solutions Inc.',
          amount: 1800.00,
          dueDate: DateTime.now().add(const Duration(days: -20)),
          status: 'paid',
        ),
      ]);

  void markAsPaid(String id) {
    state = [
      for (final invoice in state)
        if (invoice.id == id)
          Invoice(
            id: invoice.id,
            vendorName: invoice.vendorName,
            amount: invoice.amount,
            dueDate: invoice.dueDate,
            isPaid: true,
            status: 'paid',
          )
        else
          invoice,
    ];
  }

  void addInvoice(Invoice invoice) {
    state = [...state, invoice];
  }
}

final invoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  // Simulate API call
  await Future.delayed(Duration(seconds: 1));
  final now = DateTime.now();
  return [
    Invoice(
      id: 'INV-001',
      customerId: '1',
      amount: 5000.00,
      issueDate: now.subtract(Duration(days: 30)),
      dueDate: now.subtract(Duration(days: 15)),
      payments: [
        Payment(
          id: 'PAY-001',
          invoiceId: 'INV-001',
          amount: 2500.00,
          date: now.subtract(Duration(days: 20)),
          method: 'bank_transfer',
        ),
      ],
      status: 'partial',
    ),
    Invoice(
      id: 'INV-002',
      customerId: '2',
      amount: 7500.00,
      issueDate: now.subtract(Duration(days: 20)),
      dueDate: now.add(Duration(days: 10)),
      payments: [],
      status: 'pending',
    ),
    Invoice(
      id: 'INV-003',
      customerId: '3',
      amount: 12000.00,
      issueDate: now.subtract(Duration(days: 45)),
      dueDate: now.subtract(Duration(days: 15)),
      payments: [
        Payment(
          id: 'PAY-002',
          invoiceId: 'INV-003',
          amount: 12000.00,
          date: now.subtract(Duration(days: 10)),
          method: 'credit_card',
        ),
      ],
      status: 'paid',
    ),
    Invoice(
      id: 'INV-004',
      customerId: '1',
      amount: 3000.00,
      issueDate: now.subtract(Duration(days: 60)),
      dueDate: now.subtract(Duration(days: 30)),
      payments: [],
      status: 'overdue',
    ),
    Invoice(
      id: 'INV-005',
      customerId: '4',
      amount: 8500.00,
      issueDate: now.subtract(Duration(days: 15)),
      dueDate: now.add(Duration(days: 15)),
      payments: [
        Payment(
          id: 'PAY-003',
          invoiceId: 'INV-005',
          amount: 4250.00,
          date: now.subtract(Duration(days: 5)),
          method: 'bank_transfer',
        ),
      ],
      status: 'partial',
    ),
  ];
});

final selectedFilterProvider = StateProvider<String>((ref) => 'all');

final filteredInvoicesProvider = Provider<AsyncValue<List<Invoice>>>((ref) {
  final invoicesAsync = ref.watch(invoicesProvider);
  final filter = ref.watch(selectedFilterProvider);

  return invoicesAsync.whenData((invoices) {
    switch (filter) {
      case 'paid':
        return invoices.where((invoice) => invoice.status == 'paid').toList();
      case 'partial':
        return invoices
            .where((invoice) => invoice.status == 'partial')
            .toList();
      case 'pending':
        return invoices
            .where((invoice) => invoice.status == 'pending')
            .toList();
      case 'overdue':
        return invoices
            .where((invoice) => invoice.status == 'overdue')
            .toList();
      default:
        return invoices;
    }
  });
});
