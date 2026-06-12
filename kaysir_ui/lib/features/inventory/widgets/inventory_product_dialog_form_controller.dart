import 'package:flutter/material.dart';

import '../../product/models/product.dart';
import '../models/inventory_product_draft.dart';
import '../utils/inventory_form_utils.dart';
import 'inventory_product_dialog_focus.dart';

class InventoryProductDialogFormController {
  InventoryProductDialogFormController._(InventoryProductDraft draft)
    : nameController = TextEditingController(text: draft.name),
      skuController = TextEditingController(text: draft.sku),
      categoryController = TextEditingController(text: draft.category),
      priceController = TextEditingController(
        text: draft.price == null ? '' : draft.price!.toStringAsFixed(2),
      ),
      descriptionController = TextEditingController(text: draft.description),
      barcodeController = TextEditingController(text: draft.barcode),
      shortcutKeyController = TextEditingController(text: draft.shortcutKey),
      nameFocusNode = FocusNode(),
      skuFocusNode = FocusNode(),
      categoryFocusNode = FocusNode(),
      priceFocusNode = FocusNode(),
      descriptionFocusNode = FocusNode(),
      barcodeFocusNode = FocusNode(),
      shortcutKeyFocusNode = FocusNode();

  factory InventoryProductDialogFormController.fromProduct(Product? product) {
    final draft =
        product == null
            ? const InventoryProductDraft(name: '', sku: '', category: '')
            : InventoryProductDraft.fromProduct(product);
    return InventoryProductDialogFormController._(draft);
  }

  final TextEditingController nameController;
  final TextEditingController skuController;
  final TextEditingController categoryController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final TextEditingController barcodeController;
  final TextEditingController shortcutKeyController;
  final FocusNode nameFocusNode;
  final FocusNode skuFocusNode;
  final FocusNode categoryFocusNode;
  final FocusNode priceFocusNode;
  final FocusNode descriptionFocusNode;
  final FocusNode barcodeFocusNode;
  final FocusNode shortcutKeyFocusNode;

  InventoryProductDraft draft() {
    return InventoryProductDraft(
      name: nameController.text,
      sku: skuController.text,
      category: categoryController.text,
      price: parseInventoryDecimal(priceController.text),
      description: descriptionController.text,
      barcode: barcodeController.text,
      shortcutKey: shortcutKeyController.text,
    );
  }

  FocusNode? focusNodeFor(InventoryProductDialogFocusTarget? target) {
    switch (target) {
      case InventoryProductDialogFocusTarget.name:
        return nameFocusNode;
      case InventoryProductDialogFocusTarget.sku:
        return skuFocusNode;
      case InventoryProductDialogFocusTarget.category:
        return categoryFocusNode;
      case InventoryProductDialogFocusTarget.price:
        return priceFocusNode;
      case InventoryProductDialogFocusTarget.description:
        return descriptionFocusNode;
      case InventoryProductDialogFocusTarget.barcode:
        return barcodeFocusNode;
      case InventoryProductDialogFocusTarget.shortcutKey:
        return shortcutKeyFocusNode;
      case null:
        return null;
    }
  }

  void dispose() {
    nameController.dispose();
    skuController.dispose();
    categoryController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    barcodeController.dispose();
    shortcutKeyController.dispose();
    nameFocusNode.dispose();
    skuFocusNode.dispose();
    categoryFocusNode.dispose();
    priceFocusNode.dispose();
    descriptionFocusNode.dispose();
    barcodeFocusNode.dispose();
    shortcutKeyFocusNode.dispose();
  }
}
