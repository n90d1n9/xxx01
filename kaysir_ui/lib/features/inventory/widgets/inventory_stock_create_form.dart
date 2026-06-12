import 'package:flutter/material.dart';

import '../../product/models/product.dart';
import '../models/warehouse.dart';
import 'inventory_mutation_form_layout.dart';
import 'inventory_stock_create_location_fields.dart';
import 'inventory_stock_create_quantity_fields.dart';

/// Form body for creating a tracked product and warehouse stock line.
class InventoryStockCreateForm extends StatelessWidget {
  const InventoryStockCreateForm({
    super.key,
    required this.formKey,
    required this.products,
    required this.warehouses,
    required this.selectedProductId,
    required this.selectedWarehouseId,
    required this.quantityController,
    required this.reorderPointController,
    required this.reorderQuantityController,
    required this.onProductChanged,
    required this.onWarehouseChanged,
    required this.onSubmit,
    this.formError,
    this.onCancel,
  });

  final GlobalKey<FormState> formKey;
  final List<Product> products;
  final List<Warehouse> warehouses;
  final String selectedProductId;
  final String selectedWarehouseId;
  final TextEditingController quantityController;
  final TextEditingController reorderPointController;
  final TextEditingController reorderQuantityController;
  final String? formError;
  final ValueChanged<String> onProductChanged;
  final ValueChanged<String> onWarehouseChanged;
  final VoidCallback? onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return InventoryMutationFormLayout(
      formKey: formKey,
      formError: formError,
      onCancel: onCancel,
      confirmLabel: 'Create stock line',
      confirmIcon: Icons.add_rounded,
      onSubmit: onSubmit,
      children: [
        InventoryStockCreateLocationFields(
          products: products,
          warehouses: warehouses,
          selectedProductId: selectedProductId,
          selectedWarehouseId: selectedWarehouseId,
          onProductChanged: onProductChanged,
          onWarehouseChanged: onWarehouseChanged,
        ),
        const SizedBox(height: 14),
        InventoryStockCreateQuantityFields(
          quantityController: quantityController,
          reorderPointController: reorderPointController,
          reorderQuantityController: reorderQuantityController,
        ),
      ],
    );
  }
}
