import 'billing_invoice_line_item.dart';

String billingInvoiceLineItemAdapterKey(String domain, String type) {
  return '${_normalizeAdapterPart(domain)}:${_normalizeAdapterPart(type)}';
}

String _normalizeAdapterPart(String value) => value.trim().toLowerCase();

class BillingInvoiceLineItemAdapter {
  final String domain;
  final String type;
  final bool Function(Object value) canAdapt;
  final BillingInvoiceLineItem Function(Object value) toLineItem;

  const BillingInvoiceLineItemAdapter({
    required this.domain,
    required this.type,
    required this.canAdapt,
    required this.toLineItem,
  });

  String get key => billingInvoiceLineItemAdapterKey(domain, type);

  bool matches(Object value, {String? domain, String? type}) {
    if (domain != null &&
        _normalizeAdapterPart(domain) != _normalizeAdapterPart(this.domain)) {
      return false;
    }
    if (type != null &&
        _normalizeAdapterPart(type) != _normalizeAdapterPart(this.type)) {
      return false;
    }

    return canAdapt(value);
  }

  BillingInvoiceLineItem adapt(Object value) {
    if (!canAdapt(value)) {
      throw StateError(
        'Adapter $key cannot convert the supplied billing value.',
      );
    }

    final lineItem = toLineItem(value);
    final errors = lineItem.validationErrors;
    if (errors.isNotEmpty) {
      throw StateError(errors.first);
    }

    return lineItem;
  }
}

class BillingInvoiceLineItemAdapterRegistry {
  final List<BillingInvoiceLineItemAdapter> adapters;

  BillingInvoiceLineItemAdapterRegistry({
    Iterable<BillingInvoiceLineItemAdapter> adapters = const [],
  }) : adapters = List.unmodifiable(_ensureUnique(adapters));

  bool get isEmpty => adapters.isEmpty;

  BillingInvoiceLineItemAdapterRegistry register(
    BillingInvoiceLineItemAdapter adapter,
  ) {
    return BillingInvoiceLineItemAdapterRegistry(
      adapters: [...adapters, adapter],
    );
  }

  BillingInvoiceLineItemAdapter? findAdapter(
    Object value, {
    String? domain,
    String? type,
  }) {
    for (final adapter in adapters) {
      if (adapter.matches(value, domain: domain, type: type)) {
        return adapter;
      }
    }

    return null;
  }

  BillingInvoiceLineItem adapt(Object value, {String? domain, String? type}) {
    final adapter = findAdapter(value, domain: domain, type: type);
    if (adapter == null) {
      throw StateError(
        'No billing line item adapter is registered for the supplied value.',
      );
    }

    return adapter.adapt(value);
  }

  List<BillingInvoiceLineItem> adaptAll(
    Iterable<Object> values, {
    String? domain,
    String? type,
  }) {
    return List.unmodifiable(
      values.map((value) => adapt(value, domain: domain, type: type)),
    );
  }

  static List<BillingInvoiceLineItemAdapter> _ensureUnique(
    Iterable<BillingInvoiceLineItemAdapter> adapters,
  ) {
    final seenKeys = <String>{};
    final uniqueAdapters = <BillingInvoiceLineItemAdapter>[];

    for (final adapter in adapters) {
      if (adapter.domain.trim().isEmpty) {
        throw StateError('Billing line item adapter domain is required.');
      }
      if (adapter.type.trim().isEmpty) {
        throw StateError('Billing line item adapter type is required.');
      }
      if (!seenKeys.add(adapter.key)) {
        throw StateError(
          'Duplicate billing line item adapter registered for ${adapter.key}.',
        );
      }
      uniqueAdapters.add(adapter);
    }

    return uniqueAdapters;
  }
}
