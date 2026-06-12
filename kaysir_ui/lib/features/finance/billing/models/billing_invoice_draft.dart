import 'billing_invoice_line_item.dart';
import 'billing_invoice_tax_mode.dart';

class BillingInvoiceDraft {
  final String tenantId;
  final double amount;
  final DateTime issueDate;
  final List<BillingInvoiceLineItem> lineItems;
  final BillingInvoiceTaxMode taxMode;

  BillingInvoiceDraft({
    required this.tenantId,
    required this.amount,
    required this.issueDate,
    Iterable<BillingInvoiceLineItem> lineItems = const [],
    this.taxMode = BillingInvoiceTaxMode.exclusive,
  }) : lineItems = List.unmodifiable(lineItems);

  bool get isValid => validationErrors.isEmpty;

  bool get hasLineItems => lineItems.isNotEmpty;

  List<String> get validationErrors {
    final errors = <String>[];
    final hasBillableLineItems = lineItems.any(
      (lineItem) => lineItem.netSubtotal > 0,
    );

    if (tenantId.trim().isEmpty) {
      errors.add('Choose a tenant before creating an invoice.');
    }

    if (amount <= 0 && !hasBillableLineItems) {
      errors.add('Enter an invoice amount greater than zero.');
    }

    for (final lineItem in lineItems) {
      errors.addAll(lineItem.validationErrors);
    }

    return List.unmodifiable(errors);
  }

  BillingInvoiceDraft copyWith({
    String? tenantId,
    double? amount,
    DateTime? issueDate,
    Iterable<BillingInvoiceLineItem>? lineItems,
    BillingInvoiceTaxMode? taxMode,
  }) {
    return BillingInvoiceDraft(
      tenantId: tenantId ?? this.tenantId,
      amount: amount ?? this.amount,
      issueDate: issueDate ?? this.issueDate,
      lineItems: lineItems ?? this.lineItems,
      taxMode: taxMode ?? this.taxMode,
    );
  }

  void ensureValid() {
    final errors = validationErrors;
    if (errors.isNotEmpty) {
      throw StateError(errors.first);
    }
  }
}
