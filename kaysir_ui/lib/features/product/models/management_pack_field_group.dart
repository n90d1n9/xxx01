import 'management_pack.dart';
import 'product_form_section.dart';

/// Capability-based group of editable fields contributed by a management pack.
class ProductManagementPackFieldGroup {
  ProductManagementPackFieldGroup({
    required this.capability,
    required this.title,
    required this.description,
    required List<ProductManagementPackField> fields,
  }) : fields = List.unmodifiable(fields);

  final ProductManagementCapability capability;
  final String title;
  final String description;
  final List<ProductManagementPackField> fields;

  bool get hasFields => fields.isNotEmpty;
  int get fieldCount => fields.length;

  int get requiredFieldCount {
    return fields.where((field) => field.required).length;
  }

  String get fieldCountLabel => _countLabel(fieldCount, 'field');

  String get requiredFieldCountLabel {
    return _countLabel(requiredFieldCount, 'required field');
  }
}

/// Builds reusable capability groups for editable management pack fields.
List<ProductManagementPackFieldGroup> buildProductManagementPackFieldGroups(
  ProductManagementPack pack,
) {
  final groupedFields =
      <ProductManagementCapability, List<ProductManagementPackField>>{};

  for (final field in productManagementPackEditableFields(pack)) {
    groupedFields.putIfAbsent(field.capability, () => []).add(field);
  }

  final groups = [
    for (final entry in groupedFields.entries)
      ProductManagementPackFieldGroup(
        capability: entry.key,
        title: entry.key.label,
        description: _capabilityDescription(entry.key),
        fields: entry.value,
      ),
  ];

  groups.sort((left, right) {
    final leftPriority = left.fields.first.displayPriority;
    final rightPriority = right.fields.first.displayPriority;
    return leftPriority.compareTo(rightPriority);
  });

  return List.unmodifiable(groups);
}

String _capabilityDescription(ProductManagementCapability capability) {
  return switch (capability) {
    ProductManagementCapability.catalogBasics =>
      'Core catalog metadata shared by every product workflow.',
    ProductManagementCapability.scanReadiness =>
      'Identifiers used by scan, checkout, stock count, and kiosk flows.',
    ProductManagementCapability.stockTracking =>
      'Operational quantity and selling-unit data for inventory workflows.',
    ProductManagementCapability.omniChannelReadiness =>
      'Channel readiness data for multi-channel product launch.',
    ProductManagementCapability.expiryTracking =>
      'Freshness dates used to protect selling and replenishment decisions.',
    ProductManagementCapability.batchTracking =>
      'Lot-level traceability data for receiving, recalls, and audits.',
    ProductManagementCapability.weightedInventory =>
      'Controls for products sold by measured weight or variable quantity.',
    ProductManagementCapability.freshnessQueue =>
      'Review signals used to keep fresh goods safe and sellable.',
  };
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
