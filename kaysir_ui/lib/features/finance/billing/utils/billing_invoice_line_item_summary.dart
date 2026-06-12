import '../models/billing_invoice_draft.dart';
import '../models/billing_invoice_line_item.dart';
import '../models/billing_invoice_tax_mode.dart';

export '../models/billing_invoice_tax_mode.dart';

class BillingInvoiceLineItemSummary {
  final int lineCount;
  final double quantity;
  final double subtotal;
  final double discount;
  final double taxableSubtotal;
  final double tax;
  final double total;

  const BillingInvoiceLineItemSummary({
    required this.lineCount,
    required this.quantity,
    required this.subtotal,
    required this.discount,
    required this.taxableSubtotal,
    required this.tax,
    required this.total,
  });

  bool get isEmpty => lineCount == 0;

  double get netSubtotal {
    return (subtotal - discount).clamp(0, subtotal).toDouble();
  }
}

BillingInvoiceLineItemSummary summarizeBillingInvoiceLineItems(
  Iterable<BillingInvoiceLineItem> lineItems, {
  BillingInvoiceTaxMode taxMode = BillingInvoiceTaxMode.exclusive,
}) {
  var lineCount = 0;
  var quantity = 0.0;
  var subtotal = 0.0;
  var discount = 0.0;
  var taxableSubtotal = 0.0;
  var tax = 0.0;

  for (final lineItem in lineItems) {
    if (lineItem.quantity <= 0) continue;

    final lineSubtotal = lineItem.subtotal;
    final lineDiscount = lineItem.discount;
    final lineNetSubtotal = lineItem.netSubtotal;

    lineCount++;
    quantity += lineItem.quantity;
    subtotal += lineSubtotal;
    discount += lineDiscount;

    if (!lineItem.taxable || taxMode == BillingInvoiceTaxMode.exempt) {
      continue;
    }

    taxableSubtotal += lineNetSubtotal;

    final rate = lineItem.taxRate.clamp(0, 1).toDouble();
    if (rate <= 0 || lineNetSubtotal <= 0) continue;

    tax += switch (taxMode) {
      BillingInvoiceTaxMode.exclusive => lineNetSubtotal * rate,
      BillingInvoiceTaxMode.inclusive =>
        lineNetSubtotal - (lineNetSubtotal / (1 + rate)),
      BillingInvoiceTaxMode.exempt => 0,
    };
  }

  final netSubtotal = (subtotal - discount).clamp(0, subtotal).toDouble();
  final total = switch (taxMode) {
    BillingInvoiceTaxMode.exclusive => netSubtotal + tax,
    BillingInvoiceTaxMode.inclusive => netSubtotal,
    BillingInvoiceTaxMode.exempt => netSubtotal,
  };

  return BillingInvoiceLineItemSummary(
    lineCount: lineCount,
    quantity: quantity,
    subtotal: subtotal,
    discount: discount,
    taxableSubtotal: taxableSubtotal,
    tax: tax,
    total: total,
  );
}

BillingInvoiceLineItemSummary summarizeBillingInvoiceDraftLineItems(
  BillingInvoiceDraft draft, {
  BillingInvoiceTaxMode? taxMode,
}) {
  return summarizeBillingInvoiceLineItems(
    draft.lineItems,
    taxMode: taxMode ?? draft.taxMode,
  );
}

double billingInvoiceDraftTotal(
  BillingInvoiceDraft draft, {
  BillingInvoiceTaxMode? taxMode,
}) {
  if (draft.lineItems.isEmpty) return draft.amount;

  return summarizeBillingInvoiceDraftLineItems(draft, taxMode: taxMode).total;
}
