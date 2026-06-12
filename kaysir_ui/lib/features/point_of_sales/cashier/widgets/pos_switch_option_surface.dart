import 'package:flutter/material.dart';

import 'pos_ui.dart';

class POSSwitchOptionSurface extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const POSSwitchOptionSurface({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.margin = const EdgeInsets.only(bottom: POSUiTokens.gap),
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = colorScheme.primaryContainer.withValues(alpha: 0.34);
    final borderColor =
        selected
            ? colorScheme.primary.withValues(alpha: 0.2)
            : colorScheme.outlineVariant.withValues(alpha: 0.72);
    final radius = BorderRadius.circular(POSUiTokens.radius);

    return Padding(
      padding: margin,
      child: Material(
        color: selected ? selectedColor : colorScheme.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: borderColor),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
