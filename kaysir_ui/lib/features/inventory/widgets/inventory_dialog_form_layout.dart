import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_dialog_actions.dart';
import 'inventory_dialog_surface.dart';
import 'inventory_form_fields.dart';

/// Reusable shell for inventory dialogs that combine a header, form body,
/// validation error, and standard dialog actions.
class InventoryDialogFormLayout extends StatelessWidget {
  const InventoryDialogFormLayout({
    super.key,
    required this.formKey,
    required this.eyebrow,
    required this.title,
    required this.children,
    required this.confirmLabel,
    required this.onConfirm,
    this.subtitle,
    this.formError,
    this.maxWidth = 640,
    this.maxHeight,
    this.onCancel,
    this.closeTooltip = 'Close dialog',
    this.subtitleMaxLines = 2,
    this.cancelLabel = 'Cancel',
    this.confirmIcon,
    this.cancelIcon = Icons.close_rounded,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final GlobalKey<FormState> formKey;
  final String eyebrow;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final String? formError;
  final double maxWidth;
  final double? maxHeight;
  final VoidCallback? onCancel;
  final String closeTooltip;
  final int subtitleMaxLines;
  final String? cancelLabel;
  final String confirmLabel;
  final VoidCallback? onConfirm;
  final IconData? confirmIcon;
  final IconData? cancelIcon;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return InventoryDialogSurface(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      child: Form(
        key: formKey,
        autovalidateMode: autovalidateMode,
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
              onClose: onCancel,
            ),
            const SizedBox(height: 18),
            ...children,
            if (formError != null) ...[
              const SizedBox(height: 14),
              InventoryFormError(message: formError!),
            ],
            const SizedBox(height: 20),
            AppDialogActions(
              cancelLabel: cancelLabel,
              cancelIcon: cancelIcon,
              onCancel: onCancel,
              confirmLabel: confirmLabel,
              confirmIcon: confirmIcon,
              onConfirm: onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Inventory dialog form layout')
Widget inventoryDialogFormLayoutPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: InventoryDialogFormLayout(
          formKey: GlobalKey<FormState>(),
          eyebrow: 'Inventory Setup',
          title: 'Add Product',
          subtitle: 'Create a reusable product profile for stock operations.',
          confirmLabel: 'Save product',
          confirmIcon: Icons.check_rounded,
          onConfirm: () {},
          onCancel: () {},
          children: const [
            InventoryFormTextField(label: 'Product name'),
            SizedBox(height: 12),
            InventoryFormTextField(label: 'SKU'),
          ],
        ),
      ),
    ),
  );
}
