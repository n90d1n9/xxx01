import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/invoic_dummy.dart';

import '../models/invoice.dart';
import '../models/payment.dart';
import '../services/invoice_payment_policy.dart';
import '../services/payable_aging_service.dart';
import 'invoice_filter_provider.dart';

final invoicesProvider = StateNotifierProvider<InvoicesNotifier, InvoiceState>((
  ref,
) {
  return InvoicesNotifier();
});

class InvoicesNotifier extends StateNotifier<InvoiceState> {
  final InvoicePaymentPolicy _paymentPolicy;

  InvoicesNotifier({
    InvoicePaymentPolicy paymentPolicy = const InvoicePaymentPolicy(),
  }) : _paymentPolicy = paymentPolicy,
       super(InvoiceState(invoices: invoiceDummy));

  Future<List<Invoice>> getAllInvoice() async {
    await Future.delayed(const Duration(microseconds: 500));
    return state.invoices;
  }

  AsyncValue<List<Invoice>> getAllInvoiceAsync() {
    return AsyncValue.data(state.invoices);
  }

  void addInvoice(Invoice invoice) {
    state = state.copyWith(invoices: [...state.invoices, invoice]);
  }

  void updateInvoice(Invoice updatedInvoice) {
    state = state.copyWith(
      invoices:
          state.invoices.map((invoice) {
            if (invoice.id == updatedInvoice.id) {
              return updatedInvoice;
            }
            return invoice;
          }).toList(),
    );
  }

  void markAsPaid(String id) {
    updateInvoiceStatus(id, InvoiceStatus.paid);
  }

  void updateInvoiceStatus(String id, InvoiceStatus status) {
    state = state.copyWith(
      invoices:
          state.invoices
              .map(
                (invoice) =>
                    invoice.id == id
                        ? invoice.copyWith(
                          status: status,
                          isPaid: status == InvoiceStatus.paid,
                        )
                        : invoice,
              )
              .toList(),
    );
  }

  void recordPayment(String invoiceId, Payment payment) {
    state = state.copyWith(
      invoices:
          state.invoices.map((invoice) {
            if (invoice.id != invoiceId) {
              return invoice;
            }

            final currentPayments = invoice.payments ?? const <Payment>[];
            final hasPayment = currentPayments.any(
              (existingPayment) => existingPayment.id == payment.id,
            );
            final updatedPayments =
                hasPayment
                    ? currentPayments
                        .map(
                          (existingPayment) =>
                              existingPayment.id == payment.id
                                  ? payment
                                  : existingPayment,
                        )
                        .toList()
                    : [...currentPayments, payment];
            final status = _paymentPolicy.statusFor(
              invoice: invoice,
              payments: updatedPayments,
            );

            return invoice.copyWith(
              payments: updatedPayments,
              status: status,
              isPaid: status == InvoiceStatus.paid,
            );
          }).toList(),
    );
  }

  void removeInvoice(String id) {
    state = state.copyWith(
      invoices: state.invoices.where((invoice) => invoice.id != id).toList(),
    );
  }
}

class InvoiceState {
  final List<Invoice> invoices;
  final bool isLoading;
  final Invoice currentInvoice;

  InvoiceState({
    this.invoices = const [],
    this.isLoading = false,
    Invoice? currentInvoice,
  }) : currentInvoice = currentInvoice ?? Invoice(id: '');

  InvoiceState copyWith({
    List<Invoice>? invoices,
    bool? isLoading,
    Invoice? currentInvoice,
  }) {
    return InvoiceState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      currentInvoice: currentInvoice ?? this.currentInvoice,
    );
  }
}

final totalOutstandingProvider = Provider<double>((ref) {
  final invoices = ref.watch(payableInvoicesProvider);
  return invoices
      .where((invoice) => invoice.status != InvoiceStatus.paid)
      .fold(0, (sum, invoice) => sum + invoice.remainingAmount);
});

final overdueInvoicesCountProvider = Provider<int>((ref) {
  final invoices = ref.watch(payableInvoicesProvider);
  return invoices
      .where(
        (invoice) =>
            invoice.status != InvoiceStatus.paid &&
            invoice.dueDate != null &&
            invoice.dueDate!.isBefore(DateTime.now()),
      )
      .length;
});

final upcomingDueInvoicesProvider = Provider<List<Invoice>>((ref) {
  final invoices = ref.watch(payableInvoicesProvider);
  final now = DateTime.now();
  final nextWeek = now.add(const Duration(days: 7));
  return invoices.where((invoice) {
    final dueDate = invoice.dueDate;
    return invoice.status != InvoiceStatus.paid &&
        dueDate != null &&
        !dueDate.isBefore(now) &&
        dueDate.isBefore(nextWeek);
  }).toList();
});

final displayedInvoicesProvider = Provider<List<Invoice>>((ref) {
  final selectedFilter = ref.watch(selectedFilterProvider);
  final invoices = ref.watch(payableInvoicesProvider);

  switch (selectedFilter) {
    case 'pending':
      return invoices
          .where((invoice) => invoice.status == InvoiceStatus.pending)
          .toList();
    case 'overdue':
      return invoices
          .where((invoice) => invoice.status == InvoiceStatus.overdue)
          .toList();
    case 'paid':
      return invoices
          .where((invoice) => invoice.status == InvoiceStatus.paid)
          .toList();
    default:
      return invoices;
  }
});

final selectedPeriodProvider = StateProvider<String>((ref) => 'This Month');

final allPayableInvoicesProvider = Provider<List<Invoice>>((ref) {
  return ref.watch(invoicesProvider).invoices.where(_isPayableInvoice).toList()
    ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
});

final payableInvoicesProvider = Provider<List<Invoice>>((ref) {
  final filter = ref.watch(invoiceFilterProvider);
  final invoices = ref.watch(allPayableInvoicesProvider);
  final asOf = DateTime.now();

  return invoices
      .where(
        (invoice) => matchesPayableInvoiceFilter(invoice, filter, asOf: asOf),
      )
      .toList();
});

bool _isPayableInvoice(Invoice invoice) {
  return invoice.vendorId != null &&
      invoice.invoiceNumber != null &&
      invoice.invoiceDate != null &&
      invoice.dueDate != null;
}

bool matchesPayableInvoiceFilter(
  Invoice invoice,
  InvoiceFilter filter, {
  required DateTime asOf,
}) {
  final dueDate = invoice.dueDate;
  if (dueDate == null) {
    return false;
  }

  final matchesStatus =
      filter.status == null || invoice.status == filter.status;
  final matchesVendor =
      filter.vendorId == null || invoice.vendorId == filter.vendorId;
  final matchesOverdue =
      !filter.showOverdueOnly ||
      (dueDate.isBefore(asOf) && invoice.status != InvoiceStatus.paid);
  final matchesAgingBucket =
      filter.agingBucketId == null ||
      (invoice.remainingAmount > 0 &&
          const PayableAgingService().bucketIdFor(
                dueDate: dueDate,
                asOf: asOf,
              ) ==
              filter.agingBucketId);

  return matchesStatus && matchesVendor && matchesOverdue && matchesAgingBucket;
}
