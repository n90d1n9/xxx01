import 'management_pack_field_group_progress.dart';
import 'product_form_section.dart';
import 'product_form_section_progress.dart';

/// Severity of a product form issue blocking or delaying save readiness.
enum ProductFormSaveReviewIssueSeverity { invalid, missingRequired }

/// One reviewable issue shown in the product form save queue.
class ProductFormSaveReviewIssue {
  const ProductFormSaveReviewIssue({
    required this.attribute,
    required this.severity,
  });

  final ProductFormMissingRequiredAttribute attribute;
  final ProductFormSaveReviewIssueSeverity severity;

  String get label => '$statusLabel ${attribute.label}';

  String get statusLabel {
    return switch (severity) {
      ProductFormSaveReviewIssueSeverity.invalid => 'Invalid',
      ProductFormSaveReviewIssueSeverity.missingRequired => 'Missing',
    };
  }

  String get tooltip {
    return '$statusLabel ${attribute.label} in ${attribute.sectionLabel}';
  }
}

/// Presentation-ready save action state derived from product form progress.
class ProductFormSaveActionSummary {
  ProductFormSaveActionSummary({
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.submitLabel,
    required this.isReady,
    required this.filledRequiredAttributeCount,
    required this.requiredAttributeCount,
    this.nextMissingAttribute,
    this.nextInvalidAttribute,
    this.invalidAttributeCount = 0,
    List<ProductFormSaveReviewIssue> reviewIssues = const [],
  }) : reviewIssues = List.unmodifiable(reviewIssues);

  final String title;
  final String description;
  final String statusLabel;
  final String submitLabel;
  final bool isReady;
  final int filledRequiredAttributeCount;
  final int requiredAttributeCount;
  final ProductFormMissingRequiredAttribute? nextMissingAttribute;
  final ProductFormMissingRequiredAttribute? nextInvalidAttribute;
  final int invalidAttributeCount;
  final List<ProductFormSaveReviewIssue> reviewIssues;

  bool get canReviewNext => nextReviewAttribute != null;
  bool get hasRequiredAttributes => requiredAttributeCount > 0;
  bool get hasInvalidAttributes => invalidAttributeCount > 0;
  bool get hasReviewIssues => reviewIssues.isNotEmpty;

  ProductFormMissingRequiredAttribute? get nextReviewAttribute {
    if (reviewIssues.isNotEmpty) return reviewIssues.first.attribute;

    return nextInvalidAttribute ?? nextMissingAttribute;
  }

  double get readinessFraction {
    if (!hasRequiredAttributes) return 1;

    final fraction = filledRequiredAttributeCount / requiredAttributeCount;
    return fraction.clamp(0, 1).toDouble();
  }

  String get readinessPercentLabel {
    if (hasInvalidAttributes) return 'Needs review';

    return '${(readinessFraction * 100).round()}% ready';
  }

  String get requiredReadinessCountLabel {
    if (!hasRequiredAttributes) return 'No required fields';

    return '$filledRequiredAttributeCount/$requiredAttributeCount required';
  }

  String get reviewNextLabel {
    final attribute = nextReviewAttribute;
    if (attribute == null) return 'Review required fields';

    return 'Review ${attribute.label}';
  }
}

/// Builds the save action summary for the current product editor state.
ProductFormSaveActionSummary buildProductFormSaveActionSummary({
  required ProductFormSectionProgressOverview progress,
  required String submitLabel,
  required bool isEditing,
  ProductManagementPackFieldGroupProgressOverview? groupProgress,
}) {
  final nextMissingAttribute = progress.nextMissingRequiredAttribute;
  final invalidIssues = _invalidIssuesFor(
    progress: progress,
    groupProgress: groupProgress,
  );
  final missingIssues = _missingRequiredIssuesFor(progress);
  final invalidAttributeCount = invalidIssues.length;
  final nextInvalidAttribute =
      invalidIssues.isEmpty ? null : invalidIssues.first.attribute;
  final reviewIssues = [...invalidIssues, ...missingIssues];

  if (invalidAttributeCount > 0) {
    return ProductFormSaveActionSummary(
      title: 'Review product data',
      description:
          nextInvalidAttribute == null
              ? 'Fix invalid product data before saving.'
              : 'Fix ${nextInvalidAttribute.label} in '
                  '${nextInvalidAttribute.sectionLabel} before saving.',
      statusLabel: _countLabel(invalidAttributeCount, 'invalid', 'invalid'),
      submitLabel: submitLabel,
      isReady: false,
      filledRequiredAttributeCount: progress.filledRequiredAttributeCount,
      requiredAttributeCount: progress.requiredAttributeCount,
      nextMissingAttribute: nextMissingAttribute,
      nextInvalidAttribute: nextInvalidAttribute,
      invalidAttributeCount: invalidAttributeCount,
      reviewIssues: reviewIssues,
    );
  }

  if (progress.isReady) {
    return ProductFormSaveActionSummary(
      title: isEditing ? 'Ready to update product' : 'Ready to add product',
      description: 'All required product data is complete.',
      statusLabel: progress.requiredProgressLabel,
      submitLabel: submitLabel,
      isReady: true,
      filledRequiredAttributeCount: progress.filledRequiredAttributeCount,
      requiredAttributeCount: progress.requiredAttributeCount,
    );
  }

  return ProductFormSaveActionSummary(
    title: 'Product still needs required data',
    description:
        nextMissingAttribute == null
            ? 'Complete required product data before saving.'
            : 'Complete ${nextMissingAttribute.label} in '
                '${nextMissingAttribute.sectionLabel} before saving.',
    statusLabel: progress.requiredProgressLabel,
    submitLabel: submitLabel,
    isReady: false,
    filledRequiredAttributeCount: progress.filledRequiredAttributeCount,
    requiredAttributeCount: progress.requiredAttributeCount,
    nextMissingAttribute: nextMissingAttribute,
    reviewIssues: reviewIssues,
  );
}

List<ProductFormSaveReviewIssue> _invalidIssuesFor({
  required ProductFormSectionProgressOverview progress,
  required ProductManagementPackFieldGroupProgressOverview? groupProgress,
}) {
  if (groupProgress == null) return const [];

  final packSection = progress.overview.sections.firstWhere(
    (section) => section.id == ProductFormSectionId.packExtensions,
  );
  final packAttributesById = {
    for (final attribute in packSection.attributes) attribute.id: attribute,
  };
  final issues = <ProductFormSaveReviewIssue>[];

  for (final group in groupProgress.groups) {
    for (final invalidField in group.invalidFields) {
      final attribute = packAttributesById[invalidField.field.id.value];
      if (attribute == null) continue;

      issues.add(
        ProductFormSaveReviewIssue(
          severity: ProductFormSaveReviewIssueSeverity.invalid,
          attribute: ProductFormMissingRequiredAttribute(
            section: packSection,
            attribute: attribute,
          ),
        ),
      );
    }
  }

  return List.unmodifiable(issues);
}

List<ProductFormSaveReviewIssue> _missingRequiredIssuesFor(
  ProductFormSectionProgressOverview progress,
) {
  return List.unmodifiable([
    for (final attribute in progress.missingRequiredAttributes)
      ProductFormSaveReviewIssue(
        severity: ProductFormSaveReviewIssueSeverity.missingRequired,
        attribute: attribute,
      ),
  ]);
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
