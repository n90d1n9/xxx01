import 'package:flutter/material.dart';

import 'app_action_button.dart';

class AppDialogActions extends StatelessWidget {
  const AppDialogActions({
    super.key,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel,
    this.onCancel,
    this.confirmIcon,
    this.cancelIcon,
    this.confirmVariant = AppActionButtonVariant.primary,
    this.cancelVariant = AppActionButtonVariant.text,
    this.spacing = 8,
  });

  final String confirmLabel;
  final VoidCallback? onConfirm;
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final IconData? confirmIcon;
  final IconData? cancelIcon;
  final AppActionButtonVariant confirmVariant;
  final AppActionButtonVariant cancelVariant;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final actions = [
      if (cancelLabel != null)
        AppActionButton(
          label: cancelLabel!,
          icon: cancelIcon,
          variant: cancelVariant,
          onPressed: onCancel,
        ),
      AppActionButton(
        label: confirmLabel,
        icon: confirmIcon,
        variant: confirmVariant,
        onPressed: onConfirm,
      ),
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: spacing,
        runSpacing: spacing,
        children: actions,
      ),
    );
  }
}
