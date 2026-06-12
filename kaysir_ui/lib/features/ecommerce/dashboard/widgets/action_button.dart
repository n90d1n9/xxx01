import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

enum ActionButtonVariant { plain, outlined, tonal, primary }

class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.variant = ActionButtonVariant.tonal,
    this.iconSize,
    this.tooltip,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final ActionButtonVariant variant;
  final double? iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        const Size(0, POSUiTokens.controlHeight),
      ),
      padding: WidgetStateProperty.all(POSUiTokens.controlPadding),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
        ),
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
    final iconWidget = Icon(icon, size: iconSize);

    final button = switch (variant) {
      ActionButtonVariant.plain => TextButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: Text(label),
        style: style,
      ),
      ActionButtonVariant.outlined => OutlinedButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: Text(label),
        style: style,
      ),
      ActionButtonVariant.tonal => FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: iconWidget,
        label: Text(label),
        style: style,
      ),
      ActionButtonVariant.primary => FilledButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: Text(label),
        style: style,
      ),
    };

    final message = tooltip?.trim();
    if (message == null || message.isEmpty) return button;

    return Tooltip(message: message, child: button);
  }
}
