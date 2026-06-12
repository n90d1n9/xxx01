import 'product_core_information_field_ids.dart';

/// Live validation state for one core product information field.
class ProductCoreInformationFieldProgress {
  const ProductCoreInformationFieldProgress({
    required this.fieldId,
    required this.value,
    required this.required,
    this.locked = false,
  });

  final String fieldId;
  final String value;
  final bool required;
  final bool locked;

  String get trimmedValue => value.trim();
  bool get isFilled => trimmedValue.isNotEmpty;
  bool get isMissingRequired => required && !locked && !isFilled;
  bool get hasInvalidValue => !locked && isFilled && validationError != null;
  bool get isReady => locked || (!isMissingRequired && !hasInvalidValue);

  String get label => _fieldLabel(fieldId);
  String get typeLabel => _fieldTypeLabel(fieldId);

  String? get validationError {
    if (locked) return null;
    if (!required && !isFilled) return null;

    return switch (fieldId) {
      ProductCoreInformationFieldIds.price => _priceError(trimmedValue),
      ProductCoreInformationFieldIds.initialStock => _stockError(trimmedValue),
      _ => isMissingRequired ? 'Required' : null,
    };
  }
}

/// Summary metrics for the core product information editor section.
class ProductCoreInformationFieldSummary {
  ProductCoreInformationFieldSummary({
    required List<ProductCoreInformationFieldProgress> fields,
  }) : fields = List.unmodifiable(fields);

  factory ProductCoreInformationFieldSummary.forEditor({
    required bool isEditing,
    Map<String, String> values = const {},
  }) {
    return ProductCoreInformationFieldSummary(
      fields: [
        for (final fieldId in ProductCoreInformationFieldIds.all)
          ProductCoreInformationFieldProgress(
            fieldId: fieldId,
            value: values[fieldId] ?? '',
            required: _isRequiredField(fieldId, isEditing: isEditing),
            locked: _isLockedField(fieldId, isEditing: isEditing),
          ),
      ],
    );
  }

  final List<ProductCoreInformationFieldProgress> fields;

  int get fieldCount => fields.length;

  int get readyFieldCount {
    return fields.where((field) => field.isReady).length;
  }

  int get requiredFieldCount {
    return fields.where((field) => field.required).length;
  }

  int get missingRequiredFieldCount {
    return fields.where((field) => field.isMissingRequired).length;
  }

  int get invalidFieldCount {
    return fields.where((field) => field.hasInvalidValue).length;
  }

  int get lockedFieldCount {
    return fields.where((field) => field.locked).length;
  }

  bool get hasLockedFields => lockedFieldCount > 0;
  bool get hasMissingRequiredFields => missingRequiredFieldCount > 0;
  bool get hasInvalidFields => invalidFieldCount > 0;
  bool get isReady => !hasMissingRequiredFields && !hasInvalidFields;

  List<ProductCoreInformationFieldProgress> get missingRequiredFields {
    return List.unmodifiable(fields.where((field) => field.isMissingRequired));
  }

  List<ProductCoreInformationFieldProgress> get invalidFields {
    return List.unmodifiable(fields.where((field) => field.hasInvalidValue));
  }

  ProductCoreInformationFieldProgress? get nextReviewField {
    if (invalidFields.isNotEmpty) return invalidFields.first;
    if (missingRequiredFields.isNotEmpty) return missingRequiredFields.first;

    return null;
  }

  String get fieldCountLabel => _countLabel(fieldCount, 'field');
  String get readyProgressLabel => '$readyFieldCount/$fieldCount ready';
  String get requiredFieldCountLabel {
    return _countLabel(requiredFieldCount, 'required field');
  }

  String get missingRequiredCountLabel {
    return _countLabel(missingRequiredFieldCount, 'missing', 'missing');
  }

  String get invalidFieldCountLabel {
    return _countLabel(invalidFieldCount, 'invalid', 'invalid');
  }

  String get lockedFieldCountLabel => _countLabel(lockedFieldCount, 'locked');

  String get readinessLabel {
    if (hasInvalidFields) return invalidFieldCountLabel;
    if (hasMissingRequiredFields) return missingRequiredCountLabel;

    return 'Ready';
  }

  String get nextReviewTitle {
    final field = nextReviewField;
    if (field == null) return 'Core information ready';
    if (field.hasInvalidValue) return '${field.label} needs correction';

    return '${field.label} is required';
  }

  String get nextReviewDescription {
    final field = nextReviewField;
    if (field == null) {
      return 'All core catalog, pricing, and stock handoff fields are ready.';
    }
    if (field.hasInvalidValue) {
      return '${field.label} needs a valid ${field.typeLabel.toLowerCase()} value before saving.';
    }

    return 'Complete ${field.label} before this product can be saved.';
  }

  String get nextReviewActionLabel {
    final field = nextReviewField;
    if (field == null) return 'Review';

    return 'Review ${field.label}';
  }
}

bool _isRequiredField(String fieldId, {required bool isEditing}) {
  return !(isEditing && fieldId == ProductCoreInformationFieldIds.initialStock);
}

bool _isLockedField(String fieldId, {required bool isEditing}) {
  return isEditing && fieldId == ProductCoreInformationFieldIds.initialStock;
}

String? _priceError(String value) {
  if (value.isEmpty) return 'Required';

  final price = double.tryParse(value);
  if (price == null || price < 0) return 'Invalid';

  return null;
}

String? _stockError(String value) {
  if (value.isEmpty) return 'Required';

  final stock = int.tryParse(value);
  if (stock == null || stock < 0) return 'Invalid';

  return null;
}

String _fieldLabel(String fieldId) {
  return switch (fieldId) {
    ProductCoreInformationFieldIds.name => 'Product Name',
    ProductCoreInformationFieldIds.sku => 'SKU',
    ProductCoreInformationFieldIds.category => 'Category',
    ProductCoreInformationFieldIds.price => 'Price',
    ProductCoreInformationFieldIds.initialStock => 'Initial Stock',
    ProductCoreInformationFieldIds.description => 'Description',
    _ => fieldId,
  };
}

String _fieldTypeLabel(String fieldId) {
  return switch (fieldId) {
    ProductCoreInformationFieldIds.price => 'Money',
    ProductCoreInformationFieldIds.initialStock => 'Number',
    ProductCoreInformationFieldIds.description => 'Long text',
    _ => 'Text',
  };
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
