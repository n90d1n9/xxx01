import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/invoice.dart';
import '../states/invoice_provider.dart';
import '../states/paymen_proc_provider.dart';

void recalculateInvoiceStatus(WidgetRef ref, String invoiceId) {
  final invoices = ref.watch(invoicesProvider).invoices;
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
  } else if (invoice.dueDate!.isBefore(DateTime.now())) {
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
