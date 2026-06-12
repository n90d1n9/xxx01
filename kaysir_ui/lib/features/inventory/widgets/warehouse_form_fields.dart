import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_branch.dart';
import '../utils/inventory_form_utils.dart';
import 'inventory_form_fields.dart';
import 'warehouse_branch_field.dart';
import 'warehouse_form_preview_data.dart';

/// Field group for warehouse identity, branch, location, capacity, and notes.
class InventoryWarehouseFormFields extends StatelessWidget {
  const InventoryWarehouseFormFields({
    super.key,
    required this.nameController,
    required this.branchController,
    required this.locationController,
    required this.capacityController,
    required this.descriptionController,
    required this.branches,
    required this.selectedBranchId,
    required this.onTextChanged,
    required this.onBranchChanged,
  });

  final TextEditingController nameController;
  final TextEditingController branchController;
  final TextEditingController locationController;
  final TextEditingController capacityController;
  final TextEditingController descriptionController;
  final List<InventoryBranch> branches;
  final String? selectedBranchId;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String> onBranchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        InventoryFormTextField(
          controller: nameController,
          label: 'Warehouse name',
          icon: Icons.warehouse_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: inventoryWarehouseNameRequiredError,
              ),
          onChanged: onTextChanged,
        ),
        const SizedBox(height: 12),
        InventoryWarehouseBranchField(
          controller: branchController,
          branches: branches,
          selectedBranchId: selectedBranchId,
          onTextChanged: onTextChanged,
          onBranchChanged: onBranchChanged,
        ),
        const SizedBox(height: 12),
        InventoryFormTextField(
          controller: locationController,
          label: 'Location',
          icon: Icons.location_on_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: inventoryWarehouseLocationRequiredError,
              ),
          onChanged: onTextChanged,
        ),
        const SizedBox(height: 12),
        InventoryFormTextField(
          controller: capacityController,
          label: 'Capacity',
          icon: Icons.inventory_rounded,
          keyboardType: TextInputType.number,
          helperText: 'Optional',
          validator:
              (value) => validateInventoryOptionalNonNegativeNumber(
                value,
                errorMessage: inventoryWarehouseCapacityError,
              ),
          onChanged: onTextChanged,
        ),
        const SizedBox(height: 12),
        InventoryFormTextField(
          controller: descriptionController,
          label: 'Description',
          icon: Icons.notes_rounded,
          maxLines: 3,
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse form fields')
Widget inventoryWarehouseFormFieldsPreview() {
  final branches = inventoryWarehouseFormPreviewBranches();

  return inventoryWarehouseFormPreviewScaffold(
    InventoryWarehouseFormFields(
      nameController: TextEditingController(text: 'Main Fulfillment Hub'),
      branchController: TextEditingController(text: branches.first.nameLabel),
      locationController: TextEditingController(text: 'Jakarta'),
      capacityController: TextEditingController(text: '140'),
      descriptionController: TextEditingController(
        text: 'Primary storage for fast-moving products',
      ),
      branches: branches,
      selectedBranchId: branches.first.id,
      onTextChanged: (_) {},
      onBranchChanged: (_) {},
    ),
  );
}
