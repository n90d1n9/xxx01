import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

enum GanttTaskDragPreviewTone { ready, check, blocked }

class GanttTaskDragPreviewVisuals {
  const GanttTaskDragPreviewVisuals({
    required this.tone,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.accent,
    required this.border,
    required this.shadow,
    required this.shadowBlur,
    required this.shadowOffset,
  });

  final GanttTaskDragPreviewTone tone;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color accent;
  final Color border;
  final Color shadow;
  final double shadowBlur;
  final Offset shadowOffset;

  static GanttTaskDragPreviewVisuals from(
    ColorScheme colorScheme,
    ky.KyGanttTaskDateRangeValidation validation,
  ) {
    switch (validation.severity) {
      case ky.KyGanttTaskDateRangeValidationSeverity.valid:
        return GanttTaskDragPreviewVisuals(
          tone: GanttTaskDragPreviewTone.ready,
          icon: Icons.open_with_rounded,
          background: colorScheme.inverseSurface.withValues(alpha: 0.96),
          foreground: colorScheme.onInverseSurface,
          accent: colorScheme.primaryContainer,
          border: colorScheme.outline.withValues(alpha: 0.18),
          shadow: colorScheme.shadow.withValues(alpha: 0.22),
          shadowBlur: 22,
          shadowOffset: const Offset(0, 12),
        );
      case ky.KyGanttTaskDateRangeValidationSeverity.warning:
        return GanttTaskDragPreviewVisuals(
          tone: GanttTaskDragPreviewTone.check,
          icon: Icons.warning_amber_rounded,
          background: colorScheme.tertiaryContainer.withValues(alpha: 0.98),
          foreground: colorScheme.onTertiaryContainer,
          accent: colorScheme.tertiary,
          border: colorScheme.tertiary.withValues(alpha: 0.32),
          shadow: colorScheme.tertiary.withValues(alpha: 0.20),
          shadowBlur: 24,
          shadowOffset: const Offset(0, 13),
        );
      case ky.KyGanttTaskDateRangeValidationSeverity.error:
        return GanttTaskDragPreviewVisuals(
          tone: GanttTaskDragPreviewTone.blocked,
          icon: Icons.block_rounded,
          background: colorScheme.errorContainer.withValues(alpha: 0.98),
          foreground: colorScheme.onErrorContainer,
          accent: colorScheme.error,
          border: colorScheme.error.withValues(alpha: 0.34),
          shadow: colorScheme.error.withValues(alpha: 0.22),
          shadowBlur: 26,
          shadowOffset: const Offset(0, 14),
        );
    }
  }
}
