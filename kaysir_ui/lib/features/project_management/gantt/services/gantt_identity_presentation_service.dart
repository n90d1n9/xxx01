import '../states/gantt_chart_display_provider.dart';

/// Presentation metadata for taskbar tooltip detail choices.
class GanttTaskBarTooltipDetailPresentation {
  const GanttTaskBarTooltipDetailPresentation({
    required this.detail,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttTaskBarTooltipDetail detail;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

/// Presentation metadata for how many team avatars appear on a taskbar.
class GanttTeamAvatarCountPresentation {
  const GanttTeamAvatarCountPresentation({
    required this.count,
    required this.label,
    required this.tooltip,
  });

  final int count;
  final String label;
  final String tooltip;
}

/// Presentation metadata for team avatar sizing and prominence choices.
class GanttTeamAvatarStylePresentation {
  const GanttTeamAvatarStylePresentation({
    required this.style,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttTeamAvatarStyle style;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

const ganttTaskBarTooltipDetailPresentations = [
  GanttTaskBarTooltipDetailPresentation(
    detail: GanttTaskBarTooltipDetail.rich,
    label: 'Rich',
    summaryLabel: 'Rich shows full context',
    tooltip:
        'Rich tooltips include status, duration, dependencies, assignees, and clip hints.',
  ),
  GanttTaskBarTooltipDetailPresentation(
    detail: GanttTaskBarTooltipDetail.lean,
    label: 'Lean',
    summaryLabel: 'Lean trims extras',
    tooltip: 'Lean tooltips hide duration and clip hints for faster scanning.',
  ),
  GanttTaskBarTooltipDetailPresentation(
    detail: GanttTaskBarTooltipDetail.minimal,
    label: 'Minimal',
    summaryLabel: 'Minimal keeps it compact',
    tooltip: 'Minimal tooltips keep only the core task identity.',
  ),
];

const ganttTeamAvatarCountPresentations = [
  GanttTeamAvatarCountPresentation(
    count: 1,
    label: '1',
    tooltip: 'Show only the first assigned teammate on each taskbar.',
  ),
  GanttTeamAvatarCountPresentation(
    count: 2,
    label: '2',
    tooltip: 'Show up to two assigned teammates on each taskbar.',
  ),
  GanttTeamAvatarCountPresentation(
    count: 3,
    label: '3',
    tooltip: 'Show up to three assigned teammates on each taskbar.',
  ),
  GanttTeamAvatarCountPresentation(
    count: 4,
    label: '4',
    tooltip: 'Show up to four assigned teammates on each taskbar.',
  ),
  GanttTeamAvatarCountPresentation(
    count: 5,
    label: '5',
    tooltip: 'Show up to five assigned teammates on each taskbar.',
  ),
];

const ganttTeamAvatarStylePresentations = [
  GanttTeamAvatarStylePresentation(
    style: GanttTeamAvatarStyle.compact,
    label: 'Compact',
    summaryLabel: 'Compact saves space',
    tooltip: 'Compact avatars keep team presence visible on narrower bars.',
  ),
  GanttTeamAvatarStylePresentation(
    style: GanttTeamAvatarStyle.balanced,
    label: 'Balanced',
    summaryLabel: 'Balanced is standard',
    tooltip: 'Balanced avatars keep team ownership readable without crowding.',
  ),
  GanttTeamAvatarStylePresentation(
    style: GanttTeamAvatarStyle.prominent,
    label: 'Prominent',
    summaryLabel: 'Prominent highlights ownership',
    tooltip:
        'Prominent avatars increase size and overlap for team-first views.',
  ),
];

GanttTaskBarTooltipDetailPresentation ganttTaskBarTooltipDetailPresentation(
  GanttTaskBarTooltipDetail detail,
) {
  for (final presentation in ganttTaskBarTooltipDetailPresentations) {
    if (presentation.detail == detail) return presentation;
  }

  throw ArgumentError.value(detail, 'detail', 'Unknown tooltip detail');
}

GanttTeamAvatarCountPresentation ganttTeamAvatarCountPresentation(int count) {
  for (final presentation in ganttTeamAvatarCountPresentations) {
    if (presentation.count == count) return presentation;
  }

  throw ArgumentError.value(count, 'count', 'Unknown avatar count');
}

GanttTeamAvatarStylePresentation ganttTeamAvatarStylePresentation(
  GanttTeamAvatarStyle style,
) {
  for (final presentation in ganttTeamAvatarStylePresentations) {
    if (presentation.style == style) return presentation;
  }

  throw ArgumentError.value(style, 'style', 'Unknown avatar style');
}

String ganttTaskBarTooltipDetailSettingsSubtitle() {
  return ganttTaskBarTooltipDetailPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

String ganttTeamAvatarCountSettingsSubtitle() {
  return 'Limit visible avatars from 1 to 5 teammates';
}

String ganttTeamAvatarStyleSettingsSubtitle() {
  return ganttTeamAvatarStylePresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}
