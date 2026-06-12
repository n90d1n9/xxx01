import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../utils/inventory_form_utils.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_date_picker_button.dart';
import 'inventory_form_fields.dart';

class InventoryPurchaseOrderCreateDetailsPanel extends StatelessWidget {
  const InventoryPurchaseOrderCreateDetailsPanel({
    super.key,
    required this.supplierController,
    required this.notesController,
    required this.expectedDeliveryDate,
    required this.onExpectedDatePressed,
    required this.onChanged,
  });

  final TextEditingController supplierController;
  final TextEditingController notesController;
  final DateTime? expectedDeliveryDate;
  final VoidCallback onExpectedDatePressed;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Supplier & Delivery',
      subtitle: 'Capture the vendor, expected arrival, and receiving context',
      leadingIcon: Icons.assignment_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;
          final supplierField = InventoryFormTextField(
            controller: supplierController,
            label: 'Supplier name',
            icon: Icons.business_rounded,
            textInputAction: TextInputAction.next,
            onChanged: (_) => onChanged(),
            validator:
                (value) => validateInventoryRequiredText(
                  value,
                  errorMessage: inventorySupplierNameRequiredError,
                ),
          );
          final deliveryButton = InventoryDatePickerButton(
            label: 'Expected delivery',
            valueLabel:
                expectedDeliveryDate == null
                    ? 'Select date'
                    : formatInventoryDate(expectedDeliveryDate!),
            onPressed: onExpectedDatePressed,
          );
          final notesField = InventoryFormTextField(
            controller: notesController,
            label: 'Notes',
            icon: Icons.notes_rounded,
            alignLabelWithHint: true,
            maxLines: 3,
            onChanged: (_) => onChanged(),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isCompact)
                Column(
                  children: [
                    supplierField,
                    const SizedBox(height: 12),
                    deliveryButton,
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: supplierField),
                    const SizedBox(width: 12),
                    Expanded(child: deliveryButton),
                  ],
                ),
              const SizedBox(height: 12),
              notesField,
            ],
          );
        },
      ),
    );
  }
}
