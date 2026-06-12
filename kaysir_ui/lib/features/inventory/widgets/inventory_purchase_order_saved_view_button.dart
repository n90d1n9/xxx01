import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_purchase_order_saved_view.dart';

/// Popup trigger for applying purchase-order queue saved views.
class InventoryPurchaseOrderSavedViewButton extends StatelessWidget {
  const InventoryPurchaseOrderSavedViewButton({
    super.key,
    required this.savedViews,
    this.activeSavedViewId,
    this.onSelected,
    this.tooltip = 'Purchase order saved views',
    this.size = 44,
    this.iconSize = 20,
  });

  final List<InventoryPurchaseOrderSavedView> savedViews;
  final String? activeSavedViewId;
  final ValueChanged<InventoryPurchaseOrderSavedView>? onSelected;
  final String tooltip;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final activeView = _activeSavedView();

    return PopupMenuButton<InventoryPurchaseOrderSavedView>(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            PopupMenuItem<InventoryPurchaseOrderSavedView>(
              enabled: false,
              child: Text(
                'Saved views',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            for (final view in savedViews)
              PopupMenuItem<InventoryPurchaseOrderSavedView>(
                value: view,
                child: _PurchaseOrderSavedViewMenuRow(
                  view: view,
                  selected: view.id == activeSavedViewId,
                ),
              ),
          ],
      child: _PurchaseOrderSavedViewTrigger(
        activeView: activeView,
        size: size,
        iconSize: iconSize,
      ),
    );
  }

  InventoryPurchaseOrderSavedView? _activeSavedView() {
    final id = activeSavedViewId;
    if (id == null || id.isEmpty) return null;

    for (final view in savedViews) {
      if (view.id == id) return view;
    }

    return null;
  }
}

/// Popup trigger body that names the active saved view when one is applied.
class _PurchaseOrderSavedViewTrigger extends StatelessWidget {
  const _PurchaseOrderSavedViewTrigger({
    required this.activeView,
    required this.size,
    required this.iconSize,
  });

  final InventoryPurchaseOrderSavedView? activeView;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final view = activeView;
    if (view == null) {
      return SizedBox.square(
        dimension: size,
        child: Icon(Icons.bookmarks_rounded, size: iconSize),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 148, minHeight: size),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_added_rounded,
                size: iconSize,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  view.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact menu row that explains one purchase-order saved view.
class _PurchaseOrderSavedViewMenuRow extends StatelessWidget {
  const _PurchaseOrderSavedViewMenuRow({
    required this.view,
    required this.selected,
  });

  final InventoryPurchaseOrderSavedView view;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 260,
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle_rounded : _savedViewIcon(view),
            color:
                selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  view.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  view.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                _PurchaseOrderSavedViewControlChips(
                  labels: inventoryPurchaseOrderSavedViewControlLabels(view),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact chips that expose the controls applied by one saved view.
class _PurchaseOrderSavedViewControlChips extends StatelessWidget {
  const _PurchaseOrderSavedViewControlChips({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (final label in labels)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

IconData _savedViewIcon(InventoryPurchaseOrderSavedView view) {
  switch (view.id) {
    case 'receiving-now':
      return Icons.move_to_inbox_rounded;
    case 'highest-value':
      return Icons.payments_rounded;
    case 'overdue-first':
      return Icons.warning_amber_rounded;
    case 'recently-ordered':
      return Icons.history_rounded;
  }

  return Icons.bookmark_rounded;
}

@Preview(name: 'Purchase order saved view button')
Widget inventoryPurchaseOrderSavedViewButtonPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: Scaffold(
      body: Center(
        child: InventoryPurchaseOrderSavedViewButton(
          savedViews: inventoryPurchaseOrderSavedViews,
          activeSavedViewId: inventoryPurchaseOrderSavedViews.first.id,
          onSelected: (_) {},
        ),
      ),
    ),
  );
}
