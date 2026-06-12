import 'package:flutter/material.dart';

import '../models/inventory_branch.dart';
import '../models/inventory_warehouse_draft.dart';
import '../models/warehouse.dart';
import '../utils/inventory_form_utils.dart';

/// Controller bundle that translates warehouse form text fields into a draft.
class InventoryWarehouseFormControllerBundle {
  InventoryWarehouseFormControllerBundle._({
    required this.nameController,
    required this.branchController,
    required this.locationController,
    required this.capacityController,
    required this.descriptionController,
    required this.selectedBranchId,
  });

  factory InventoryWarehouseFormControllerBundle.fromWarehouse({
    required List<InventoryBranch> branches,
    Warehouse? warehouse,
  }) {
    final draft =
        warehouse == null
            ? const InventoryWarehouseDraft(name: '', location: '')
            : InventoryWarehouseDraft.fromWarehouse(warehouse);
    final selectedBranchId = _branchIdForDraft(draft, branches);
    final branchController = TextEditingController(text: draft.branchName);
    _syncSelectedBranchName(
      branchController: branchController,
      selectedBranchId: selectedBranchId,
      branches: branches,
    );

    return InventoryWarehouseFormControllerBundle._(
      nameController: TextEditingController(text: draft.name),
      branchController: branchController,
      locationController: TextEditingController(text: draft.location),
      capacityController: TextEditingController(
        text: draft.capacity?.toString() ?? '',
      ),
      descriptionController: TextEditingController(text: draft.description),
      selectedBranchId: selectedBranchId,
    );
  }

  final TextEditingController nameController;
  final TextEditingController branchController;
  final TextEditingController locationController;
  final TextEditingController capacityController;
  final TextEditingController descriptionController;
  String? selectedBranchId;

  InventoryWarehouseDraft toDraft({required bool usesBranchDirectory}) {
    final capacityText = capacityController.text.trim();
    return InventoryWarehouseDraft(
      name: nameController.text,
      branchId: usesBranchDirectory ? selectedBranchId : null,
      branchName: branchController.text,
      location: locationController.text,
      capacity:
          capacityText.isEmpty ? null : parseInventoryNumber(capacityText),
      description: descriptionController.text,
    );
  }

  void selectBranch(String branchId, List<InventoryBranch> branches) {
    selectedBranchId = branchId;
    _syncSelectedBranchName(
      branchController: branchController,
      selectedBranchId: selectedBranchId,
      branches: branches,
    );
  }

  void dispose() {
    nameController.dispose();
    branchController.dispose();
    locationController.dispose();
    capacityController.dispose();
    descriptionController.dispose();
  }

  static String? _branchIdForDraft(
    InventoryWarehouseDraft draft,
    List<InventoryBranch> branches,
  ) {
    final draftBranchId = draft.branchId;
    if (draftBranchId != null &&
        branches.any((branch) => branch.id == draftBranchId)) {
      return draftBranchId;
    }

    final draftBranchName = draft.branchName.trim().toLowerCase();
    for (final branch in branches) {
      if (branch.name.trim().toLowerCase() == draftBranchName) {
        return branch.id;
      }
    }

    return branches.isEmpty ? null : branches.first.id;
  }

  static void _syncSelectedBranchName({
    required TextEditingController branchController,
    required String? selectedBranchId,
    required List<InventoryBranch> branches,
  }) {
    if (selectedBranchId == null) return;

    for (final branch in branches) {
      if (branch.id == selectedBranchId) {
        branchController.text = branch.nameLabel;
        return;
      }
    }
  }
}
