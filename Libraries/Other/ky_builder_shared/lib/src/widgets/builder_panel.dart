import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Provides a compact framed container for builder previews and inline panels.
class KyBuilderPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double backgroundAlpha;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final bool clipContent;

  const KyBuilderPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 8,
    this.backgroundAlpha = 0.36,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.clipContent = false,
  });

  @Preview(name: 'Builder panel')
  const KyBuilderPanel.preview({super.key})
    : child = const Text('Preview content'),
      padding = const EdgeInsets.all(16),
      radius = 8,
      backgroundAlpha = 0.36,
      color = null,
      borderColor = null,
      borderWidth = 1,
      clipContent = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(radius);
    Widget content = Padding(padding: padding, child: child);

    if (clipContent) {
      content = ClipRRect(borderRadius: borderRadius, child: content);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            color ??
            colorScheme.surfaceContainerHighest.withValues(
              alpha: backgroundAlpha,
            ),
        border: Border.all(
          color: borderColor ?? colorScheme.outlineVariant,
          width: borderWidth,
        ),
        borderRadius: borderRadius,
      ),
      child: content,
    );
  }
}
