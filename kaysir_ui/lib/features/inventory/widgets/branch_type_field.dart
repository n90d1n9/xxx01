import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../models/inventory_branch.dart';
import 'branch_form_preview_data.dart';

/// Branch type select field for classifying company and fulfillment locations.
class InventoryBranchTypeField extends StatelessWidget {
  const InventoryBranchTypeField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final InventoryBranchType value;
  final ValueChanged<InventoryBranchType> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<InventoryBranchType>(
      label: 'Branch type',
      icon: Icons.category_rounded,
      value: value,
      options: [
        for (final type in InventoryBranchType.values)
          AppSelectOption(value: type, label: inventoryBranchTypeLabel(type)),
      ],
      onChanged: onChanged,
    );
  }
}

@Preview(name: 'Inventory branch type field')
Widget inventoryBranchTypeFieldPreview() {
  return inventoryBranchFormPreviewScaffold(
    InventoryBranchTypeField(
      value: InventoryBranchType.branchOffice,
      onChanged: (_) {},
    ),
  );
}
