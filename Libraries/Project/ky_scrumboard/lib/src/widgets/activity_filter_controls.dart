import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_activity.dart';
import '../scrum_board_palette.dart';
import 'scrum_activity_presentation.dart';

/// Filter chip row for narrowing an activity timeline by activity type.
class ActivityFilterControls extends StatelessWidget {
  const ActivityFilterControls({
    super.key,
    required this.activities,
    required this.selectedType,
    required this.onSelectedTypeChanged,
  });

  final List<ScrumActivity> activities;
  final ScrumActivityType? selectedType;
  final ValueChanged<ScrumActivityType?> onSelectedTypeChanged;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();

    final counts = activityTypeCounts(activities);
    final visibleTypes = orderedVisibleActivityTypes(counts);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ActivityFilterChip(
          label: 'All ${activities.length}',
          icon: Icons.history_rounded,
          color: const Color(0xFF475569),
          selected: selectedType == null,
          onSelected: () => onSelectedTypeChanged(null),
        ),
        for (final type in visibleTypes)
          ActivityFilterChip(
            label: '${scrumActivityTypeLabel(type)} ${counts[type]}',
            icon: scrumActivityTypeIcon(type),
            color: scrumActivityTypeColor(type),
            selected: selectedType == type,
            onSelected: () => onSelectedTypeChanged(type),
          ),
      ],
    );
  }
}

/// Preview for activity timeline filter controls.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Activity filter controls',
  size: Size(420, 120),
)
Widget activityFilterControlsPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ActivityFilterControls(
          activities: [
            ScrumActivity(
              id: 'moved',
              type: ScrumActivityType.taskMoved,
              createdAt: DateTime(2026, 1, 2, 9),
            ),
            ScrumActivity(
              id: 'priority',
              type: ScrumActivityType.taskPriorityChanged,
              createdAt: DateTime(2026, 1, 2, 10),
            ),
            ScrumActivity(
              id: 'note',
              type: ScrumActivityType.taskCommented,
              createdAt: DateTime(2026, 1, 2, 11),
            ),
          ],
          selectedType: ScrumActivityType.taskMoved,
          onSelectedTypeChanged: (_) {},
        ),
      ),
    ),
  );
}

/// Single compact filter chip used by the activity timeline filter row.
class ActivityFilterChip extends StatelessWidget {
  const ActivityFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: ChoiceChip(
        avatar: Icon(icon, size: 15, color: color),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(label, overflow: TextOverflow.ellipsis),
        ),
        selected: selected,
        onSelected: (_) => onSelected(),
        labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: selected ? color : ScrumBoardPalette.mutedInk,
          fontWeight: FontWeight.w800,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: color.withValues(alpha: .12),
        side: BorderSide(
          color: selected
              ? color.withValues(alpha: .35)
              : ScrumBoardPalette.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Counts activities by type for timeline filter labels.
Map<ScrumActivityType, int> activityTypeCounts(
  Iterable<ScrumActivity> activities,
) {
  final counts = <ScrumActivityType, int>{};
  for (final activity in activities) {
    counts.update(activity.type, (count) => count + 1, ifAbsent: () => 1);
  }
  return counts;
}

/// Orders visible activity types by the enum order used across the package.
List<ScrumActivityType> orderedVisibleActivityTypes(
  Map<ScrumActivityType, int> counts,
) {
  return [
    for (final type in ScrumActivityType.values)
      if ((counts[type] ?? 0) > 0) type,
  ];
}

/// Filters activities by a selected type, or returns all activities.
List<ScrumActivity> filterActivitiesByType(
  List<ScrumActivity> activities,
  ScrumActivityType? selectedType,
) {
  if (selectedType == null) return activities;
  return activities
      .where((activity) => activity.type == selectedType)
      .toList(growable: false);
}
