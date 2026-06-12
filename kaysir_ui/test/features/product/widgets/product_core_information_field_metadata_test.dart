import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_core_information_field_ids.dart';
import 'package:kaysir/features/product/widgets/product_core_information_field_metadata.dart';
import 'package:kaysir/features/product/widgets/product_field_input_helper.dart';

void main() {
  test('core information metadata describes price fields', () {
    final metadata = ProductCoreInformationFieldMetadata.forField(
      ProductCoreInformationFieldIds.price,
      isEditing: false,
    );

    expect(metadata.label, 'Price');
    expect(metadata.description, 'Base selling price used by POS and catalog.');
    expect(metadata.typeLabel, 'Money');
    expect(metadata.requirementLabel, 'Required');
    expect(metadata.requirementTone, ProductFieldInputRequirementTone.required);
    expect(
      metadata.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );
    expect(metadata.helperData.typeLabel, 'Money');
  });

  test('core information metadata describes locked stock while editing', () {
    final metadata = ProductCoreInformationFieldMetadata.forField(
      ProductCoreInformationFieldIds.initialStock,
      isEditing: true,
    );

    expect(metadata.label, 'Initial Stock');
    expect(
      metadata.description,
      'Locked after creation and managed through inventory movements.',
    );
    expect(metadata.typeLabel, 'Number');
    expect(metadata.requirementLabel, 'Locked');
    expect(metadata.requirementTone, ProductFieldInputRequirementTone.locked);
    expect(metadata.keyboardType, TextInputType.number);
  });
}
