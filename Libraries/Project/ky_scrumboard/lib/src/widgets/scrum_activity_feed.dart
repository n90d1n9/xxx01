import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_activity.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'activity_feed_row.dart';

/// Vertical list of recent board activity rows.
class ScrumActivityFeed extends StatelessWidget {
  const ScrumActivityFeed({
    super.key,
    required this.activities,
    required this.statusLabelFor,
    this.showEmptyState = true,
    this.now,
  });

  final List<ScrumActivity> activities;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final bool showEmptyState;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      if (!showEmptyState) return const SizedBox.shrink();

      return Text(
        'No board activity yet.',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: ScrumBoardPalette.mutedInk),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < activities.length; index += 1) ...[
          ActivityFeedRow(
            activity: activities[index],
            statusLabelFor: statusLabelFor,
            now: now,
          ),
          if (index < activities.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Preview for the activity feed list.
@Preview(group: 'Ky Scrumboard', name: 'Activity feed', size: Size(360, 220))
Widget scrumActivityFeedPreview() {
  final now = DateTime(2026, 1, 2, 12);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 320,
          child: ScrumActivityFeed(
            activities: [
              ScrumActivity(
                id: 'activity-1',
                type: ScrumActivityType.taskMoved,
                createdAt: DateTime(2026, 1, 2, 9),
                taskId: 'checkout',
                taskTitle: 'Checkout copy',
                fromStatus: ScrumTaskStatus.todo,
                toStatus: ScrumTaskStatus.review,
                actor: 'Alya',
              ),
              ScrumActivity(
                id: 'activity-2',
                type: ScrumActivityType.taskCommented,
                createdAt: DateTime(2026, 1, 2, 11, 30),
                taskId: 'release',
                taskTitle: 'Release handoff',
                note: 'Waiting on design review.',
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
