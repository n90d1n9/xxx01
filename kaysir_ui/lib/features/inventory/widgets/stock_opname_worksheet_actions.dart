import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import 'stock_opname_worksheet_action_layout.dart';
import 'stock_opname_worksheet_preview_data.dart';

/// Footer actions for stock opname worksheet persistence.
class InventoryStockOpnameActions extends StatelessWidget {
  const InventoryStockOpnameActions({
    super.key,
    this.onReset,
    this.onSaveDraft,
    this.onComplete,
  });

  final VoidCallback? onReset;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return InventoryStockOpnameActionLayout(
      actions: [
        AppActionButton(
          label: 'Reset count',
          icon: Icons.refresh_rounded,
          variant: AppActionButtonVariant.secondary,
          onPressed: onReset,
        ),
        AppActionButton(
          label: 'Save draft',
          icon: Icons.save_outlined,
          variant: AppActionButtonVariant.secondary,
          onPressed: onSaveDraft,
        ),
        AppActionButton(
          label: 'Complete count',
          icon: Icons.verified_rounded,
          onPressed: onComplete,
        ),
      ],
    );
  }
}

@Preview(name: 'Inventory stock opname worksheet actions')
Widget inventoryStockOpnameActionsPreview() {
  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnameActions(
      onReset: () {},
      onSaveDraft: () {},
      onComplete: () {},
    ),
  );
}
