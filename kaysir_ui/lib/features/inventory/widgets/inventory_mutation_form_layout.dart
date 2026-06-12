import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_dialog_actions.dart';
import 'inventory_form_fields.dart';

/// Reusable form shell for inventory mutation flows that share validation,
/// optional form-level errors, and standard dialog actions.
class InventoryMutationFormLayout extends StatelessWidget {
  const InventoryMutationFormLayout({
    super.key,
    required this.formKey,
    required this.children,
    required this.confirmLabel,
    required this.onSubmit,
    this.formError,
    this.onCancel,
    this.confirmIcon,
    this.cancelLabel = 'Cancel',
    this.cancelIcon = Icons.close_rounded,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.errorSpacing = 14,
    this.actionSpacing = 20,
  });

  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final String? formError;
  final String? cancelLabel;
  final IconData? cancelIcon;
  final VoidCallback? onCancel;
  final String confirmLabel;
  final IconData? confirmIcon;
  final VoidCallback? onSubmit;
  final AutovalidateMode autovalidateMode;
  final double errorSpacing;
  final double actionSpacing;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...children,
          if (formError != null) ...[
            SizedBox(height: errorSpacing),
            InventoryFormError(message: formError!),
          ],
          SizedBox(height: actionSpacing),
          AppDialogActions(
            cancelLabel: cancelLabel,
            cancelIcon: cancelIcon,
            onCancel: onCancel,
            confirmLabel: confirmLabel,
            confirmIcon: confirmIcon,
            onConfirm: onSubmit,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Inventory mutation form layout')
Widget inventoryMutationFormLayoutPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: InventoryMutationFormLayout(
              formKey: GlobalKey<FormState>(),
              confirmLabel: 'Apply change',
              confirmIcon: Icons.check_rounded,
              onSubmit: () {},
              onCancel: () {},
              children: const [
                InventoryFormTextField(
                  label: 'Quantity',
                  icon: Icons.tag_rounded,
                ),
                SizedBox(height: 12),
                InventoryFormTextField(
                  label: 'Notes',
                  icon: Icons.notes_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
