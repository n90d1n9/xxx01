import 'package:flutter/material.dart';

class OrderSavedWorkspaceActionMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isDestructive;

  const OrderSavedWorkspaceActionMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor =
        color ??
        (isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: effectiveColor),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: effectiveColor)),
      ],
    );
  }
}
