import 'package:flutter/material.dart';

/// Rounded text pill for compact FnB status labels.
class FnbStatusPill extends StatelessWidget {
  const FnbStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    this.maxWidth = 180,
    this.backgroundAlpha = .1,
    this.borderAlpha = .2,
  }) : assert(maxWidth > 0, 'maxWidth must be greater than zero.');

  final String label;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double maxWidth;
  final double backgroundAlpha;
  final double borderAlpha;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: backgroundAlpha),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: borderAlpha)),
        ),
        child: Padding(
          padding: padding,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
