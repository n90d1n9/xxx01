import 'package:flutter/material.dart';

import '../models/management_pack.dart';
import '../models/product.dart';
import '../models/product_form_section.dart';

/// Owns management-pack field controllers, toggles, and derived form values.
class ProductManagementPackFormController {
  ProductManagementPackFormController({this.product});

  final Product? product;
  final textControllers = <ProductManagementFieldId, TextEditingController>{};
  final toggleValues = <ProductManagementFieldId, bool>{};

  VoidCallback? _listener;

  void attachListener(VoidCallback listener) {
    if (_listener == listener) return;

    detachListener();
    _listener = listener;
    for (final controller in textControllers.values) {
      controller.addListener(listener);
    }
  }

  void detachListener() {
    final listener = _listener;
    if (listener == null) return;

    for (final controller in textControllers.values) {
      controller.removeListener(listener);
    }
    _listener = null;
  }

  void ensurePackFields(ProductManagementPack pack) {
    for (final field in productManagementPackEditableFields(pack)) {
      if (field.type == ProductManagementFieldType.toggle) {
        toggleValues.putIfAbsent(field.id, () => _initialToggleValue(field));
        continue;
      }

      textControllers.putIfAbsent(
        field.id,
        () => _trackedController(text: _initialFieldValue(field)),
      );
    }
  }

  void setToggleValue(ProductManagementPackField field, bool value) {
    toggleValues[field.id] = value;
  }

  String fieldText(ProductManagementFieldId id) {
    return textControllers[id]?.text ?? '';
  }

  Map<String, String> progressValues(ProductManagementPack pack) {
    final values = <String, String>{};

    for (final field in productManagementPackEditableFields(pack)) {
      if (field.type == ProductManagementFieldType.toggle) {
        values[field.id.value] =
            (toggleValues[field.id] ?? false) ? 'true' : '';
        continue;
      }

      values[field.id.value] = fieldText(field.id);
    }

    return values;
  }

  Map<String, String> customAttributes(ProductManagementPack pack) {
    final values = <String, String>{};

    for (final field in productManagementPackEditableFields(pack)) {
      if (field.id == ProductManagementFieldId.barcode ||
          field.id == ProductManagementFieldId.unit) {
        continue;
      }

      if (field.type == ProductManagementFieldType.toggle) {
        if (toggleValues[field.id] ?? false) {
          values[field.id.value] = 'true';
        }
        continue;
      }

      values[field.id.value] = fieldText(field.id);
    }

    return values;
  }

  String get barcodeText => fieldText(ProductManagementFieldId.barcode);
  String get unitText => fieldText(ProductManagementFieldId.unit);

  void dispose() {
    detachListener();
    for (final controller in textControllers.values) {
      controller.dispose();
    }
  }

  TextEditingController _trackedController({String text = ''}) {
    final controller = TextEditingController(text: text);
    final listener = _listener;
    if (listener != null) controller.addListener(listener);
    return controller;
  }

  String _initialFieldValue(ProductManagementPackField field) {
    final currentProduct = product;
    if (currentProduct == null) return '';

    if (field.id == ProductManagementFieldId.barcode) {
      return currentProduct.barcode ?? '';
    }
    if (field.id == ProductManagementFieldId.unit) {
      return currentProduct.unit ?? '';
    }

    return currentProduct.customAttributes[field.id.value] ?? '';
  }

  bool _initialToggleValue(ProductManagementPackField field) {
    final value = product?.customAttributes[field.id.value] ?? '';
    final normalized = value.trim().toLowerCase();

    return normalized == 'true' || normalized == 'yes' || normalized == '1';
  }
}
