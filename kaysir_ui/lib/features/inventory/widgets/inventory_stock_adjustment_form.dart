import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_stock_adjustment_draft.dart';
import '../utils/inventory_form_utils.dart';
import 'inventory_form_fields.dart';
import 'inventory_mutation_form_layout.dart';
import 'inventory_stock_adjustment_dialog_state.dart';

/// Form body for increasing or decreasing a stock line with preview metrics.
class InventoryStockAdjustmentForm extends StatelessWidget {
  const InventoryStockAdjustmentForm({
    super.key,
    required this.formKey,
    required this.direction,
    required this.currentQuantity,
    required this.projectedQuantity,
    required this.quantityController,
    required this.reasonController,
    required this.onQuantityChanged,
    required this.onSubmit,
    this.formError,
    this.onCancel,
  });

  final GlobalKey<FormState> formKey;
  final InventoryStockAdjustmentDirection direction;
  final int currentQuantity;
  final int projectedQuantity;
  final TextEditingController quantityController;
  final TextEditingController reasonController;
  final String? formError;
  final ValueChanged<String> onQuantityChanged;
  final VoidCallback? onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return InventoryMutationFormLayout(
      formKey: formKey,
      formError: formError,
      onCancel: onCancel,
      confirmLabel:
          '${inventoryStockAdjustmentDirectionLabel(direction)} stock',
      confirmIcon: inventoryStockAdjustmentDirectionIcon(direction),
      onSubmit: onSubmit,
      children: [
        InventoryStockAdjustmentPreview(
          currentQuantity: currentQuantity,
          projectedQuantity: projectedQuantity,
        ),
        const SizedBox(height: 16),
        InventoryStockAdjustmentQuantityField(
          controller: quantityController,
          direction: direction,
          onChanged: onQuantityChanged,
        ),
        const SizedBox(height: 12),
        InventoryStockAdjustmentReasonField(controller: reasonController),
      ],
    );
  }
}

/// Metric preview showing current and projected quantity for an adjustment.
class InventoryStockAdjustmentPreview extends StatelessWidget {
  const InventoryStockAdjustmentPreview({
    super.key,
    required this.currentQuantity,
    required this.projectedQuantity,
  });

  final int currentQuantity;
  final int projectedQuantity;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      minTileWidth: 150,
      metrics: [
        AppMetricGridItem(
          title: 'Current Qty',
          value: currentQuantity.toString(),
          helper: 'Units on hand',
          icon: Icons.inventory_2_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Projected Qty',
          value: projectedQuantity < 0 ? '0' : projectedQuantity.toString(),
          helper: 'After adjustment',
          icon: Icons.trending_flat_rounded,
          accentColor: Colors.teal.shade700,
        ),
      ],
    );
  }
}

/// Quantity input for an inventory stock adjustment direction.
class InventoryStockAdjustmentQuantityField extends StatelessWidget {
  const InventoryStockAdjustmentQuantityField({
    super.key,
    required this.controller,
    required this.direction,
    required this.onChanged,
  });

  final TextEditingController controller;
  final InventoryStockAdjustmentDirection direction;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InventoryIntegerFormField(
      controller: controller,
      label: 'Quantity to ${inventoryStockAdjustmentDirectionVerb(direction)}',
      icon: inventoryStockAdjustmentDirectionIcon(direction),
      onChanged: onChanged,
      validator: validateInventoryPositiveQuantity,
    );
  }
}

/// Optional reason input captured with a stock adjustment audit event.
class InventoryStockAdjustmentReasonField extends StatelessWidget {
  const InventoryStockAdjustmentReasonField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return InventoryFormTextField(
      controller: controller,
      label: 'Reason',
      icon: Icons.notes_rounded,
      maxLines: 3,
    );
  }
}

IconData inventoryStockAdjustmentDirectionIcon(
  InventoryStockAdjustmentDirection direction,
) {
  switch (direction) {
    case InventoryStockAdjustmentDirection.increase:
      return Icons.add_circle_outline_rounded;
    case InventoryStockAdjustmentDirection.decrease:
      return Icons.remove_circle_outline_rounded;
  }
}
