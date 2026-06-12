import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../models/inventory_branch.dart';
import 'branch_form_preview_data.dart';

/// Compliance tier select field for branch governance controls.
class InventoryBranchComplianceTierField extends StatelessWidget {
  const InventoryBranchComplianceTierField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final InventoryBranchComplianceTier value;
  final ValueChanged<InventoryBranchComplianceTier> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<InventoryBranchComplianceTier>(
      label: 'Compliance tier',
      icon: Icons.policy_rounded,
      value: value,
      options: [
        for (final tier in InventoryBranchComplianceTier.values)
          AppSelectOption(
            value: tier,
            label: inventoryBranchComplianceTierLabel(tier),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

@Preview(name: 'Inventory branch compliance tier field')
Widget inventoryBranchComplianceTierFieldPreview() {
  return inventoryBranchFormPreviewScaffold(
    InventoryBranchComplianceTierField(
      value: InventoryBranchComplianceTier.standard,
      onChanged: (_) {},
    ),
  );
}
