import 'package:flutter/material.dart';

class AdminShortcutHint extends StatelessWidget {
  const AdminShortcutHint({
    super.key,
    required this.label,
    this.icon,
    this.semanticLabel,
  });

  final String label;
  final IconData? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    return Semantics(
      label: semanticLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 3),
            ],
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}
