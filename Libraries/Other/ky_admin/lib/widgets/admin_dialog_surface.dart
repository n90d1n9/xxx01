import 'dart:math' as math;

import 'package:flutter/material.dart';

class AdminDialogSurface extends StatelessWidget {
  const AdminDialogSurface({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.minWidth = 320,
    this.maxHeight = 640,
    this.margin = const EdgeInsets.all(20),
  });

  final Widget child;
  final double maxWidth;
  final double minWidth;
  final double maxHeight;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final availableSize = MediaQuery.sizeOf(context);
    final availableWidth = math.max(
      0.0,
      availableSize.width - margin.horizontal,
    );
    final availableHeight = math.max(
      0.0,
      availableSize.height - margin.vertical,
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: math.min(minWidth, availableWidth),
          maxWidth: math.min(maxWidth, availableWidth),
          maxHeight: math.min(maxHeight, availableHeight),
        ),
        child: Material(
          color: colorScheme.surface,
          elevation: 18,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}
