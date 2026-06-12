import 'package:flutter/material.dart';

import '../models/product_core_information_field_ids.dart';
import 'product_field_input_helper.dart';

/// Presentation metadata for one core product information input.
class ProductCoreInformationFieldMetadata {
  const ProductCoreInformationFieldMetadata({
    required this.fieldId,
    required this.label,
    required this.description,
    required this.icon,
    required this.typeLabel,
    required this.requirementLabel,
    required this.requirementTone,
    required this.keyboardType,
  });

  factory ProductCoreInformationFieldMetadata.forField(
    String fieldId, {
    required bool isEditing,
  }) {
    return switch (fieldId) {
      ProductCoreInformationFieldIds.name =>
        const ProductCoreInformationFieldMetadata(
          fieldId: ProductCoreInformationFieldIds.name,
          label: 'Product Name',
          description: 'Customer-facing name used across product surfaces.',
          icon: Icons.inventory_2_rounded,
          typeLabel: 'Text',
          requirementLabel: 'Required',
          requirementTone: ProductFieldInputRequirementTone.required,
          keyboardType: TextInputType.text,
        ),
      ProductCoreInformationFieldIds.sku =>
        const ProductCoreInformationFieldMetadata(
          fieldId: ProductCoreInformationFieldIds.sku,
          label: 'SKU',
          description: 'Internal catalog identifier used for lookup.',
          icon: Icons.qr_code_rounded,
          typeLabel: 'Text',
          requirementLabel: 'Required',
          requirementTone: ProductFieldInputRequirementTone.required,
          keyboardType: TextInputType.text,
        ),
      ProductCoreInformationFieldIds.category =>
        const ProductCoreInformationFieldMetadata(
          fieldId: ProductCoreInformationFieldIds.category,
          label: 'Category',
          description: 'Grouping used for browsing, reporting, and filters.',
          icon: Icons.category_rounded,
          typeLabel: 'Text',
          requirementLabel: 'Required',
          requirementTone: ProductFieldInputRequirementTone.required,
          keyboardType: TextInputType.text,
        ),
      ProductCoreInformationFieldIds.price =>
        const ProductCoreInformationFieldMetadata(
          fieldId: ProductCoreInformationFieldIds.price,
          label: 'Price',
          description: 'Base selling price used by POS and catalog.',
          icon: Icons.payments_rounded,
          typeLabel: 'Money',
          requirementLabel: 'Required',
          requirementTone: ProductFieldInputRequirementTone.required,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ProductCoreInformationFieldIds.initialStock =>
        ProductCoreInformationFieldMetadata._initialStock(isEditing),
      ProductCoreInformationFieldIds.description =>
        const ProductCoreInformationFieldMetadata(
          fieldId: ProductCoreInformationFieldIds.description,
          label: 'Description',
          description: 'Short product copy used by catalog and channels.',
          icon: Icons.description_rounded,
          typeLabel: 'Long text',
          requirementLabel: 'Required',
          requirementTone: ProductFieldInputRequirementTone.required,
          keyboardType: TextInputType.multiline,
        ),
      _ => throw ArgumentError.value(fieldId, 'fieldId', 'Unknown core field'),
    };
  }

  factory ProductCoreInformationFieldMetadata._initialStock(bool isEditing) {
    if (isEditing) {
      return const ProductCoreInformationFieldMetadata(
        fieldId: ProductCoreInformationFieldIds.initialStock,
        label: 'Initial Stock',
        description:
            'Locked after creation and managed through inventory movements.',
        icon: Icons.inventory_rounded,
        typeLabel: 'Number',
        requirementLabel: 'Locked',
        requirementTone: ProductFieldInputRequirementTone.locked,
        keyboardType: TextInputType.number,
      );
    }

    return const ProductCoreInformationFieldMetadata(
      fieldId: ProductCoreInformationFieldIds.initialStock,
      label: 'Initial Stock',
      description: 'Opening quantity used to create the first stock movement.',
      icon: Icons.inventory_rounded,
      typeLabel: 'Number',
      requirementLabel: 'Required',
      requirementTone: ProductFieldInputRequirementTone.required,
      keyboardType: TextInputType.number,
    );
  }

  final String fieldId;
  final String label;
  final String description;
  final IconData icon;
  final String typeLabel;
  final String requirementLabel;
  final ProductFieldInputRequirementTone requirementTone;
  final TextInputType keyboardType;

  ProductFieldInputHelperData get helperData {
    return ProductFieldInputHelperData(
      description: description,
      requirementLabel: requirementLabel,
      requirementTone: requirementTone,
      typeLabel: typeLabel,
      typeIcon: _typeIcon,
    );
  }

  IconData get _typeIcon {
    return switch (typeLabel) {
      'Money' => Icons.payments_rounded,
      'Number' => Icons.pin_rounded,
      'Long text' => Icons.notes_rounded,
      _ => Icons.short_text_rounded,
    };
  }
}
