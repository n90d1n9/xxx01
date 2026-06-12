import 'package:flutter/material.dart';

class InventoryDataTableSurface extends StatelessWidget {
  const InventoryDataTableSurface({
    super.key,
    required this.child,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 8,
  });

  final Widget child;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: Border.all(color: borderColor ?? colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: child,
          ),
        ),
      ),
    );

    if (height == null) return surface;

    return SizedBox(height: height, child: surface);
  }
}
