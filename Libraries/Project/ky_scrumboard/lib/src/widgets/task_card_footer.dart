import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'scrum_task_signal_badges.dart';

/// Footer for a scrum task card with assignee and optional signal badges.
class ScrumTaskCardFooter extends StatelessWidget {
  const ScrumTaskCardFooter({
    super.key,
    required this.task,
    this.dueSoonDays = 2,
    this.reviewAgeWarningDays = 3,
    this.statusStartedAt,
    this.statusLabel,
    this.now,
  });

  final ScrumTask task;
  final int dueSoonDays;
  final int reviewAgeWarningDays;
  final DateTime? statusStartedAt;
  final String? statusLabel;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ScrumTaskAssigneeAvatar(
              name: task.assignee,
              color: task.accentColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.assignee,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium?.copyWith(
                  color: ScrumBoardPalette.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        _ScrumTaskSignalBadgeSection(
          task: task,
          dueSoonDays: dueSoonDays,
          reviewAgeWarningDays: reviewAgeWarningDays,
          statusStartedAt: statusStartedAt,
          statusLabel: statusLabel,
          now: now,
        ),
      ],
    );
  }
}

/// Preview for task-card assignee and signal footer.
@Preview(group: 'Ky Scrumboard', name: 'Task card footer', size: Size(340, 150))
Widget scrumTaskCardFooterPreview() {
  final now = DateTime(2026, 1, 10);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 300,
          child: ScrumTaskCardFooter(
            task: ScrumTask(
              id: 'footer-preview',
              title: 'Footer preview',
              description: 'Preview card footer signals.',
              assignee: 'Alya Rahman',
              storyPoints: 5,
              createdAt: DateTime(2026, 1, 3),
              dueAt: now.add(const Duration(days: 1)),
              status: ScrumTaskStatus.review,
              priority: ScrumTaskPriority.high,
              accentColor: const Color(0xFF2563EB),
            ),
            statusStartedAt: DateTime(2026, 1, 6),
            statusLabel: 'Review',
            now: now,
          ),
        ),
      ),
    ),
  );
}

/// Signal badge wrapper that keeps footer spacing consistent.
class _ScrumTaskSignalBadgeSection extends StatelessWidget {
  const _ScrumTaskSignalBadgeSection({
    required this.task,
    required this.dueSoonDays,
    required this.reviewAgeWarningDays,
    this.statusStartedAt,
    this.statusLabel,
    this.now,
  });

  final ScrumTask task;
  final int dueSoonDays;
  final int reviewAgeWarningDays;
  final DateTime? statusStartedAt;
  final String? statusLabel;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    if (!ScrumTaskSignalBadges.hasSignalsFor(
      task,
      dueSoonDays: dueSoonDays,
      reviewAgeWarningDays: reviewAgeWarningDays,
      statusStartedAt: statusStartedAt,
      now: now,
    )) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ScrumTaskSignalBadges(
        task: task,
        dueSoonDays: dueSoonDays,
        reviewAgeWarningDays: reviewAgeWarningDays,
        statusStartedAt: statusStartedAt,
        statusLabel: statusLabel,
        now: now,
      ),
    );
  }
}

/// Initials avatar for the task-card assignee row.
class _ScrumTaskAssigneeAvatar extends StatelessWidget {
  const _ScrumTaskAssigneeAvatar({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: color.withValues(alpha: .12),
      child: Text(
        _initials(name),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
