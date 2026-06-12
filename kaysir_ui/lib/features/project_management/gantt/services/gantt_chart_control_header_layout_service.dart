import 'dart:ui';

/// Responsive layout decisions for the full-screen Gantt control header.
class GanttChartControlHeaderLayout {
  const GanttChartControlHeaderLayout({
    required this.expandedControlsMaxHeight,
    required this.useCompactHeaderActions,
  });

  final double expandedControlsMaxHeight;
  final bool useCompactHeaderActions;
}

/// Calculates responsive header layout values from viewport and focus state.
class GanttChartControlHeaderLayoutService {
  const GanttChartControlHeaderLayoutService();

  static const compactActionBreakpoint = 700.0;
  static const minExpandedControlsHeight = 160.0;
  static const maxExpandedControlsHeight = 280.0;
  static const focusedHeightFactor = 0.28;
  static const defaultHeightFactor = 0.32;

  GanttChartControlHeaderLayout layoutFor({
    required Size viewportSize,
    required bool hasActiveFocus,
  }) {
    final heightFactor =
        hasActiveFocus ? focusedHeightFactor : defaultHeightFactor;
    final expandedControlsMaxHeight =
        (viewportSize.height * heightFactor)
            .clamp(minExpandedControlsHeight, maxExpandedControlsHeight)
            .toDouble();

    return GanttChartControlHeaderLayout(
      expandedControlsMaxHeight: expandedControlsMaxHeight,
      useCompactHeaderActions: viewportSize.width < compactActionBreakpoint,
    );
  }
}
