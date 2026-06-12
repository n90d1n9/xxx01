import 'vendor.dart';

enum VendorStatementLineType { bill, payment }

class VendorStatementLine {
  final VendorStatementLineType type;
  final DateTime date;
  final String reference;
  final String description;
  final double chargeAmount;
  final double paymentAmount;
  final double balance;

  const VendorStatementLine({
    required this.type,
    required this.date,
    required this.reference,
    required this.description,
    required this.balance,
    this.chargeAmount = 0,
    this.paymentAmount = 0,
  });
}

class VendorStatement {
  final Vendor vendor;
  final List<VendorStatementLine> lines;
  final double totalBilled;
  final double totalPaid;
  final double overdueAmount;
  final int openBillCount;

  const VendorStatement({
    required this.vendor,
    required this.lines,
    this.totalBilled = 0,
    this.totalPaid = 0,
    this.overdueAmount = 0,
    this.openBillCount = 0,
  });

  double get outstandingAmount => totalBilled - totalPaid;
}
