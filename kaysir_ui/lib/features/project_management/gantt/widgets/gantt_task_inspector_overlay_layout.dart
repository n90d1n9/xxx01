import 'package:flutter/widgets.dart';

import '../states/gantt_chart_interaction_provider.dart';

class GanttTaskInspectorOverlayLayout {
  const GanttTaskInspectorOverlayLayout({
    required this.resolvedPlacement,
    required this.padding,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.alignment,
  });

  final GanttTaskInspectorPlacement resolvedPlacement;
  final double padding;
  final double sheetWidth;
  final double sheetHeight;
  final Alignment alignment;

  bool get isBottomSheet =>
      resolvedPlacement == GanttTaskInspectorPlacement.bottom;

  static GanttTaskInspectorOverlayLayout resolve({
    required BoxConstraints constraints,
    required GanttTaskInspectorPlacement placement,
  }) {
    final isCompact = constraints.maxWidth < 720;
    final resolvedPlacement =
        placement == GanttTaskInspectorPlacement.adaptive
            ? isCompact
                ? GanttTaskInspectorPlacement.bottom
                : GanttTaskInspectorPlacement.side
            : placement;
    final isBottomSheet =
        resolvedPlacement == GanttTaskInspectorPlacement.bottom;
    final padding = isCompact ? 8.0 : 12.0;
    final availableWidth =
        (constraints.maxWidth - padding * 2)
            .clamp(0.0, constraints.maxWidth)
            .toDouble();
    final availableHeight =
        (constraints.maxHeight - padding * 2)
            .clamp(0.0, constraints.maxHeight)
            .toDouble();
    final bottomSheetTargetHeight =
        constraints.maxHeight * (isCompact ? 0.84 : 0.58);
    final minBottomSheetHeight =
        availableHeight < 320 ? availableHeight : 320.0;
    final sheetHeight =
        isBottomSheet
            ? bottomSheetTargetHeight
                .clamp(minBottomSheetHeight, availableHeight)
                .toDouble()
            : availableHeight;
    final sideSheetWidth = availableWidth < 480 ? availableWidth : 480.0;
    final bottomSheetWidth =
        isCompact || availableWidth < 720 ? availableWidth : 720.0;

    return GanttTaskInspectorOverlayLayout(
      resolvedPlacement: resolvedPlacement,
      padding: padding,
      sheetWidth: isBottomSheet ? bottomSheetWidth : sideSheetWidth,
      sheetHeight: sheetHeight,
      alignment: isBottomSheet ? Alignment.bottomCenter : Alignment.centerRight,
    );
  }
}
