import 'product_form_section.dart';

/// Readiness state for a product form section.
enum ProductFormSectionReadiness { ready, needsRequired, optionalOnly }

/// Completion state for one product form attribute.
class ProductFormAttributeProgress {
  const ProductFormAttributeProgress({
    required this.attribute,
    required this.value,
  });

  final ProductFormAttributeDefinition attribute;
  final String value;

  bool get isFilled => value.trim().isNotEmpty;
  bool get isMissingRequired => attribute.required && !isFilled;
}

/// Missing required product attribute with its parent form section.
class ProductFormMissingRequiredAttribute {
  const ProductFormMissingRequiredAttribute({
    required this.section,
    required this.attribute,
  });

  final ProductFormSectionDefinition section;
  final ProductFormAttributeDefinition attribute;

  String get fieldId => attribute.id;
  String get label => attribute.label;
  String get sectionLabel => section.title;
  String get helperLabel => '${section.title} | ${attribute.typeLabel}';
}

/// Completion state for one product form section.
class ProductFormSectionProgress {
  ProductFormSectionProgress({
    required this.section,
    required List<ProductFormAttributeProgress> attributes,
  }) : attributes = List.unmodifiable(attributes);

  final ProductFormSectionDefinition section;
  final List<ProductFormAttributeProgress> attributes;

  int get filledAttributeCount {
    return attributes.where((attribute) => attribute.isFilled).length;
  }

  int get requiredAttributeCount => section.requiredAttributeCount;

  int get filledRequiredAttributeCount {
    return attributes
        .where(
          (attribute) => attribute.attribute.required && attribute.isFilled,
        )
        .length;
  }

  int get missingRequiredAttributeCount {
    return requiredAttributeCount - filledRequiredAttributeCount;
  }

  List<ProductFormAttributeProgress> get missingRequiredAttributes {
    return List.unmodifiable(
      attributes.where((attribute) => attribute.isMissingRequired),
    );
  }

  bool get hasRequiredAttributes => requiredAttributeCount > 0;
  bool get hasMissingRequiredAttributes => missingRequiredAttributeCount > 0;

  ProductFormSectionReadiness get readiness {
    if (!hasRequiredAttributes) return ProductFormSectionReadiness.optionalOnly;
    if (hasMissingRequiredAttributes) {
      return ProductFormSectionReadiness.needsRequired;
    }

    return ProductFormSectionReadiness.ready;
  }

  String get requiredProgressLabel {
    if (!hasRequiredAttributes) return 'Optional';

    return '$filledRequiredAttributeCount/$requiredAttributeCount required';
  }

  String get readinessLabel {
    return switch (readiness) {
      ProductFormSectionReadiness.ready => 'Ready',
      ProductFormSectionReadiness.needsRequired => _countLabel(
        missingRequiredAttributeCount,
        'missing required',
        'missing required',
      ),
      ProductFormSectionReadiness.optionalOnly => 'Optional',
    };
  }
}

/// Completion state across the whole product form section overview.
class ProductFormSectionProgressOverview {
  ProductFormSectionProgressOverview({
    required this.overview,
    required List<ProductFormSectionProgress> sections,
  }) : sections = List.unmodifiable(sections);

  final ProductFormSectionOverview overview;
  final List<ProductFormSectionProgress> sections;

  int get requiredAttributeCount => overview.requiredAttributeCount;

  int get filledRequiredAttributeCount {
    return sections.fold(
      0,
      (total, section) => total + section.filledRequiredAttributeCount,
    );
  }

  int get missingRequiredAttributeCount {
    return requiredAttributeCount - filledRequiredAttributeCount;
  }

  bool get hasMissingRequiredAttributes => missingRequiredAttributeCount > 0;
  bool get isReady => !hasMissingRequiredAttributes;

  List<ProductFormMissingRequiredAttribute> get missingRequiredAttributes {
    return List.unmodifiable([
      for (final section in sections)
        for (final attribute in section.missingRequiredAttributes)
          ProductFormMissingRequiredAttribute(
            section: section.section,
            attribute: attribute.attribute,
          ),
    ]);
  }

  ProductFormMissingRequiredAttribute? get nextMissingRequiredAttribute {
    final missingAttributes = missingRequiredAttributes;
    if (missingAttributes.isEmpty) return null;

    return missingAttributes.first;
  }

  String get requiredProgressLabel {
    if (requiredAttributeCount == 0) return 'No required fields';

    return '$filledRequiredAttributeCount/$requiredAttributeCount ready';
  }

  String get readinessLabel {
    if (isReady) return 'Ready to save';

    return _countLabel(
      missingRequiredAttributeCount,
      'required missing',
      'required missing',
    );
  }

  ProductFormSectionProgress progressFor(ProductFormSectionId sectionId) {
    return sections.firstWhere((section) => section.section.id == sectionId);
  }
}

/// Builds live form progress from the section overview and current values.
ProductFormSectionProgressOverview buildProductFormSectionProgressOverview({
  required ProductFormSectionOverview overview,
  required Map<String, String> values,
}) {
  return ProductFormSectionProgressOverview(
    overview: overview,
    sections: [
      for (final section in overview.sections)
        ProductFormSectionProgress(
          section: section,
          attributes: [
            for (final attribute in section.attributes)
              ProductFormAttributeProgress(
                attribute: attribute,
                value: values[attribute.id] ?? '',
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
