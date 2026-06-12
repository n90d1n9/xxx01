import 'package:flutter/material.dart';

/// Presentation metadata for the view settings reset row.
class GanttChartViewResetPresentation {
  const GanttChartViewResetPresentation({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonTooltip,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonTooltip;
}

const _customizedResetPresentation = GanttChartViewResetPresentation(
  title: 'View Defaults',
  subtitle: 'Custom preferences active',
  icon: Icons.tune_outlined,
  buttonTooltip: 'Reset view defaults',
);

const _defaultResetPresentation = GanttChartViewResetPresentation(
  title: 'View Defaults',
  subtitle: 'Default preferences active',
  icon: Icons.check_circle_outline_rounded,
  buttonTooltip: 'Reset view defaults',
);

GanttChartViewResetPresentation ganttChartViewResetPresentation({
  required bool isCustomized,
}) {
  return isCustomized
      ? _customizedResetPresentation
      : _defaultResetPresentation;
}
