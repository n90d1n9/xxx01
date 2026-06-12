class BillingInvoiceLineItemSource {
  final String domain;
  final String type;
  final String id;
  final Map<String, String> attributes;

  BillingInvoiceLineItemSource({
    required this.domain,
    required this.type,
    required this.id,
    Map<String, String> attributes = const {},
  }) : attributes = Map.unmodifiable(attributes);

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];

    if (domain.trim().isEmpty) {
      errors.add('Line item source domain is required.');
    }
    if (type.trim().isEmpty) {
      errors.add('Line item source type is required.');
    }
    if (id.trim().isEmpty) {
      errors.add('Line item source id is required.');
    }

    return List.unmodifiable(errors);
  }

  BillingInvoiceLineItemSource copyWith({
    String? domain,
    String? type,
    String? id,
    Map<String, String>? attributes,
  }) {
    return BillingInvoiceLineItemSource(
      domain: domain ?? this.domain,
      type: type ?? this.type,
      id: id ?? this.id,
      attributes: attributes ?? this.attributes,
    );
  }
}

class BillingInvoiceLineItem {
  final String id;
  final String description;
  final double quantity;
  final double unitPrice;
  final String unitLabel;
  final double discountAmount;
  final bool taxable;
  final double taxRate;
  final BillingInvoiceLineItemSource? source;
  final DateTime? servicePeriodStart;
  final DateTime? servicePeriodEnd;

  const BillingInvoiceLineItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.unitLabel = 'unit',
    this.discountAmount = 0,
    this.taxable = true,
    this.taxRate = 0,
    this.source,
    this.servicePeriodStart,
    this.servicePeriodEnd,
  });

  double get subtotal {
    if (quantity <= 0 || unitPrice <= 0) return 0;
    return quantity * unitPrice;
  }

  double get discount {
    return discountAmount.clamp(0, subtotal).toDouble();
  }

  double get netSubtotal {
    return (subtotal - discount).clamp(0, subtotal).toDouble();
  }

  bool get hasServicePeriod {
    return servicePeriodStart != null || servicePeriodEnd != null;
  }

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];

    if (id.trim().isEmpty) {
      errors.add('Line item id is required.');
    }
    if (description.trim().isEmpty) {
      errors.add('Line item description is required.');
    }
    if (quantity <= 0) {
      errors.add('Line item quantity must be greater than zero.');
    }
    if (unitPrice < 0) {
      errors.add('Line item unit price cannot be negative.');
    }
    if (discountAmount < 0) {
      errors.add('Line item discount cannot be negative.');
    }
    if (taxRate < 0 || taxRate > 1) {
      errors.add('Line item tax rate must be between 0 and 1.');
    }
    if (servicePeriodStart != null &&
        servicePeriodEnd != null &&
        servicePeriodEnd!.isBefore(servicePeriodStart!)) {
      errors.add('Line item service period end cannot be before its start.');
    }
    final sourceErrors = source?.validationErrors ?? const <String>[];
    errors.addAll(sourceErrors);

    return List.unmodifiable(errors);
  }

  BillingInvoiceLineItem copyWith({
    String? id,
    String? description,
    double? quantity,
    double? unitPrice,
    String? unitLabel,
    double? discountAmount,
    bool? taxable,
    double? taxRate,
    BillingInvoiceLineItemSource? source,
    DateTime? servicePeriodStart,
    DateTime? servicePeriodEnd,
  }) {
    return BillingInvoiceLineItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unitLabel: unitLabel ?? this.unitLabel,
      discountAmount: discountAmount ?? this.discountAmount,
      taxable: taxable ?? this.taxable,
      taxRate: taxRate ?? this.taxRate,
      source: source ?? this.source,
      servicePeriodStart: servicePeriodStart ?? this.servicePeriodStart,
      servicePeriodEnd: servicePeriodEnd ?? this.servicePeriodEnd,
    );
  }
}
