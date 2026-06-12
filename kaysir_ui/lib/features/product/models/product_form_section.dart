import 'management_pack.dart';

/// Stable section identifiers used by the product editor form overview.
enum ProductFormSectionId { identity, commercial, packExtensions }

/// Product attribute shown in a reusable product editor form section.
class ProductFormAttributeDefinition {
  const ProductFormAttributeDefinition({
    required this.id,
    required this.label,
    required this.description,
    required this.typeLabel,
    required this.required,
    required this.sourceLabel,
  });

  factory ProductFormAttributeDefinition.fromPackField(
    ProductManagementPackField field, {
    required String sourceLabel,
  }) {
    return ProductFormAttributeDefinition(
      id: field.id.value,
      label: field.label,
      description: field.description,
      typeLabel: productManagementFieldTypeLabel(field.type),
      required: field.required,
      sourceLabel: sourceLabel,
    );
  }

  final String id;
  final String label;
  final String description;
  final String typeLabel;
  final bool required;
  final String sourceLabel;

  String get requirementLabel => required ? 'Required' : 'Optional';
}

/// Logical group of product attributes shown in the editor setup overview.
class ProductFormSectionDefinition {
  ProductFormSectionDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required List<ProductFormAttributeDefinition> attributes,
  }) : attributes = List.unmodifiable(attributes);

  final ProductFormSectionId id;
  final String title;
  final String subtitle;
  final List<ProductFormAttributeDefinition> attributes;

  bool get hasAttributes => attributes.isNotEmpty;
  int get attributeCount => attributes.length;
  int get requiredAttributeCount {
    return attributes.where((attribute) => attribute.required).length;
  }

  String get attributeCountLabel => _countLabel(attributeCount, 'field');

  String get requiredAttributeCountLabel {
    return _countLabel(requiredAttributeCount, 'required field');
  }
}

/// Product editor setup overview derived from the active management pack.
class ProductFormSectionOverview {
  ProductFormSectionOverview({
    required this.pack,
    required List<ProductFormSectionDefinition> sections,
  }) : sections = List.unmodifiable(sections);

  final ProductManagementPack pack;
  final List<ProductFormSectionDefinition> sections;

  bool get hasSections => sections.isNotEmpty;
  int get sectionCount => sections.length;
  int get attributeCount {
    return sections.fold(0, (total, section) => total + section.attributeCount);
  }

  int get requiredAttributeCount {
    return sections.fold(
      0,
      (total, section) => total + section.requiredAttributeCount,
    );
  }

  String get attributeCountLabel => _countLabel(attributeCount, 'field');

  String get requiredAttributeCountLabel {
    return _countLabel(requiredAttributeCount, 'required field');
  }
}

/// Builds the section overview for the product editor and active pack.
ProductFormSectionOverview buildProductFormSectionOverview({
  required ProductManagementPack pack,
  required bool isEditing,
}) {
  return ProductFormSectionOverview(
    pack: pack,
    sections: [
      ProductFormSectionDefinition(
        id: ProductFormSectionId.identity,
        title: 'Identity',
        subtitle: 'Searchable catalog identity and product copy',
        attributes: const [
          ProductFormAttributeDefinition(
            id: 'name',
            label: 'Product Name',
            description: 'Customer-facing name used across product surfaces.',
            typeLabel: 'Text',
            required: true,
            sourceLabel: 'Core',
          ),
          ProductFormAttributeDefinition(
            id: 'sku',
            label: 'SKU',
            description: 'Internal catalog identifier used for lookup.',
            typeLabel: 'Text',
            required: true,
            sourceLabel: 'Core',
          ),
          ProductFormAttributeDefinition(
            id: 'category',
            label: 'Category',
            description: 'Grouping used for browsing, reporting, and filters.',
            typeLabel: 'Text',
            required: true,
            sourceLabel: 'Core',
          ),
          ProductFormAttributeDefinition(
            id: 'description',
            label: 'Description',
            description: 'Short product copy used by catalog and channels.',
            typeLabel: 'Long text',
            required: true,
            sourceLabel: 'Core',
          ),
        ],
      ),
      ProductFormSectionDefinition(
        id: ProductFormSectionId.commercial,
        title: 'Commercial',
        subtitle: 'Pricing and opening stock data for selling',
        attributes: [
          const ProductFormAttributeDefinition(
            id: 'price',
            label: 'Price',
            description: 'Base selling price used by POS and catalog.',
            typeLabel: 'Money',
            required: true,
            sourceLabel: 'Core',
          ),
          ProductFormAttributeDefinition(
            id: 'initial_stock',
            label: 'Initial Stock',
            description:
                isEditing
                    ? 'Locked after creation and managed through stock moves.'
                    : 'Opening quantity used to create the first stock move.',
            typeLabel: 'Number',
            required: !isEditing,
            sourceLabel: 'Inventory',
          ),
        ],
      ),
      ProductFormSectionDefinition(
        id: ProductFormSectionId.packExtensions,
        title: 'Pack extensions',
        subtitle: '${pack.title} attributes and operational controls',
        attributes: [
          for (final field in productManagementPackEditableFields(pack))
            ProductFormAttributeDefinition.fromPackField(
              field,
              sourceLabel: pack.title,
            ),
        ],
      ),
    ],
  );
}

/// Fields contributed by a management pack, excluding fixed base form fields.
List<ProductManagementPackField> productManagementPackEditableFields(
  ProductManagementPack pack,
) {
  return List.unmodifiable(
    pack.fields.where(
      (field) => !fixedProductManagementFormFieldIds.contains(field.id),
    ),
  );
}

/// Field IDs rendered by the base product editor instead of pack extensions.
final fixedProductManagementFormFieldIds = {
  ProductManagementFieldId.sku,
  ProductManagementFieldId.category,
};

String productManagementFieldTypeLabel(ProductManagementFieldType type) {
  return switch (type) {
    ProductManagementFieldType.text => 'Text',
    ProductManagementFieldType.number => 'Number',
    ProductManagementFieldType.date => 'Date',
    ProductManagementFieldType.toggle => 'Toggle',
    ProductManagementFieldType.select => 'Select',
  };
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
