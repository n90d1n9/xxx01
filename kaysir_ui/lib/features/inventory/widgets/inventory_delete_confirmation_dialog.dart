import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_dialog_actions.dart';
import 'inventory_dialog_surface.dart';

/// Reusable destructive confirmation dialog for inventory delete workflows.
class InventoryDeleteConfirmationDialog extends StatelessWidget {
  const InventoryDeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.onConfirm,
    this.children = const [],
    this.onCancel,
    this.eyebrow = 'Confirm Delete',
    this.cancelLabel = 'Cancel',
    this.closeTooltip = 'Close dialog',
    this.showCloseButton = false,
    this.confirmIcon = Icons.delete_outline_rounded,
    this.cancelIcon = Icons.close_rounded,
    this.subtitleMaxLines = 3,
    this.maxWidth = 520,
    this.bodySpacing = 18,
    this.actionsSpacing = 20,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final int subtitleMaxLines;
  final List<Widget> children;
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final String confirmLabel;
  final VoidCallback? onConfirm;
  final IconData? confirmIcon;
  final IconData? cancelIcon;
  final String closeTooltip;
  final bool showCloseButton;
  final double maxWidth;
  final double bodySpacing;
  final double actionsSpacing;

  @override
  Widget build(BuildContext context) {
    return InventoryDialogSurface(
      maxWidth: maxWidth,
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InventoryDialogHeader(
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
            subtitleMaxLines: subtitleMaxLines,
            closeTooltip: closeTooltip,
            showCloseButton: showCloseButton,
            onClose: onCancel,
          ),
          if (children.isEmpty)
            SizedBox(height: actionsSpacing)
          else ...[
            SizedBox(height: bodySpacing),
            ...children,
            SizedBox(height: actionsSpacing),
          ],
          AppDialogActions(
            cancelLabel: cancelLabel,
            cancelIcon: cancelIcon,
            onCancel: onCancel,
            confirmLabel: confirmLabel,
            confirmIcon: confirmIcon,
            confirmVariant: AppActionButtonVariant.destructive,
            onConfirm: onConfirm,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Inventory delete confirmation dialog')
Widget inventoryDeleteConfirmationDialogPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: InventoryDeleteConfirmationDialog(
          title: 'Delete selected products?',
          subtitle: 'This will remove 3 selected products from the catalog.',
          confirmLabel: 'Delete selected',
          showCloseButton: true,
          onCancel: () {},
          onConfirm: () {},
          children: const [Text('3 products selected')],
        ),
      ),
    ),
  );
}
