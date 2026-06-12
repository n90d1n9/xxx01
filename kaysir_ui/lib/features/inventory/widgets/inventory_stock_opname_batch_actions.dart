import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import 'inventory_stock_opname_batch_action_details.dart';

/// Compact worksheet action strip for applying count changes to visible rows.
///
/// The strip is intentionally presentation-only. It receives the already
/// resolved visible count and delegates the mutation to the stock opname form
/// controller through callbacks supplied by the screen.
class InventoryStockOpnameBatchActions extends StatelessWidget {
  const InventoryStockOpnameBatchActions({
    super.key,
    required this.visibleLineCount,
    required this.matchableLineCount,
    this.onMatchVisible,
  });

  final int visibleLineCount;
  final int matchableLineCount;
  final VoidCallback? onMatchVisible;

  @override
  Widget build(BuildContext context) {
    final details = inventoryStockOpnameBatchActionDetails(
      visibleLineCount: visibleLineCount,
      matchableLineCount: matchableLineCount,
      hasMatchVisibleHandler: onMatchVisible != null,
    );

    if (!details.isVisible) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        _InventoryStockOpnameBatchActionSummary(label: details.summaryLabel),
        AppActionButton(
          label: details.matchActionLabel,
          icon: Icons.done_all_rounded,
          variant: AppActionButtonVariant.secondary,
          compact: true,
          onPressed: details.canMatchVisible ? onMatchVisible : null,
        ),
      ],
    );
  }
}

/// Short helper text describing the current visible batch action state.
class _InventoryStockOpnameBatchActionSummary extends StatelessWidget {
  const _InventoryStockOpnameBatchActionSummary({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

@Preview(name: 'Inventory stock opname batch actions')
Widget inventoryStockOpnameBatchActionsPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: InventoryStockOpnameBatchActions(
            visibleLineCount: 3,
            matchableLineCount: 2,
            onMatchVisible: () {},
          ),
        ),
      ),
    ),
  );
}
