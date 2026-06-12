import 'management_pack.dart';
import 'management_pack_field_group.dart';
import 'management_pack_field_validation.dart';

/// Readiness state for a capability-based management pack field group.
enum ProductManagementPackFieldGroupReadiness {
  invalid,
  ready,
  needsRequired,
  optionalOnly,
}

/// Completion state for one management pack field.
class ProductManagementPackFieldProgress {
  const ProductManagementPackFieldProgress({
    required this.field,
    required this.value,
  });

  final ProductManagementPackField field;
  final String value;

  String get trimmedValue => value.trim();
  bool get isFilled => trimmedValue.isNotEmpty;
  bool get isMissingRequired => field.required && !isFilled;
  bool get hasInvalidValue => isFilled && validationError != null;

  String? get validationError {
    return validateProductManagementPackFieldInput(field, value);
  }
}

/// Live completion state for one capability-based management pack field group.
class ProductManagementPackFieldGroupProgress {
  ProductManagementPackFieldGroupProgress({
    required this.group,
    required List<ProductManagementPackFieldProgress> fields,
  }) : fields = List.unmodifiable(fields);

  final ProductManagementPackFieldGroup group;
  final List<ProductManagementPackFieldProgress> fields;

  int get filledFieldCount {
    return fields.where((field) => field.isFilled).length;
  }

  int get requiredFieldCount => group.requiredFieldCount;

  int get filledRequiredFieldCount {
    return fields
        .where((field) => field.field.required && field.isFilled)
        .length;
  }

  int get missingRequiredFieldCount {
    return requiredFieldCount - filledRequiredFieldCount;
  }

  int get invalidFieldCount {
    return fields.where((field) => field.hasInvalidValue).length;
  }

  bool get hasRequiredFields => requiredFieldCount > 0;
  bool get hasMissingRequiredFields => missingRequiredFieldCount > 0;
  bool get hasInvalidFields => invalidFieldCount > 0;

  ProductManagementPackFieldGroupReadiness get readiness {
    if (hasInvalidFields) {
      return ProductManagementPackFieldGroupReadiness.invalid;
    }
    if (!hasRequiredFields) {
      return ProductManagementPackFieldGroupReadiness.optionalOnly;
    }
    if (hasMissingRequiredFields) {
      return ProductManagementPackFieldGroupReadiness.needsRequired;
    }

    return ProductManagementPackFieldGroupReadiness.ready;
  }

  String get filledProgressLabel {
    return '$filledFieldCount/${group.fieldCount} filled';
  }

  String get requiredProgressLabel {
    if (!hasRequiredFields) return 'Optional';

    return '$filledRequiredFieldCount/$requiredFieldCount required';
  }

  String get readinessLabel {
    return switch (readiness) {
      ProductManagementPackFieldGroupReadiness.invalid => _countLabel(
        invalidFieldCount,
        'invalid',
        'invalid',
      ),
      ProductManagementPackFieldGroupReadiness.ready => 'Ready',
      ProductManagementPackFieldGroupReadiness.needsRequired => _countLabel(
        missingRequiredFieldCount,
        'missing required',
        'missing required',
      ),
      ProductManagementPackFieldGroupReadiness.optionalOnly => 'Optional',
    };
  }

  List<ProductManagementPackFieldProgress> get missingRequiredFields {
    return List.unmodifiable(fields.where((field) => field.isMissingRequired));
  }

  List<ProductManagementPackFieldProgress> get invalidFields {
    return List.unmodifiable(fields.where((field) => field.hasInvalidValue));
  }

  ProductManagementPackFieldProgress? get nextMissingRequiredField {
    final missingFields = missingRequiredFields;
    if (missingFields.isEmpty) return null;

    return missingFields.first;
  }

  ProductManagementPackFieldProgress? get nextInvalidField {
    final invalidFields = this.invalidFields;
    if (invalidFields.isEmpty) return null;

    return invalidFields.first;
  }

  ProductManagementPackFieldProgress? get nextReviewField {
    return nextInvalidField ?? nextMissingRequiredField;
  }

  String get reviewNextLabel {
    final field = nextReviewField;
    if (field == null) return 'Review fields';

    return 'Review ${field.field.label}';
  }
}

/// Live completion state for all management pack field groups.
class ProductManagementPackFieldGroupProgressOverview {
  ProductManagementPackFieldGroupProgressOverview({
    required List<ProductManagementPackFieldGroupProgress> groups,
  }) : groups = List.unmodifiable(groups);

  final List<ProductManagementPackFieldGroupProgress> groups;

  ProductManagementPackFieldGroupProgress progressFor(
    ProductManagementCapability capability,
  ) {
    return groups.firstWhere((group) => group.group.capability == capability);
  }
}

/// Builds live progress for management pack field groups from current values.
ProductManagementPackFieldGroupProgressOverview
buildProductManagementPackFieldGroupProgressOverview({
  required List<ProductManagementPackFieldGroup> groups,
  required Map<String, String> values,
}) {
  return ProductManagementPackFieldGroupProgressOverview(
    groups: [
      for (final group in groups)
        ProductManagementPackFieldGroupProgress(
          group: group,
          fields: [
            for (final field in group.fields)
              ProductManagementPackFieldProgress(
                field: field,
                value: values[field.id.value] ?? '',
              ),
          ],
        ),
    ],
  );
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
