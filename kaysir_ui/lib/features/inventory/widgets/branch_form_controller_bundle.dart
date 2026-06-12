import 'package:flutter/material.dart';

import '../models/inventory_branch.dart';
import '../models/inventory_branch_draft.dart';
import '../utils/inventory_form_utils.dart';

/// Controller bundle that translates branch form inputs into a draft.
class InventoryBranchFormControllerBundle {
  InventoryBranchFormControllerBundle._({
    required this.nameController,
    required this.cityController,
    required this.managerController,
    required this.contactController,
    required this.codeController,
    required this.regionController,
    required this.legalEntityController,
    required this.employeeCountController,
    required this.notesController,
    required this.type,
    required this.complianceTier,
    required this.status,
  });

  factory InventoryBranchFormControllerBundle.fromBranch(
    InventoryBranch? branch,
  ) {
    final draft =
        branch == null
            ? const InventoryBranchDraft(
              name: '',
              city: '',
              managerName: '',
              contact: '',
            )
            : InventoryBranchDraft.fromBranch(branch);

    return InventoryBranchFormControllerBundle._(
      nameController: TextEditingController(text: draft.name),
      cityController: TextEditingController(text: draft.city),
      managerController: TextEditingController(text: draft.managerName),
      contactController: TextEditingController(text: draft.contact),
      codeController: TextEditingController(text: draft.code),
      regionController: TextEditingController(text: draft.region),
      legalEntityController: TextEditingController(text: draft.legalEntity),
      employeeCountController: TextEditingController(
        text: draft.employeeCount.toString(),
      ),
      notesController: TextEditingController(text: draft.notes),
      type: draft.type,
      complianceTier: draft.complianceTier,
      status: draft.status,
    );
  }

  final TextEditingController nameController;
  final TextEditingController cityController;
  final TextEditingController managerController;
  final TextEditingController contactController;
  final TextEditingController codeController;
  final TextEditingController regionController;
  final TextEditingController legalEntityController;
  final TextEditingController employeeCountController;
  final TextEditingController notesController;
  InventoryBranchType type;
  InventoryBranchComplianceTier complianceTier;
  InventoryBranchStatus status;

  InventoryBranchDraft toDraft() {
    return InventoryBranchDraft(
      name: nameController.text,
      city: cityController.text,
      managerName: managerController.text,
      contact: contactController.text,
      code: codeController.text,
      region: regionController.text,
      legalEntity: legalEntityController.text,
      type: type,
      complianceTier: complianceTier,
      employeeCount: parseInventoryInteger(employeeCountController.text) ?? -1,
      status: status,
      notes: notesController.text,
    );
  }

  void dispose() {
    nameController.dispose();
    cityController.dispose();
    managerController.dispose();
    contactController.dispose();
    codeController.dispose();
    regionController.dispose();
    legalEntityController.dispose();
    employeeCountController.dispose();
    notesController.dispose();
  }
}
