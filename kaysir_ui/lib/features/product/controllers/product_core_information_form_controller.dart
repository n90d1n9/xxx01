import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/product_core_information_field_ids.dart';
import '../utils/product_form_draft.dart';

/// Owns core product information text controllers and derived form values.
class ProductCoreInformationFormController {
  ProductCoreInformationFormController({
    required this.nameController,
    required this.skuController,
    required this.categoryController,
    required this.priceController,
    required this.stockController,
    required this.descriptionController,
  });

  factory ProductCoreInformationFormController.fromProduct(Product? product) {
    return ProductCoreInformationFormController(
      nameController: TextEditingController(text: product?.name ?? ''),
      skuController: TextEditingController(text: product?.sku ?? ''),
      categoryController: TextEditingController(text: product?.category ?? ''),
      priceController: TextEditingController(
        text: product?.price.toString() ?? '',
      ),
      stockController: TextEditingController(
        text: product?.currentStock.toString() ?? '',
      ),
      descriptionController: TextEditingController(
        text: product?.description ?? '',
      ),
    );
  }

  final TextEditingController nameController;
  final TextEditingController skuController;
  final TextEditingController categoryController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final TextEditingController descriptionController;

  VoidCallback? _listener;

  List<TextEditingController> get controllers {
    return [
      nameController,
      skuController,
      categoryController,
      priceController,
      stockController,
      descriptionController,
    ];
  }

  void attachListener(VoidCallback listener) {
    if (_listener == listener) return;

    detachListener();
    _listener = listener;
    for (final controller in controllers) {
      controller.addListener(listener);
    }
  }

  void detachListener() {
    final listener = _listener;
    if (listener == null) return;

    for (final controller in controllers) {
      controller.removeListener(listener);
    }
    _listener = null;
  }

  Map<String, String> progressValues() {
    return {
      ProductCoreInformationFieldIds.name: nameController.text,
      ProductCoreInformationFieldIds.sku: skuController.text,
      ProductCoreInformationFieldIds.category: categoryController.text,
      ProductCoreInformationFieldIds.price: priceController.text,
      ProductCoreInformationFieldIds.initialStock: stockController.text,
      ProductCoreInformationFieldIds.description: descriptionController.text,
    };
  }

  ProductFormDraft toDraft({
    String barcode = '',
    String unit = '',
    Map<String, String> customAttributes = const {},
  }) {
    return ProductFormDraft.fromText(
      name: nameController.text,
      sku: skuController.text,
      category: categoryController.text,
      price: priceController.text,
      initialStock: stockController.text,
      description: descriptionController.text,
      barcode: barcode,
      unit: unit,
      customAttributes: customAttributes,
    );
  }

  void dispose() {
    detachListener();
    for (final controller in controllers) {
      controller.dispose();
    }
  }
}
