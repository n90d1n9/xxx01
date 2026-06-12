import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/product_core_information_field_ids.dart';
import 'product_core_information_field_metadata.dart';
import 'product_field_input_helper.dart';

/// Helper content for core product information inputs.
class ProductCoreInformationFieldHelper extends StatelessWidget {
  const ProductCoreInformationFieldHelper({
    super.key,
    required this.metadata,
    this.maxDescriptionLines = 2,
  });

  final ProductCoreInformationFieldMetadata metadata;
  final int maxDescriptionLines;

  @override
  Widget build(BuildContext context) {
    return ProductFieldInputHelper(
      data: metadata.helperData,
      maxDescriptionLines: maxDescriptionLines,
    );
  }
}

@Preview(name: 'Product core information field helper')
Widget productCoreInformationFieldHelperPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductCoreInformationFieldHelper(
          metadata: ProductCoreInformationFieldMetadata.forField(
            ProductCoreInformationFieldIds.initialStock,
            isEditing: true,
          ),
        ),
      ),
    ),
  );
}
