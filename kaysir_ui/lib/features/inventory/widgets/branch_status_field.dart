import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../models/inventory_branch.dart';
import 'branch_form_preview_data.dart';

/// Branch status select field for operating lifecycle changes.
class InventoryBranchStatusField extends StatelessWidget {
  const InventoryBranchStatusField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final InventoryBranchStatus value;
  final ValueChanged<InventoryBranchStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<InventoryBranchStatus>(
      label: 'Status',
      icon: Icons.toggle_on_rounded,
      value: value,
      options: [
        for (final status in InventoryBranchStatus.values)
          AppSelectOption(
            value: status,
            label: inventoryBranchStatusLabel(status),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

@Preview(name: 'Inventory branch status field')
Widget inventoryBranchStatusFieldPreview() {
  return inventoryBranchFormPreviewScaffold(
    InventoryBranchStatusField(
      value: InventoryBranchStatus.active,
      onChanged: (_) {},
    ),
  );
}
