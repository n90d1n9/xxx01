import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'inventory_delete_confirmation_dialog.dart';

/// Reusable confirmation dialog for discarding unsaved inventory workflow edits.
class InventoryUnsavedChangesDialog extends StatelessWidget {
  const InventoryUnsavedChangesDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.onConfirm,
    this.onCancel,
    this.confirmIcon = Icons.warning_amber_rounded,
  });

  final String title;
  final String subtitle;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final IconData confirmIcon;

  @override
  Widget build(BuildContext context) {
    return InventoryDeleteConfirmationDialog(
      eyebrow: 'Unsaved Changes',
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      confirmIcon: confirmIcon,
      cancelLabel: 'Keep editing',
      cancelIcon: Icons.edit_rounded,
      closeTooltip: 'Close unsaved changes dialog',
      showCloseButton: true,
      onCancel: onCancel,
      onConfirm: onConfirm,
    );
  }
}

@Preview(name: 'Inventory unsaved changes dialog')
Widget inventoryUnsavedChangesDialogPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: InventoryUnsavedChangesDialog(
          title: 'Switch warehouse?',
          subtitle:
              'Switching warehouses will discard the current count sheet edits.',
          confirmLabel: 'Switch warehouse',
          confirmIcon: Icons.swap_horiz_rounded,
          onCancel: () {},
          onConfirm: () {},
        ),
      ),
    ),
  );
}
