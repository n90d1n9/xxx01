import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';

import '../services/gantt_chart_view_reset_presentation_service.dart';

/// Reset row for returning Gantt view settings to their defaults.
class GanttChartViewResetTile extends StatelessWidget {
  const GanttChartViewResetTile({
    required this.isCustomized,
    required this.onReset,
    this.backgroundColor,
    super.key,
  });

  final bool isCustomized;
  final VoidCallback onReset;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final presentation = ganttChartViewResetPresentation(
      isCustomized: isCustomized,
    );
    final accentColor =
        isCustomized ? colorScheme.tertiary : colorScheme.onSurfaceVariant;

    return AppInfoRow(
      title: presentation.title,
      subtitle: presentation.subtitle,
      icon: presentation.icon,
      contained: true,
      iconStyle: AppInfoRowIconStyle.badge,
      backgroundColor: backgroundColor,
      borderColor:
          isCustomized
              ? colorScheme.tertiary.withValues(alpha: 0.34)
              : colorScheme.outlineVariant,
      iconBackgroundColor:
          isCustomized
              ? colorScheme.tertiaryContainer
              : colorScheme.surfaceContainerHighest,
      iconForegroundColor:
          isCustomized
              ? colorScheme.onTertiaryContainer
              : colorScheme.onSurfaceVariant,
      trailing: Tooltip(
        message: presentation.buttonTooltip,
        child: IconButton.outlined(
          key: const ValueKey('gantt-chart-view-reset-button'),
          visualDensity: VisualDensity.compact,
          color: accentColor,
          onPressed: isCustomized ? onReset : null,
          icon: const Icon(Icons.restart_alt_rounded),
        ),
      ),
    );
  }
}
