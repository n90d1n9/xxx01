import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack.dart';
import 'management_pack_field_input_metadata.dart';
import 'product_field_input_helper.dart';

/// Compact helper content for product management pack field inputs.
class ProductManagementPackFieldInputHelper extends StatelessWidget {
  const ProductManagementPackFieldInputHelper({
    super.key,
    required this.metadata,
    this.maxDescriptionLines = 2,
  });

  final ProductManagementPackFieldInputMetadata metadata;
  final int maxDescriptionLines;

  @override
  Widget build(BuildContext context) {
    return ProductFieldInputHelper(
      data: ProductFieldInputHelperData(
        description: metadata.helperText,
        requirementLabel: metadata.requirementLabel,
        requirementTone:
            metadata.field.required
                ? ProductFieldInputRequirementTone.required
                : ProductFieldInputRequirementTone.optional,
        typeLabel: metadata.typeLabel,
        typeIcon: _typeIcon,
        unitLabel: metadata.suffixText,
      ),
      maxDescriptionLines: maxDescriptionLines,
    );
  }

  IconData get _typeIcon {
    return switch (metadata.field.type) {
      ProductManagementFieldType.date => Icons.calendar_month_rounded,
      ProductManagementFieldType.number => Icons.pin_rounded,
      ProductManagementFieldType.select => Icons.arrow_drop_down_circle_rounded,
      ProductManagementFieldType.toggle => Icons.toggle_on_rounded,
      ProductManagementFieldType.text => Icons.short_text_rounded,
    };
  }
}

@Preview(name: 'Management pack field input helper')
Widget productManagementPackFieldInputHelperPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackFieldInputHelper(
          metadata: ProductManagementPackFieldInputMetadata.fromField(
            groceryFreshGoodsFields[3],
          ),
        ),
      ),
    ),
  );
}
