import 'package:flutter/material.dart';

import '../states/gantt_chart_display_provider.dart';
import '../states/gantt_chart_interaction_provider.dart';
import 'gantt_chart_identity_option_tiles.dart';
import 'gantt_chart_interaction_option_tiles.dart';
import 'gantt_chart_profile_option_tiles.dart';
import 'gantt_chart_selection_option_tiles.dart';
import 'gantt_chart_taskbar_option_tiles.dart';
import 'gantt_chart_timeline_option_tiles.dart';

class GanttChartDisplayOptionsBar extends StatelessWidget {
  const GanttChartDisplayOptionsBar({
    required this.displayPreferences,
    required this.onDisplayChanged,
    required this.interactionPreferences,
    required this.onInteractionChanged,
    super.key,
  });

  final GanttChartDisplayPreferences displayPreferences;
  final ValueChanged<GanttChartDisplayPreferences> onDisplayChanged;
  final GanttChartInteractionPreferences interactionPreferences;
  final ValueChanged<GanttChartInteractionPreferences> onInteractionChanged;

  @override
  Widget build(BuildContext context) {
    return _GanttOptionGrid(
      children: [
        ...ganttChartProfileOptionTiles(
          context: context,
          displayPreferences: displayPreferences,
          onDisplayChanged: onDisplayChanged,
          interactionPreferences: interactionPreferences,
          onInteractionChanged: onInteractionChanged,
        ),
        ...ganttChartInteractionOptionTiles(
          context: context,
          interactionPreferences: interactionPreferences,
          onInteractionChanged: onInteractionChanged,
        ),
        ...ganttChartIdentityOptionTiles(
          context: context,
          displayPreferences: displayPreferences,
          onDisplayChanged: onDisplayChanged,
        ),
        ...ganttChartTimelineOptionTiles(
          context: context,
          displayPreferences: displayPreferences,
          onDisplayChanged: onDisplayChanged,
        ),
        ...ganttChartTaskBarOptionTiles(
          context: context,
          displayPreferences: displayPreferences,
          onDisplayChanged: onDisplayChanged,
        ),
        ...ganttChartSelectionOptionTiles(
          context: context,
          displayPreferences: displayPreferences,
          onDisplayChanged: onDisplayChanged,
        ),
      ],
    );
  }
}

class _GanttOptionGrid extends StatelessWidget {
  const _GanttOptionGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                children[index],
              ],
            ],
          );
        }

        const spacing = 12.0;
        final columnCount =
            constraints.maxWidth >= 1180
                ? 4
                : constraints.maxWidth >= 720
                ? 3
                : 1;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columnCount - 1))) /
            columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
