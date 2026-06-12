import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/payment.dart';

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
    final invoicePayments =
        invoices
            .where((invoice) => invoice.id == invoiceId)
            .expand((invoice) => invoice.payments ?? const <Payment>[])
            .toList();
    final externalPayments =
        payments.where((payment) => payment.invoiceId == invoiceId).toList();

    return {
      for (final payment in [...invoicePayments, ...externalPayments])
        payment.id: payment,
    }.values.toList();
  }

  // Helper method to calculate total paid amount for an invoice
  double getTotalPaidForInvoice(String invoiceId) {
    return getPaymentsForInvoice(
      invoiceId,
    ).fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // Helper method to calculate outstanding amount for an invoice
  double getOutstandingAmountForInvoice(String invoiceId) {
    final invoice = invoices.firstWhere(
      (inv) => inv.id == invoiceId,
      orElse: () => Invoice(id: invoiceId),
    );
    final totalPaid = getTotalPaidForInvoice(invoiceId);
    if (invoice.status == InvoiceStatus.paid) {
      return 0;
    }
    return (invoice.amount - totalPaid).clamp(0, invoice.amount).toDouble();
  }

  // Calculate total outstanding AR
  double get totalOutstandingAR {
    return invoices.fold(0.0, (sum, invoice) {
      return sum + getOutstandingAmountForInvoice(invoice.id);
    });
  }

  double get totalInvoiced {
    return invoices.fold(0.0, (sum, invoice) => sum + invoice.amount);
  }

  double get totalCollected {
    return invoices.fold(
      0.0,
      (sum, invoice) => sum + getTotalPaidForInvoice(invoice.id),
    );
  }

  double get collectionRate {
    if (totalInvoiced == 0) {
      return 0;
    }
    return totalCollected / totalInvoiced;
  }

  double get dueSoonTotal {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return invoices
        .where((invoice) {
          final dueDate = invoice.dueDate;
          return invoice.status != InvoiceStatus.paid &&
              dueDate != null &&
              !dueDate.isBefore(now) &&
              dueDate.isBefore(nextWeek);
        })
        .fold(
          0.0,
          (sum, invoice) => sum + getOutstandingAmountForInvoice(invoice.id),
        );
  }

  Map<String, double> get agingBuckets {
    final now = DateTime.now();
    final buckets = {
      'Current': 0.0,
      '1-30': 0.0,
      '31-60': 0.0,
      '61-90': 0.0,
      '90+': 0.0,
    };

    for (final invoice in invoices) {
      final outstanding = getOutstandingAmountForInvoice(invoice.id);
      final dueDate = invoice.dueDate;
      if (outstanding <= 0 || dueDate == null) {
        continue;
      }

      final daysPastDue = now.difference(dueDate).inDays;
      final bucket =
          daysPastDue <= 0
              ? 'Current'
              : daysPastDue <= 30
              ? '1-30'
              : daysPastDue <= 60
              ? '31-60'
              : daysPastDue <= 90
              ? '61-90'
              : '90+';
      buckets[bucket] = buckets[bucket]! + outstanding;
    }

    return buckets;
  }

  List<Invoice> get collectionQueue {
    final openInvoices =
        invoices
            .where((invoice) => getOutstandingAmountForInvoice(invoice.id) > 0)
            .toList();

    openInvoices.sort((a, b) {
      final aDate = a.dueDate ?? DateTime(2100);
      final bDate = b.dueDate ?? DateTime(2100);
      return aDate.compareTo(bDate);
    });

    return openInvoices;
  }

  // Get invoices grouped by status
  Map<InvoiceStatus, List<Invoice>> get invoicesByStatus {
    Map<InvoiceStatus, List<Invoice>> result = {};
    for (var status in InvoiceStatus.values) {
      result[status] =
          invoices.where((invoice) => invoice.status == status).toList();
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
              invoice.dueDate != null &&
              invoice.dueDate!.isBefore(now),
        )
        .toList();
  }
}
