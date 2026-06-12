import 'management_pack_field_group_progress.dart';
import 'product_form_section.dart';
import 'product_form_section_progress.dart';

/// Type of product editor section navigator row.
enum ProductEditorSectionNavigatorItemKind { formSection, packGroup }

/// Presentation state for one product editor section navigator row.
class ProductEditorSectionNavigatorItem {
  const ProductEditorSectionNavigatorItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.statusLabel,
    required this.kind,
    required this.isReady,
    required this.needsRequiredData,
    this.primaryAttribute,
    this.nextMissingAttribute,
    this.nextReviewAttribute,
  });

  final String id;
  final String title;
  final String subtitle;
  final String progressLabel;
  final String statusLabel;
  final ProductEditorSectionNavigatorItemKind kind;
  final bool isReady;
  final bool needsRequiredData;
  final ProductFormAttributeDefinition? primaryAttribute;
  final ProductFormMissingRequiredAttribute? nextMissingAttribute;
  final ProductFormMissingRequiredAttribute? nextReviewAttribute;

  bool get canLaunch => reviewAttribute != null || primaryAttribute != null;
  bool get canReview => reviewAttribute != null;

  ProductFormMissingRequiredAttribute? get reviewAttribute {
    return nextReviewAttribute ?? nextMissingAttribute;
  }

  String get actionLabel {
    if (canReview) return reviewLabel;

    return 'Open';
  }

  String get reviewLabel {
    final attribute = reviewAttribute;
    if (attribute == null) return 'Review';

    return 'Review ${attribute.label}';
  }
}

/// Presentation state for the product editor section navigator.
class ProductEditorSectionNavigatorViewState {
  ProductEditorSectionNavigatorViewState({
    required List<ProductEditorSectionNavigatorItem> items,
    required this.requiredMissingCount,
    required this.invalidFieldCount,
    required this.isReady,
  }) : items = List.unmodifiable(items);

  /// Builds navigator rows from form sections and management pack groups.
  factory ProductEditorSectionNavigatorViewState.from({
    required ProductFormSectionProgressOverview progress,
    required ProductManagementPackFieldGroupProgressOverview groupProgress,
  }) {
    final packSection = progress.overview.sections.firstWhere(
      (section) => section.id == ProductFormSectionId.packExtensions,
    );
    final packAttributesById = {
      for (final attribute in packSection.attributes) attribute.id: attribute,
    };
    final invalidFieldCount = _invalidFieldCountFor(groupProgress);

    return ProductEditorSectionNavigatorViewState(
      requiredMissingCount: progress.missingRequiredAttributeCount,
      invalidFieldCount: invalidFieldCount,
      isReady: progress.isReady && invalidFieldCount == 0,
      items: [
        for (final sectionProgress in progress.sections)
          if (sectionProgress.section.id != ProductFormSectionId.packExtensions)
            _formSectionItem(sectionProgress),
        for (final group in groupProgress.groups)
          _packGroupItem(
            groupProgress: group,
            packSection: packSection,
            packAttributesById: packAttributesById,
          ),
      ],
    );
  }

  final List<ProductEditorSectionNavigatorItem> items;
  final int requiredMissingCount;
  final int invalidFieldCount;
  final bool isReady;

  bool get hasItems => items.isNotEmpty;

  String get statusLabel {
    if (isReady) return 'All ready';
    if (invalidFieldCount > 0) {
      return _countLabel(invalidFieldCount, 'invalid', 'invalid');
    }

    return _countLabel(
      requiredMissingCount,
      'required missing',
      'required missing',
    );
  }
}

int _invalidFieldCountFor(
  ProductManagementPackFieldGroupProgressOverview groupProgress,
) {
  return groupProgress.groups.fold(
    0,
    (total, progress) => total + progress.invalidFieldCount,
  );
}

ProductEditorSectionNavigatorItem _formSectionItem(
  ProductFormSectionProgress progress,
) {
  final primaryAttribute =
      progress.missingRequiredAttributes.isEmpty
          ? progress.section.attributes.isEmpty
              ? null
              : progress.section.attributes.first
          : progress.missingRequiredAttributes.first.attribute;

  return ProductEditorSectionNavigatorItem(
    id: progress.section.id.name,
    title: progress.section.title,
    subtitle: progress.section.subtitle,
    progressLabel: progress.requiredProgressLabel,
    statusLabel: progress.readinessLabel,
    kind: ProductEditorSectionNavigatorItemKind.formSection,
    isReady: progress.readiness == ProductFormSectionReadiness.ready,
    needsRequiredData:
        progress.readiness == ProductFormSectionReadiness.needsRequired,
    primaryAttribute: primaryAttribute,
    nextMissingAttribute:
        progress.missingRequiredAttributes.isEmpty
            ? null
            : ProductFormMissingRequiredAttribute(
              section: progress.section,
              attribute: progress.missingRequiredAttributes.first.attribute,
            ),
  );
}

ProductEditorSectionNavigatorItem _packGroupItem({
  required ProductManagementPackFieldGroupProgress groupProgress,
  required ProductFormSectionDefinition packSection,
  required Map<String, ProductFormAttributeDefinition> packAttributesById,
}) {
  final missingField = groupProgress.nextMissingRequiredField;
  final missingAttribute =
      missingField == null
          ? null
          : packAttributesById[missingField.field.id.value];
  final reviewField = groupProgress.nextReviewField;
  final reviewAttribute =
      reviewField == null
          ? null
          : packAttributesById[reviewField.field.id.value];
  final primaryField =
      reviewField?.field ??
      (groupProgress.group.fields.isEmpty
          ? null
          : groupProgress.group.fields.first);
  final primaryAttribute =
      primaryField == null ? null : packAttributesById[primaryField.id.value];

  return ProductEditorSectionNavigatorItem(
    id: groupProgress.group.capability.name,
    title: groupProgress.group.title,
    subtitle: groupProgress.group.description,
    progressLabel:
        groupProgress.hasRequiredFields
            ? groupProgress.requiredProgressLabel
            : groupProgress.filledProgressLabel,
    statusLabel: groupProgress.readinessLabel,
    kind: ProductEditorSectionNavigatorItemKind.packGroup,
    isReady:
        groupProgress.readiness ==
        ProductManagementPackFieldGroupReadiness.ready,
    needsRequiredData:
        groupProgress.readiness ==
            ProductManagementPackFieldGroupReadiness.needsRequired ||
        groupProgress.readiness ==
            ProductManagementPackFieldGroupReadiness.invalid,
    primaryAttribute: primaryAttribute,
    nextMissingAttribute:
        missingAttribute == null
            ? null
            : ProductFormMissingRequiredAttribute(
              section: packSection,
              attribute: missingAttribute,
            ),
    nextReviewAttribute:
        reviewAttribute == null
            ? null
            : ProductFormMissingRequiredAttribute(
              section: packSection,
              attribute: reviewAttribute,
            ),
  );
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
