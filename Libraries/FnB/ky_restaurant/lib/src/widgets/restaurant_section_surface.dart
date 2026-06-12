import 'package:flutter/material.dart';

/// Applies reusable section chrome for grouped restaurant workspace content.
class RestaurantSectionSurface extends StatelessWidget {
  const RestaurantSectionSurface({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 8,
    this.borderWidth = 1,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            colors.surfaceContainerHighest.withValues(alpha: .28),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? colors.outlineVariant.withValues(alpha: .55),
          width: borderWidth,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
