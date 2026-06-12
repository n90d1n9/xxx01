import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/product_core_information_field_ids.dart';
import '../models/product_core_information_field_summary.dart';
import '../utils/product_form_draft.dart';
import 'product_core_information_field_helper.dart';
import 'product_core_information_field_metadata.dart';
import 'product_core_information_readiness_notice.dart';
import 'product_core_information_summary_pills.dart';

/// Core catalog, pricing, and opening stock fields for the product editor.
class ProductCoreInformationFields extends StatelessWidget {
  const ProductCoreInformationFields({
    super.key,
    required this.nameController,
    required this.skuController,
    required this.categoryController,
    required this.priceController,
    required this.stockController,
    required this.descriptionController,
    required this.isEditing,
    this.onReviewField,
    this.fieldFocusNodes = const {},
    this.fieldKeys = const {},
  });

  final TextEditingController nameController;
  final TextEditingController skuController;
  final TextEditingController categoryController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final TextEditingController descriptionController;
  final bool isEditing;
  final ValueChanged<String>? onReviewField;
  final Map<String, FocusNode> fieldFocusNodes;
  final Map<String, GlobalKey> fieldKeys;

  @override
  Widget build(BuildContext context) {
    final summary = ProductCoreInformationFieldSummary.forEditor(
      isEditing: isEditing,
      values: _progressValues,
    );

    return AppContentPanel(
      title: 'Product Information',
      subtitle: _subtitle,
      leadingIcon: Icons.inventory_2_rounded,
      trailing: ProductCoreInformationSummaryPills(summary: summary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductCoreInformationReadinessNotice(
            summary: summary,
            onReviewField: onReviewField,
          ),
          if (!summary.isReady) const SizedBox(height: 16),
          _anchoredField(
            ProductCoreInformationFieldIds.name,
            TextFormField(
              key: const ValueKey('product-core-field-name'),
              controller: nameController,
              focusNode: _focusNodeFor(ProductCoreInformationFieldIds.name),
              decoration: _fieldDecoration(
                _metadataFor(ProductCoreInformationFieldIds.name),
              ),
              validator:
                  (value) =>
                      validateRequiredProductField(value, 'a product name'),
            ),
          ),
          const SizedBox(height: 16),
          _anchoredField(
            ProductCoreInformationFieldIds.sku,
            TextFormField(
              key: const ValueKey('product-core-field-sku'),
              controller: skuController,
              focusNode: _focusNodeFor(ProductCoreInformationFieldIds.sku),
              decoration: _fieldDecoration(
                _metadataFor(ProductCoreInformationFieldIds.sku),
              ),
              validator:
                  (value) => validateRequiredProductField(value, 'a SKU'),
            ),
          ),
          const SizedBox(height: 16),
          _anchoredField(
            ProductCoreInformationFieldIds.category,
            TextFormField(
              key: const ValueKey('product-core-field-category'),
              controller: categoryController,
              focusNode: _focusNodeFor(ProductCoreInformationFieldIds.category),
              decoration: _fieldDecoration(
                _metadataFor(ProductCoreInformationFieldIds.category),
              ),
              validator:
                  (value) => validateRequiredProductField(value, 'a category'),
            ),
          ),
          const SizedBox(height: 16),
          _PriceStockFields(
            priceController: priceController,
            stockController: stockController,
            priceFocusNode: _focusNodeFor(ProductCoreInformationFieldIds.price),
            stockFocusNode: _focusNodeFor(
              ProductCoreInformationFieldIds.initialStock,
            ),
            priceKey: fieldKeys[ProductCoreInformationFieldIds.price],
            stockKey: fieldKeys[ProductCoreInformationFieldIds.initialStock],
            isEditing: isEditing,
          ),
          const SizedBox(height: 16),
          _anchoredField(
            ProductCoreInformationFieldIds.description,
            TextFormField(
              key: const ValueKey('product-core-field-description'),
              controller: descriptionController,
              focusNode: _focusNodeFor(
                ProductCoreInformationFieldIds.description,
              ),
              decoration: _fieldDecoration(
                _metadataFor(ProductCoreInformationFieldIds.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator:
                  (value) =>
                      validateRequiredProductField(value, 'a description'),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> get _progressValues {
    return {
      ProductCoreInformationFieldIds.name: nameController.text,
      ProductCoreInformationFieldIds.sku: skuController.text,
      ProductCoreInformationFieldIds.category: categoryController.text,
      ProductCoreInformationFieldIds.price: priceController.text,
      ProductCoreInformationFieldIds.initialStock: stockController.text,
      ProductCoreInformationFieldIds.description: descriptionController.text,
    };
  }

  String get _subtitle {
    if (isEditing) {
      return 'Catalog identity, pricing, and inventory handoff.';
    }

    return 'Catalog identity, pricing, and opening stock for launch.';
  }

  InputDecoration _fieldDecoration(
    ProductCoreInformationFieldMetadata metadata, {
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: metadata.label,
      helper: ProductCoreInformationFieldHelper(metadata: metadata),
      prefixIcon: Icon(metadata.icon),
      border: const OutlineInputBorder(),
      alignLabelWithHint: alignLabelWithHint,
    );
  }

  ProductCoreInformationFieldMetadata _metadataFor(String fieldId) {
    return ProductCoreInformationFieldMetadata.forField(
      fieldId,
      isEditing: isEditing,
    );
  }

  FocusNode? _focusNodeFor(String fieldId) => fieldFocusNodes[fieldId];

  Widget _anchoredField(String fieldId, Widget child) {
    final fieldKey = fieldKeys[fieldId];
    if (fieldKey == null) return child;

    return KeyedSubtree(key: fieldKey, child: child);
  }
}

/// Responsive paired inputs for product price and opening stock.
class _PriceStockFields extends StatelessWidget {
  const _PriceStockFields({
    required this.priceController,
    required this.stockController,
    required this.priceFocusNode,
    required this.stockFocusNode,
    required this.priceKey,
    required this.stockKey,
    required this.isEditing,
  });

  final TextEditingController priceController;
  final TextEditingController stockController;
  final FocusNode? priceFocusNode;
  final FocusNode? stockFocusNode;
  final GlobalKey? priceKey;
  final GlobalKey? stockKey;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final priceMetadata = ProductCoreInformationFieldMetadata.forField(
      ProductCoreInformationFieldIds.price,
      isEditing: isEditing,
    );
    final stockMetadata = ProductCoreInformationFieldMetadata.forField(
      ProductCoreInformationFieldIds.initialStock,
      isEditing: isEditing,
    );
    final priceField = _anchoredField(
      priceKey,
      TextFormField(
        key: const ValueKey('product-core-field-price'),
        controller: priceController,
        focusNode: priceFocusNode,
        decoration: InputDecoration(
          labelText: priceMetadata.label,
          helper: ProductCoreInformationFieldHelper(metadata: priceMetadata),
          prefixIcon: Icon(priceMetadata.icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: priceMetadata.keyboardType,
        validator: validateProductPriceInput,
      ),
    );
    final stockField = _anchoredField(
      stockKey,
      TextFormField(
        key: const ValueKey('product-core-field-initial-stock'),
        controller: stockController,
        focusNode: stockFocusNode,
        decoration: InputDecoration(
          labelText: stockMetadata.label,
          helper: ProductCoreInformationFieldHelper(metadata: stockMetadata),
          prefixIcon: Icon(stockMetadata.icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: stockMetadata.keyboardType,
        enabled: !isEditing,
        validator: isEditing ? null : validateProductStockInput,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [priceField, const SizedBox(height: 16), stockField],
          );
        }

        return Row(
          children: [
            Expanded(child: priceField),
            const SizedBox(width: 16),
            Expanded(child: stockField),
          ],
        );
      },
    );
  }

  Widget _anchoredField(GlobalKey? fieldKey, Widget child) {
    if (fieldKey == null) return child;

    return KeyedSubtree(key: fieldKey, child: child);
  }
}

@Preview(name: 'Product core information fields')
Widget productCoreInformationFieldsPreview() {
  final controllers = _PreviewCoreInformationControllers();

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductCoreInformationFields(
          nameController: controllers.nameController,
          skuController: controllers.skuController,
          categoryController: controllers.categoryController,
          priceController: controllers.priceController,
          stockController: controllers.stockController,
          descriptionController: controllers.descriptionController,
          isEditing: false,
        ),
      ),
    ),
  );
}

/// Controller fixture used by the core information fields preview.
class _PreviewCoreInformationControllers {
  _PreviewCoreInformationControllers()
    : nameController = TextEditingController(text: 'Spinach'),
      skuController = TextEditingController(text: 'SP-001'),
      categoryController = TextEditingController(text: 'Fresh produce'),
      priceController = TextEditingController(text: '12'),
      stockController = TextEditingController(text: '8'),
      descriptionController = TextEditingController(text: 'Leafy greens');

  final TextEditingController nameController;
  final TextEditingController skuController;
  final TextEditingController categoryController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final TextEditingController descriptionController;
}
