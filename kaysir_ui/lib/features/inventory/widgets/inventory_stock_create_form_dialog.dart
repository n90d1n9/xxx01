import 'package:flutter/material.dart';

import '../../product/models/product.dart';
import '../models/inventory_stock_create_draft.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';
import 'inventory_dialog_content_layout.dart';
import 'inventory_stock_create_dialog_state.dart';
import 'inventory_stock_create_empty_state.dart';
import 'inventory_stock_create_form.dart';

/// Dialog for creating a stock line for a product and warehouse pair.
class InventoryStockCreateDialog extends StatefulWidget {
  const InventoryStockCreateDialog({
    super.key,
    required this.products,
    required this.warehouses,
    required this.existingRecords,
    required this.onSubmit,
    this.onCancel,
  });

  final List<Product> products;
  final List<Warehouse> warehouses;
  final List<InventoryStockRecord> existingRecords;
  final ValueChanged<InventoryStockCreateDraft> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<InventoryStockCreateDialog> createState() =>
      _InventoryStockCreateDialogState();
}

class _InventoryStockCreateDialogState
    extends State<InventoryStockCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _reorderPointController;
  late final TextEditingController _reorderQuantityController;

  String? _selectedProductId;
  String? _selectedWarehouseId;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final selection = firstAvailableInventoryStockLocation(
      products: widget.products,
      warehouses: widget.warehouses,
      existingRecords: widget.existingRecords,
    );
    _selectedProductId =
        selection?.productId ??
        (widget.products.isEmpty ? null : widget.products.first.id);
    _selectedWarehouseId =
        selection?.warehouseId ??
        (widget.warehouses.isEmpty ? null : widget.warehouses.first.id);
    _quantityController = TextEditingController(text: '0');
    _reorderPointController = TextEditingController(text: '5');
    _reorderQuantityController = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reorderPointController.dispose();
    _reorderQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InventoryDialogContentLayout(
      maxWidth: 680,
      maxHeight: 780,
      eyebrow: 'Inventory Setup',
      title: 'Create Stock Line',
      subtitle:
          'Assign a product to a warehouse with opening quantity and reorder controls.',
      closeTooltip: 'Close create stock line',
      onClose: widget.onCancel,
      child:
          !_canCreateStockLine
              ? InventoryStockCreateEmptyState(
                hasProducts: widget.products.isNotEmpty,
                hasWarehouses: widget.warehouses.isNotEmpty,
              )
              : InventoryStockCreateForm(
                formKey: _formKey,
                products: widget.products,
                warehouses: widget.warehouses,
                selectedProductId: _selectedProductId!,
                selectedWarehouseId: _selectedWarehouseId!,
                quantityController: _quantityController,
                reorderPointController: _reorderPointController,
                reorderQuantityController: _reorderQuantityController,
                formError: _formError,
                onProductChanged: _updateProduct,
                onWarehouseChanged: _updateWarehouse,
                onCancel: widget.onCancel,
                onSubmit: _submit,
              ),
    );
  }

  bool get _canCreateStockLine {
    return canCreateInventoryStockLine(
      products: widget.products,
      warehouses: widget.warehouses,
      existingRecords: widget.existingRecords,
    );
  }

  void _updateProduct(String value) {
    setState(() {
      _selectedProductId = value;
      _formError = null;
    });
  }

  void _updateWarehouse(String value) {
    setState(() {
      _selectedWarehouseId = value;
      _formError = null;
    });
  }

  void _submit() {
    if (_selectedProductId == null || _selectedWarehouseId == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final draft = inventoryStockCreateDraftFromInput(
      productId: _selectedProductId!,
      warehouseId: _selectedWarehouseId!,
      quantityText: _quantityController.text,
      reorderPointText: _reorderPointController.text,
      reorderQuantityText: _reorderQuantityController.text,
    );
    if (draft == null) return;

    final issue = validateInventoryStockCreateDraft(
      draft,
      existingRecords: widget.existingRecords,
    );
    if (issue != null) {
      setState(() {
        _formError = inventoryStockCreateIssueLabel(issue);
      });
      return;
    }

    widget.onSubmit(draft);
  }
}
