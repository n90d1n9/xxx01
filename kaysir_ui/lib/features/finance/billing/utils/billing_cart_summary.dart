class BillingCartSummaryLine {
  final String id;
  final String name;
  final double unitPrice;
  final int quantity;
  final bool taxable;

  const BillingCartSummaryLine({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.taxable = true,
  });

  double get lineSubtotal {
    if (quantity <= 0 || unitPrice <= 0) return 0;
    return unitPrice * quantity;
  }
}

class BillingPricingPolicy {
  final double taxRate;
  final double discountRate;
  final double flatDiscount;

  const BillingPricingPolicy({
    this.taxRate = 0,
    this.discountRate = 0,
    this.flatDiscount = 0,
  });
}

class BillingCartSummary {
  final int lineCount;
  final int itemCount;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;

  const BillingCartSummary({
    required this.lineCount,
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
  });

  bool get isEmpty => itemCount == 0;
}

BillingCartSummary summarizeBillingCart(
  Iterable<BillingCartSummaryLine> lines, {
  BillingPricingPolicy policy = const BillingPricingPolicy(),
}) {
  var lineCount = 0;
  var itemCount = 0;
  var subtotal = 0.0;
  var taxableSubtotal = 0.0;

  for (final line in lines) {
    if (line.quantity <= 0) continue;

    final lineSubtotal = line.lineSubtotal;
    if (lineSubtotal <= 0) continue;

    lineCount++;
    itemCount += line.quantity;
    subtotal += lineSubtotal;
    if (line.taxable) taxableSubtotal += lineSubtotal;
  }

  final percentageDiscount = subtotal * policy.discountRate.clamp(0, 1);
  final discount =
      (percentageDiscount + policy.flatDiscount).clamp(0, subtotal).toDouble();
  final discountRatio = subtotal == 0 ? 0.0 : discount / subtotal;
  final taxableDiscount = taxableSubtotal * discountRatio;
  final taxableBase =
      (taxableSubtotal - taxableDiscount).clamp(0, subtotal).toDouble();
  final tax = taxableBase * policy.taxRate.clamp(0, 1).toDouble();
  final total = subtotal - discount + tax;

  return BillingCartSummary(
    lineCount: lineCount,
    itemCount: itemCount,
    subtotal: subtotal,
    discount: discount,
    tax: tax,
    total: total,
  );
}
