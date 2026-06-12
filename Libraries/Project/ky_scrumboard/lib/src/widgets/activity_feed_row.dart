import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_activity.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'scrum_activity_presentation.dart';

/// Single activity feed row with type icon, task title, and metadata.
class ActivityFeedRow extends StatelessWidget {
  const ActivityFeedRow({
    super.key,
    required this.activity,
    required this.statusLabelFor,
    this.now,
  });

  final ScrumActivity activity;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final color = scrumActivityTypeColor(activity.type);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        border: Border.all(color: color.withValues(alpha: .14)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              scrumActivityTypeIcon(activity.type),
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scrumActivityTypeLabel(activity.type),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: ScrumBoardPalette.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.taskTitle ?? 'Board activity',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: ScrumBoardPalette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activityFeedMetaText(activity, statusLabelFor, now: now),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: ScrumBoardPalette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Preview for a single activity feed row.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Activity feed row',
  size: Size(360, 110),
)
Widget activityFeedRowPreview() {
  final now = DateTime(2026, 1, 2, 11);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 320,
          child: ActivityFeedRow(
            activity: ScrumActivity(
              id: 'activity-preview',
              type: ScrumActivityType.taskMoved,
              createdAt: DateTime(2026, 1, 2, 9),
              taskId: 'checkout',
              taskTitle: 'Checkout copy',
              fromStatus: ScrumTaskStatus.todo,
              toStatus: ScrumTaskStatus.review,
              actor: 'Alya',
            ),
            statusLabelFor: (status) => status.label,
            now: now,
          ),
        ),
      ),
    ),
  );
}

/// Human-readable metadata line for an activity feed row.
String activityFeedMetaText(
  ScrumActivity activity,
  String Function(ScrumTaskStatus status) statusLabelFor, {
  DateTime? now,
}) {
  final segments = <String>[];
  final note = activity.note?.trim();
  final actor = activity.actor?.trim();

  if (note != null && note.isNotEmpty) {
    segments.add(note);
  } else if (activity.fromStatus != null && activity.toStatus != null) {
    final fromLabel = statusLabelFor(activity.fromStatus!);
    final toLabel = statusLabelFor(activity.toStatus!);
    segments.add(fromLabel == toLabel ? toLabel : '$fromLabel to $toLabel');
  } else if (activity.toStatus != null) {
    segments.add(statusLabelFor(activity.toStatus!));
  } else if (activity.fromStatus != null) {
    segments.add(statusLabelFor(activity.fromStatus!));
  } else if (activity.fromPriority != null && activity.toPriority != null) {
    final fromLabel = activity.fromPriority!.label;
    final toLabel = activity.toPriority!.label;
    segments.add(fromLabel == toLabel ? toLabel : '$fromLabel to $toLabel');
  } else if (activity.toPriority != null) {
    segments.add(activity.toPriority!.label);
  } else if (activity.fromPriority != null) {
    segments.add(activity.fromPriority!.label);
  }

  if (actor != null && actor.isNotEmpty) segments.add(actor);
  segments.add(activityFeedTimeText(activity.createdAt, now: now));
  return segments.join(' - ');
}

/// Human-readable relative time for activity feed metadata.
String activityFeedTimeText(DateTime createdAt, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  if (createdAt.isAfter(currentTime)) return 'Just now';

  final elapsed = currentTime.difference(createdAt);
  if (elapsed.inMinutes < 1) return 'Just now';
  if (elapsed.inHours < 1) return '${elapsed.inMinutes}m ago';
  if (elapsed.inDays < 1) return '${elapsed.inHours}h ago';
  if (elapsed.inDays < 30) return '${elapsed.inDays}d ago';
  return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
}
