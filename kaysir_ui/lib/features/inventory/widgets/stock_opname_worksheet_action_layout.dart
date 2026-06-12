import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import 'stock_opname_worksheet_preview_data.dart';

/// Responsive footer layout for stock opname worksheet actions.
///
/// Keeps action placement separate from button intent so the worksheet footer
/// can adapt to compact screens without changing persistence behavior.
class InventoryStockOpnameActionLayout extends StatelessWidget {
  const InventoryStockOpnameActionLayout({
    super.key,
    required this.actions,
    this.compactBreakpoint = 560,
    this.spacing = 10,
  });

  final List<Widget> actions;
  final double compactBreakpoint;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < compactBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < actions.length; index += 1) ...[
                if (index > 0) SizedBox(height: spacing),
                SizedBox(width: double.infinity, child: actions[index]),
              ],
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (var index = 0; index < actions.length; index += 1) ...[
              if (index > 0) SizedBox(width: spacing),
              actions[index],
            ],
          ],
        );
      },
    );
  }
}

@Preview(name: 'Inventory stock opname action layout')
Widget inventoryStockOpnameActionLayoutPreview() {
  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnameActionLayout(
      actions: [
        AppActionButton(
          label: 'Reset count',
          icon: Icons.refresh_rounded,
          variant: AppActionButtonVariant.secondary,
          onPressed: () {},
        ),
        AppActionButton(
          label: 'Save draft',
          icon: Icons.save_outlined,
          variant: AppActionButtonVariant.secondary,
          onPressed: () {},
        ),
        AppActionButton(
          label: 'Complete count',
          icon: Icons.verified_rounded,
          onPressed: () {},
        ),
      ],
    ),
  );
}
