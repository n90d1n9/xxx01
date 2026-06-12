import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_dialog_actions.dart';
import '../../../widgets/ui/app_status_pill.dart';
import 'inventory_dialog_surface.dart';

/// Shared frame for product catalog bulk mutation dialogs with a status pill,
/// custom body content, and standard dialog actions.
class InventoryProductBulkMutationDialogLayout extends StatelessWidget {
  const InventoryProductBulkMutationDialogLayout({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusIcon,
    required this.children,
    required this.confirmLabel,
    required this.confirmIcon,
    required this.onConfirm,
    this.formKey,
    this.onCancel,
    this.closeTooltip = 'Close bulk mutation dialog',
    this.maxWidth = 600,
    this.statusMaxWidth = 170,
    this.statusColor,
    this.confirmVariant = AppActionButtonVariant.primary,
  });

  final GlobalKey<FormState>? formKey;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String statusLabel;
  final IconData statusIcon;
  final double statusMaxWidth;
  final Color? statusColor;
  final List<Widget> children;
  final String closeTooltip;
  final double maxWidth;
  final VoidCallback? onCancel;
  final String confirmLabel;
  final IconData confirmIcon;
  final AppActionButtonVariant confirmVariant;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        InventoryDialogHeader(
          eyebrow: eyebrow,
          title: title,
          subtitle: subtitle,
          closeTooltip: closeTooltip,
          onClose: onCancel,
        ),
        const SizedBox(height: 18),
        AppStatusPill(
          label: statusLabel,
          color: statusColor ?? Theme.of(context).colorScheme.primary,
          icon: statusIcon,
          maxWidth: statusMaxWidth,
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 20),
        AppDialogActions(
          cancelLabel: 'Cancel',
          cancelIcon: Icons.close_rounded,
          onCancel: onCancel,
          confirmLabel: confirmLabel,
          confirmIcon: confirmIcon,
          confirmVariant: confirmVariant,
          onConfirm: onConfirm,
        ),
      ],
    );

    return InventoryDialogSurface(
      maxWidth: maxWidth,
      child: formKey == null ? content : Form(key: formKey, child: content),
    );
  }
}

@Preview(name: 'Inventory product bulk mutation dialog layout')
Widget inventoryProductBulkMutationDialogLayoutPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: InventoryProductBulkMutationDialogLayout(
          eyebrow: 'Bulk Quality Repair',
          title: 'Generate missing SKUs',
          subtitle: 'Create unique SKUs for 4 selected products.',
          statusLabel: '4 missing SKU',
          statusIcon: Icons.tag_rounded,
          confirmLabel: 'Generate SKUs',
          confirmIcon: Icons.tag_rounded,
          onCancel: () {},
          onConfirm: () {},
          children: const [
            Text('SKU prefix'),
            SizedBox(height: 16),
            Text('SKU preview'),
          ],
        ),
      ),
    ),
  );
}
