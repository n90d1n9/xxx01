import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_select_field.dart';
import '../../../../widgets/ui/app_status_pill.dart';
import '../../../product/models/product.dart';
import '../../models/inventory_purchase_order_create.dart';
import '../../models/purchase_order_item.dart';
import '../../utils/inventory_formatters.dart';
import '../../widgets/inventory_dialog_form_layout.dart';
import '../../widgets/inventory_form_fields.dart';

/// Dialog for adding a validated product line to a purchase order draft.
class AddOrderItemDialog extends StatefulWidget {
  const AddOrderItemDialog({
    super.key,
    required this.products,
    required this.onCancel,
    required this.onItemAdded,
  });

  final List<Product> products;
  final VoidCallback onCancel;
  final ValueChanged<PurchaseOrderItem> onItemAdded;

  @override
  State<AddOrderItemDialog> createState() => _AddOrderItemDialogState();
}

class _AddOrderItemDialogState extends State<AddOrderItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedProductId;

  InventoryPurchaseOrderLineDraft get _draft {
    return InventoryPurchaseOrderLineDraft(
      products: widget.products,
      productId: _selectedProductId,
      quantityText: _quantityController.text,
      unitPriceText: _priceController.text,
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;

    return InventoryDialogFormLayout(
      maxWidth: 560,
      maxHeight: 620,
      formKey: _formKey,
      eyebrow: 'Purchase Order',
      title: 'Add Item',
      subtitle: 'Select a product, quantity, and negotiated unit cost.',
      closeTooltip: 'Close add item dialog',
      onCancel: widget.onCancel,
      confirmLabel: 'Add item',
      confirmIcon: Icons.add_rounded,
      onConfirm: _submit,
      children: [
        AppSelectField<String?>(
          label: 'Product',
          icon: Icons.inventory_2_rounded,
          value: _selectedProductId,
          options: [
            for (final product in widget.products)
              AppSelectOption(value: product.id, label: product.name),
          ],
          validator:
              (_) => _lineIssueLabel(
                InventoryPurchaseOrderLineIssue.missingProduct,
              ),
          onChanged: _selectProduct,
          menuMaxHeight: 260,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 440;
            final fields = [
              InventoryIntegerFormField(
                controller: _quantityController,
                label: 'Quantity',
                icon: Icons.tag_rounded,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator:
                    (_) => _lineIssueLabel(
                      InventoryPurchaseOrderLineIssue.invalidQuantity,
                    ),
                onChanged: (_) => setState(() {}),
              ),
              InventoryFormTextField(
                controller: _priceController,
                label: 'Unit price',
                icon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator:
                    (_) => _lineIssueLabel(
                      InventoryPurchaseOrderLineIssue.invalidUnitPrice,
                    ),
                onChanged: (_) => setState(() {}),
              ),
            ];

            if (isCompact) {
              return Column(
                children: [fields[0], const SizedBox(height: 12), fields[1]],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: fields[0]),
                const SizedBox(width: 12),
                Expanded(child: fields[1]),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: AppStatusPill(
            label: 'Line total ${formatInventoryCurrency(draft.total)}',
            icon: Icons.calculate_rounded,
            color: Theme.of(context).colorScheme.primary,
            maxWidth: 220,
          ),
        ),
      ],
    );
  }

  String? _lineIssueLabel(InventoryPurchaseOrderLineIssue targetIssue) {
    final issue = validateInventoryPurchaseOrderLineDraft(_draft);
    return issue == targetIssue
        ? inventoryPurchaseOrderLineIssueLabel(issue!)
        : null;
  }

  void _selectProduct(String? value) {
    setState(() {
      _selectedProductId = value;
      Product? selectedProduct;
      for (final product in widget.products) {
        if (product.id == value) {
          selectedProduct = product;
          break;
        }
      }
      if (selectedProduct != null) {
        _priceController.text = selectedProduct.price.toStringAsFixed(2);
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onItemAdded(_draft.toPurchaseOrderItem());
  }
}

@Preview(name: 'Purchase order add item dialog')
Widget purchaseOrderAddItemDialogPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: AddOrderItemDialog(
          products: [
            Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
            Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 20),
          ],
          onCancel: () {},
          onItemAdded: (_) {},
        ),
      ),
    ),
  );
}
