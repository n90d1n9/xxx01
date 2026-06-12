import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_activity.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'activity_filter_controls.dart';
import 'scrum_activity_feed.dart';

/// Timeline section with activity type filters and a compact activity feed.
class ScrumActivityTimelineSection extends StatefulWidget {
  const ScrumActivityTimelineSection({
    super.key,
    required this.activities,
    required this.statusLabelFor,
    this.title = 'Recent activity',
    this.now,
  });

  final List<ScrumActivity> activities;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final String title;
  final DateTime? now;

  @override
  State<ScrumActivityTimelineSection> createState() =>
      _ScrumActivityTimelineSectionState();
}

class _ScrumActivityTimelineSectionState
    extends State<ScrumActivityTimelineSection> {
  ScrumActivityType? _selectedType;

  @override
  void didUpdateWidget(covariant ScrumActivityTimelineSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedType == null) return;
    if (activityTypeCounts(widget.activities).containsKey(_selectedType)) {
      return;
    }
    _selectedType = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activities.isEmpty) return const SizedBox.shrink();

    final filteredActivities = filterActivitiesByType(
      widget.activities,
      _selectedType,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: ScrumBoardPalette.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        ActivityFilterControls(
          activities: widget.activities,
          selectedType: _selectedType,
          onSelectedTypeChanged: (type) => setState(() => _selectedType = type),
        ),
        const SizedBox(height: 10),
        ScrumActivityFeed(
          activities: filteredActivities,
          statusLabelFor: widget.statusLabelFor,
          showEmptyState: false,
          now: widget.now,
        ),
      ],
    );
  }
}

/// Preview for the activity timeline section.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Activity timeline',
  size: Size(380, 320),
)
Widget scrumActivityTimelineSectionPreview() {
  final now = DateTime(2026, 1, 2, 12);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 340,
          child: ScrumActivityTimelineSection(
            activities: [
              ScrumActivity(
                id: 'moved',
                type: ScrumActivityType.taskMoved,
                createdAt: DateTime(2026, 1, 2, 9),
                taskId: 'checkout',
                taskTitle: 'Checkout copy',
                fromStatus: ScrumTaskStatus.todo,
                toStatus: ScrumTaskStatus.review,
              ),
              ScrumActivity(
                id: 'priority',
                type: ScrumActivityType.taskPriorityChanged,
                createdAt: DateTime(2026, 1, 2, 11),
                taskId: 'risk',
                taskTitle: 'Risk review',
              ),
            ],
            statusLabelFor: (status) => status.label,
            now: now,
          ),
        ),
      ),
    ),
  );
}
