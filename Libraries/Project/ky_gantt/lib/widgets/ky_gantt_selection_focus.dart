import 'package:flutter/material.dart';

List<BoxShadow> kyGanttSelectedTaskFocusShadows(ColorScheme colorScheme) {
  return [
    BoxShadow(
      color: colorScheme.primary.withValues(alpha: 0.18),
      blurRadius: 18,
      spreadRadius: 1,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: colorScheme.primary.withValues(alpha: 0.10),
      blurRadius: 0,
      spreadRadius: 2,
    ),
  ];
}
