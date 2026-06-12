import 'package:flutter/material.dart';

import '../models/management_pack.dart';

/// Presentation metadata used by management pack field input widgets.
class ProductManagementPackFieldInputMetadata {
  const ProductManagementPackFieldInputMetadata({
    required this.field,
    required this.inputKey,
    required this.icon,
    required this.typeLabel,
    required this.requirementLabel,
    required this.keyboardType,
    required this.textInputAction,
    required this.helperText,
    required this.hintText,
    required this.suffixText,
    required this.isControllerBacked,
    required this.supportsDatePicker,
    required this.supportsNumberStepper,
  });

  factory ProductManagementPackFieldInputMetadata.fromField(
    ProductManagementPackField field,
  ) {
    return ProductManagementPackFieldInputMetadata(
      field: field,
      inputKey: ValueKey('product-pack-field-${field.id.value}'),
      icon: _fieldIcon(field),
      typeLabel: _typeLabel(field.type),
      requirementLabel: field.requirementLabel,
      keyboardType: _keyboardType(field.type),
      textInputAction: _textInputAction(field.type),
      helperText: field.description,
      hintText: _hintText(field.type),
      suffixText: field.unitLabel,
      isControllerBacked: field.type != ProductManagementFieldType.toggle,
      supportsDatePicker: field.type == ProductManagementFieldType.date,
      supportsNumberStepper: field.type == ProductManagementFieldType.number,
    );
  }

  final ProductManagementPackField field;
  final Key inputKey;
  final IconData icon;
  final String typeLabel;
  final String requirementLabel;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String helperText;
  final String? hintText;
  final String? suffixText;
  final bool isControllerBacked;
  final bool supportsDatePicker;
  final bool supportsNumberStepper;
}

String _typeLabel(ProductManagementFieldType type) {
  return switch (type) {
    ProductManagementFieldType.text => 'Text',
    ProductManagementFieldType.number => 'Number',
    ProductManagementFieldType.date => 'Date',
    ProductManagementFieldType.toggle => 'Toggle',
    ProductManagementFieldType.select => 'Select',
  };
}

TextInputType _keyboardType(ProductManagementFieldType type) {
  switch (type) {
    case ProductManagementFieldType.number:
      return const TextInputType.numberWithOptions(decimal: true);
    case ProductManagementFieldType.date:
      return TextInputType.datetime;
    case ProductManagementFieldType.text:
    case ProductManagementFieldType.toggle:
    case ProductManagementFieldType.select:
      return TextInputType.text;
  }
}

TextInputAction _textInputAction(ProductManagementFieldType type) {
  return switch (type) {
    ProductManagementFieldType.date ||
    ProductManagementFieldType.number ||
    ProductManagementFieldType.text => TextInputAction.next,
    ProductManagementFieldType.toggle ||
    ProductManagementFieldType.select => TextInputAction.done,
  };
}

String? _hintText(ProductManagementFieldType type) {
  return switch (type) {
    ProductManagementFieldType.date => 'YYYY-MM-DD',
    ProductManagementFieldType.number => '0',
    ProductManagementFieldType.text ||
    ProductManagementFieldType.toggle ||
    ProductManagementFieldType.select => null,
  };
}

IconData _fieldIcon(ProductManagementPackField field) {
  switch (field.id.value) {
    case 'barcode':
      return Icons.qr_code_scanner_rounded;
    case 'unit':
      return Icons.straighten_rounded;
    case 'expiry_date':
      return Icons.event_rounded;
    case 'batch_number':
      return Icons.inventory_rounded;
    case 'weighted_unit':
      return Icons.scale_rounded;
    case 'shelf_life_days':
      return Icons.timer_rounded;
    case 'freshness_status':
      return Icons.eco_rounded;
  }

  return Icons.tune_rounded;
}
