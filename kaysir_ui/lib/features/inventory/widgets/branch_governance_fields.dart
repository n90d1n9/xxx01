import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_branch.dart';
import 'branch_compliance_tier_field.dart';
import 'branch_form_preview_data.dart';
import 'branch_status_field.dart';
import 'branch_type_field.dart';

/// Select-field stack for branch type, compliance tier, and operating status.
class InventoryBranchGovernanceFields extends StatelessWidget {
  const InventoryBranchGovernanceFields({
    super.key,
    required this.type,
    required this.complianceTier,
    required this.status,
    required this.onTypeChanged,
    required this.onComplianceTierChanged,
    required this.onStatusChanged,
  });

  final InventoryBranchType type;
  final InventoryBranchComplianceTier complianceTier;
  final InventoryBranchStatus status;
  final ValueChanged<InventoryBranchType> onTypeChanged;
  final ValueChanged<InventoryBranchComplianceTier> onComplianceTierChanged;
  final ValueChanged<InventoryBranchStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InventoryBranchTypeField(value: type, onChanged: onTypeChanged),
        const SizedBox(height: 12),
        InventoryBranchComplianceTierField(
          value: complianceTier,
          onChanged: onComplianceTierChanged,
        ),
        const SizedBox(height: 12),
        InventoryBranchStatusField(value: status, onChanged: onStatusChanged),
      ],
    );
  }
}

@Preview(name: 'Inventory branch governance fields')
Widget inventoryBranchGovernanceFieldsPreview() {
  return inventoryBranchFormPreviewScaffold(
    InventoryBranchGovernanceFields(
      type: InventoryBranchType.branchOffice,
      complianceTier: InventoryBranchComplianceTier.standard,
      status: InventoryBranchStatus.active,
      onTypeChanged: (_) {},
      onComplianceTierChanged: (_) {},
      onStatusChanged: (_) {},
    ),
  );
}
