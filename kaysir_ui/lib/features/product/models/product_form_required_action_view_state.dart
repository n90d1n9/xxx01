import 'product_form_section_progress.dart';

/// Visible-window state for the product form required-field guide.
class ProductFormRequiredActionViewState {
  ProductFormRequiredActionViewState({
    required List<ProductFormMissingRequiredAttribute> missingAttributes,
    required int maxVisibleAttributes,
    required this.expanded,
  }) : missingAttributes = List.unmodifiable(missingAttributes),
       maxVisibleAttributes =
           maxVisibleAttributes < 1 ? 1 : maxVisibleAttributes;

  factory ProductFormRequiredActionViewState.fromProgress({
    required ProductFormSectionProgressOverview progress,
    required int maxVisibleAttributes,
    required bool expanded,
  }) {
    return ProductFormRequiredActionViewState(
      missingAttributes: progress.missingRequiredAttributes,
      maxVisibleAttributes: maxVisibleAttributes,
      expanded: expanded,
    );
  }

  final List<ProductFormMissingRequiredAttribute> missingAttributes;
  final int maxVisibleAttributes;
  final bool expanded;

  bool get hasMissingAttributes => missingAttributes.isNotEmpty;

  ProductFormMissingRequiredAttribute? get nextAttribute {
    if (missingAttributes.isEmpty) return null;

    return missingAttributes.first;
  }

  List<ProductFormMissingRequiredAttribute> get additionalAttributes {
    if (missingAttributes.length <= 1) return const [];

    return List.unmodifiable(missingAttributes.skip(1));
  }

  int get collapsedAdditionalAttributeLimit => maxVisibleAttributes - 1;

  List<ProductFormMissingRequiredAttribute> get visibleAdditionalAttributes {
    final additional = additionalAttributes;
    if (expanded) return additional;

    return List.unmodifiable(
      additional.take(collapsedAdditionalAttributeLimit),
    );
  }

  int get hiddenAdditionalAttributeCount {
    return additionalAttributes.length - visibleAdditionalAttributes.length;
  }

  bool get canExpand {
    return !expanded && hiddenAdditionalAttributeCount > 0;
  }

  bool get canCollapse {
    return expanded &&
        additionalAttributes.length > collapsedAdditionalAttributeLimit;
  }

  bool get canToggleAdditionalAttributes => canExpand || canCollapse;

  String get additionalToggleLabel {
    if (expanded) return 'Show less';

    return 'Show $hiddenAdditionalAttributeCount more';
  }
}
