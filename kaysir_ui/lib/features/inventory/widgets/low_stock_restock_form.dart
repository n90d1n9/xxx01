import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_replenishment_plan.dart';
import '../models/inventory_restock_draft.dart';
import '../utils/inventory_form_utils.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_form_fields.dart';
import 'inventory_mutation_form_layout.dart';
import 'low_stock_restock_dialog_state.dart';

/// Form body for confirming the replenishment quantity and restock notes.
class LowStockRestockForm extends StatelessWidget {
  const LowStockRestockForm({
    super.key,
    required this.formKey,
    required this.plan,
    required this.draft,
    required this.quantityController,
    required this.notesController,
    required this.onQuantityChanged,
    required this.onSubmit,
    this.formError,
    this.onCancel,
    this.currencyFormat,
  });

  final GlobalKey<FormState> formKey;
  final InventoryReplenishmentPlan plan;
  final InventoryRestockDraft? draft;
  final TextEditingController quantityController;
  final TextEditingController notesController;
  final String? formError;
  final ValueChanged<String> onQuantityChanged;
  final VoidCallback? onCancel;
  final VoidCallback onSubmit;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    return InventoryMutationFormLayout(
      formKey: formKey,
      formError: formError,
      onCancel: onCancel,
      confirmLabel: 'Confirm restock',
      confirmIcon: Icons.add_business_rounded,
      onSubmit: onSubmit,
      children: [
        LowStockRestockPreview(
          plan: plan,
          draft: draft,
          currencyFormat: currencyFormat,
        ),
        const SizedBox(height: 16),
        LowStockRestockQuantityField(
          controller: quantityController,
          onChanged: onQuantityChanged,
        ),
        const SizedBox(height: 12),
        LowStockRestockNotesField(controller: notesController),
      ],
    );
  }
}

/// Metric preview for the current, ordered, projected, and estimated restock
/// values.
class LowStockRestockPreview extends StatelessWidget {
  const LowStockRestockPreview({
    super.key,
    required this.plan,
    required this.draft,
    required this.currencyFormat,
  });

  final InventoryReplenishmentPlan plan;
  final InventoryRestockDraft? draft;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    final state = lowStockRestockPreviewState(plan: plan, draft: draft);

    return AppMetricGrid(
      minTileWidth: 150,
      metrics: [
        AppMetricGridItem(
          title: 'Current Qty',
          value: state.currentQuantity.toString(),
          helper: 'Units on hand',
          icon: Icons.inventory_2_rounded,
          accentColor: Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Order Qty',
          value: state.orderQuantity < 0 ? '0' : state.orderQuantity.toString(),
          helper: 'Suggested ${state.suggestedQuantity}',
          icon: Icons.add_shopping_cart_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'After Restock',
          value:
              state.projectedQuantity < 0
                  ? '0'
                  : state.projectedQuantity.toString(),
          helper: 'Reorder point ${state.reorderPoint}',
          icon: Icons.trending_up_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Estimated Cost',
          value: formatInventoryCurrency(
            state.estimatedCost < 0 ? 0 : state.estimatedCost,
            formatter: currencyFormat,
          ),
          helper: 'Based on unit cost',
          icon: Icons.payments_rounded,
          accentColor: Colors.green.shade700,
        ),
      ],
    );
  }
}

/// Quantity field for the replenishment order amount.
class LowStockRestockQuantityField extends StatelessWidget {
  const LowStockRestockQuantityField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InventoryIntegerFormField(
      controller: controller,
      label: 'Quantity to order',
      icon: Icons.add_shopping_cart_rounded,
      onChanged: onChanged,
      validator: validateInventoryPositiveQuantity,
    );
  }
}

/// Notes field for supplier or operational restock context.
class LowStockRestockNotesField extends StatelessWidget {
  const LowStockRestockNotesField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return InventoryFormTextField(
      controller: controller,
      label: 'Notes',
      icon: Icons.notes_rounded,
      maxLines: 3,
    );
  }
}
