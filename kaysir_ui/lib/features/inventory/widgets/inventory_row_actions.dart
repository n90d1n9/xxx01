import 'package:flutter/material.dart';

import '../../../widgets/ui/app_icon_action_button.dart';

class InventoryRowAction {
  const InventoryRowAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.variant,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AppIconActionButtonVariant? variant;
}

class InventoryRowActions extends StatelessWidget {
  const InventoryRowActions({
    super.key,
    required this.actions,
    this.spacing = 4,
    this.runSpacing = 4,
    this.variant = AppIconActionButtonVariant.outlined,
  });

  final List<InventoryRowAction> actions;
  final double spacing;
  final double runSpacing;
  final AppIconActionButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (final action in actions)
          AppIconActionButton(
            icon: action.icon,
            tooltip: action.tooltip,
            variant: action.variant ?? variant,
            onPressed: action.onPressed,
          ),
      ],
    );
  }
}
