import '../models/invoice.dart';
import '../models/payment.dart';
import '../models/vendor.dart';
import '../models/vendor_statement.dart';

class VendorStatementService {
  const VendorStatementService();

  VendorStatement build({
    required Vendor vendor,
    required Iterable<Invoice> bills,
    required Iterable<Payment> payments,
    required DateTime asOf,
  }) {
    final vendorBills =
        bills.where((bill) => bill.vendorId == vendor.id).toList()
          ..sort(_compareBills);
    final paymentsByInvoiceId = _paymentsByInvoiceId(vendorBills, payments);
    final draftLines = <_DraftStatementLine>[];

    var totalBilled = 0.0;
    var totalPaid = 0.0;
    var overdueAmount = 0.0;
    var openBillCount = 0;

    for (final bill in vendorBills) {
      final billReference = bill.invoiceNumber ?? bill.id;
      final billDate = bill.invoiceDate ?? bill.issueDate ?? bill.dueDate;
      if (billDate == null) {
        continue;
      }

      totalBilled += bill.amount;
      draftLines.add(
        _DraftStatementLine(
          sortDate: billDate,
          sortPriority: 0,
          reference: billReference,
          description:
              bill.description.trim().isEmpty
                  ? 'Vendor bill $billReference'
                  : bill.description.trim(),
          type: VendorStatementLineType.bill,
          chargeAmount: bill.amount,
        ),
      );

      final billPayments = paymentsByInvoiceId[bill.id] ?? const <Payment>[];
      final paidAmount = billPayments.fold(
        0.0,
        (total, payment) => total + payment.amount,
      );
      totalPaid += paidAmount;

      final outstanding = bill.amount - paidAmount;
      if (outstanding > 0.01) {
        openBillCount++;
        final dueDate = bill.dueDate;
        if (dueDate != null && _dateOnly(dueDate).isBefore(_dateOnly(asOf))) {
          overdueAmount += outstanding;
        }
      }

      for (final payment in billPayments) {
        draftLines.add(
          _DraftStatementLine(
            sortDate: payment.paymentDate ?? billDate,
            sortPriority: 1,
            reference:
                payment.reference ??
                payment.referenceNumber ??
                'Payment ${payment.id}',
            description: 'Payment for $billReference',
            type: VendorStatementLineType.payment,
            paymentAmount: payment.amount,
          ),
        );
      }
    }

    draftLines.sort(_compareDraftLines);

    var runningBalance = 0.0;
    final lines = <VendorStatementLine>[];
    for (final line in draftLines) {
      runningBalance += line.chargeAmount;
      runningBalance -= line.paymentAmount;
      lines.add(
        VendorStatementLine(
          type: line.type,
          date: line.sortDate,
          reference: line.reference,
          description: line.description,
          chargeAmount: line.chargeAmount,
          paymentAmount: line.paymentAmount,
          balance: runningBalance,
        ),
      );
    }

    return VendorStatement(
      vendor: vendor,
      lines: lines,
      totalBilled: totalBilled,
      totalPaid: totalPaid,
      overdueAmount: overdueAmount,
      openBillCount: openBillCount,
    );
  }

  Map<String, List<Payment>> _paymentsByInvoiceId(
    List<Invoice> bills,
    Iterable<Payment> payments,
  ) {
    final invoiceIds = {for (final bill in bills) bill.id};
    final paymentById = <String, Payment>{};

    for (final bill in bills) {
      for (final payment in bill.payments ?? const <Payment>[]) {
        paymentById[payment.id] = payment;
      }
    }
    for (final payment in payments) {
      if (invoiceIds.contains(payment.invoiceId)) {
        paymentById[payment.id] = payment;
      }
    }

    final grouped = <String, List<Payment>>{};
    for (final payment in paymentById.values) {
      if (!invoiceIds.contains(payment.invoiceId)) {
        continue;
      }
      grouped.putIfAbsent(payment.invoiceId, () => []).add(payment);
    }
    for (final invoicePayments in grouped.values) {
      invoicePayments.sort(_comparePayments);
    }

    return grouped;
  }

  int _compareBills(Invoice a, Invoice b) {
    final dateComparison = (a.invoiceDate ?? a.issueDate ?? a.dueDate!)
        .compareTo(b.invoiceDate ?? b.issueDate ?? b.dueDate!);
    if (dateComparison != 0) {
      return dateComparison;
    }
    return (a.invoiceNumber ?? a.id).compareTo(b.invoiceNumber ?? b.id);
  }

  int _comparePayments(Payment a, Payment b) {
    final dateComparison = (a.paymentDate ?? DateTime(9999)).compareTo(
      b.paymentDate ?? DateTime(9999),
    );
    if (dateComparison != 0) {
      return dateComparison;
    }
    return a.id.compareTo(b.id);
  }

  int _compareDraftLines(_DraftStatementLine a, _DraftStatementLine b) {
    final dateComparison = a.sortDate.compareTo(b.sortDate);
    if (dateComparison != 0) {
      return dateComparison;
    }
    final priorityComparison = a.sortPriority.compareTo(b.sortPriority);
    if (priorityComparison != 0) {
      return priorityComparison;
    }
    return a.reference.compareTo(b.reference);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class _DraftStatementLine {
  final DateTime sortDate;
  final int sortPriority;
  final VendorStatementLineType type;
  final String reference;
  final String description;
  final double chargeAmount;
  final double paymentAmount;

  const _DraftStatementLine({
    required this.sortDate,
    required this.sortPriority,
    required this.type,
    required this.reference,
    required this.description,
    this.chargeAmount = 0,
    this.paymentAmount = 0,
  });
}
