import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/widgets/management_pack_field_input_metadata.dart';

void main() {
  test('management pack field input metadata describes date fields', () {
    final metadata = ProductManagementPackFieldInputMetadata.fromField(
      groceryFreshGoodsFields.first,
    );

    expect(metadata.inputKey, const ValueKey('product-pack-field-expiry_date'));
    expect(metadata.icon, Icons.event_rounded);
    expect(metadata.typeLabel, 'Date');
    expect(metadata.requirementLabel, 'Required');
    expect(metadata.keyboardType, TextInputType.datetime);
    expect(metadata.textInputAction, TextInputAction.next);
    expect(
      metadata.helperText,
      'Date used to protect fresh goods from expired selling.',
    );
    expect(metadata.hintText, 'YYYY-MM-DD');
    expect(metadata.suffixText, isNull);
    expect(metadata.isControllerBacked, isTrue);
    expect(metadata.supportsDatePicker, isTrue);
    expect(metadata.supportsNumberStepper, isFalse);
  });

  test('management pack field input metadata describes number fields', () {
    final metadata = ProductManagementPackFieldInputMetadata.fromField(
      groceryFreshGoodsFields[3],
    );

    expect(
      metadata.inputKey,
      const ValueKey('product-pack-field-shelf_life_days'),
    );
    expect(metadata.icon, Icons.timer_rounded);
    expect(metadata.typeLabel, 'Number');
    expect(metadata.requirementLabel, 'Optional');
    expect(
      metadata.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );
    expect(metadata.textInputAction, TextInputAction.next);
    expect(metadata.hintText, '0');
    expect(metadata.suffixText, 'days');
    expect(metadata.isControllerBacked, isTrue);
    expect(metadata.supportsDatePicker, isFalse);
    expect(metadata.supportsNumberStepper, isTrue);
  });

  test('management pack field input metadata describes toggle fields', () {
    final metadata = ProductManagementPackFieldInputMetadata.fromField(
      groceryFreshGoodsFields[2],
    );

    expect(
      metadata.inputKey,
      const ValueKey('product-pack-field-weighted_unit'),
    );
    expect(metadata.icon, Icons.scale_rounded);
    expect(metadata.typeLabel, 'Toggle');
    expect(metadata.requirementLabel, 'Optional');
    expect(metadata.keyboardType, TextInputType.text);
    expect(metadata.textInputAction, TextInputAction.done);
    expect(metadata.hintText, isNull);
    expect(metadata.isControllerBacked, isFalse);
    expect(metadata.supportsDatePicker, isFalse);
    expect(metadata.supportsNumberStepper, isFalse);
  });
}
