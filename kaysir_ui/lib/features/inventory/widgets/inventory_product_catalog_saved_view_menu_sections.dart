import '../models/inventory_product_catalog_saved_view.dart';
import 'inventory_product_catalog_saved_view_types.dart';

/// Group of saved product catalog views rendered under one menu heading.
class InventoryProductCatalogSavedViewMenuSection {
  InventoryProductCatalogSavedViewMenuSection({required this.label});

  final String? label;
  final views = <InventoryProductCatalogSavedView>[];
}

List<InventoryProductCatalogSavedViewMenuSection>
inventoryProductCatalogSavedViewMenuSections(
  Iterable<InventoryProductCatalogSavedView> savedViews,
  InventoryProductCatalogSavedViewSectionLabel? sectionLabel,
) {
  if (sectionLabel == null) {
    final section = InventoryProductCatalogSavedViewMenuSection(label: null);
    section.views.addAll(savedViews);
    return [section];
  }

  final sections = <InventoryProductCatalogSavedViewMenuSection>[];
  for (final view in savedViews) {
    final label = sectionLabel(view)?.trim();
    final normalizedLabel = label == null || label.isEmpty ? null : label;
    var section = _matchingSavedViewMenuSection(sections, normalizedLabel);
    if (section == null) {
      section = InventoryProductCatalogSavedViewMenuSection(
        label: normalizedLabel,
      );
      sections.add(section);
    }
    section.views.add(view);
  }

  return sections;
}

bool inventoryProductCatalogSavedViewCanRunAction(
  InventoryProductCatalogSavedViewActionPredicate? predicate,
  InventoryProductCatalogSavedView view,
) {
  return predicate?.call(view) ?? true;
}

String inventoryProductCatalogSavedViewMenuKeyPart(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
}

InventoryProductCatalogSavedViewMenuSection? _matchingSavedViewMenuSection(
  Iterable<InventoryProductCatalogSavedViewMenuSection> sections,
  String? label,
) {
  for (final section in sections) {
    if (section.label == label) return section;
  }

  return null;
}
