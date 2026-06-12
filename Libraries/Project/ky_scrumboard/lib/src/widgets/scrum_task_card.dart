import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'task_card_footer.dart';
import 'task_card_header.dart';

/// Draggable scrumboard task card with selection, metadata, and signal badges.
class ScrumTaskCard extends StatelessWidget {
  const ScrumTaskCard({
    super.key,
    required this.task,
    required this.onPressed,
    this.selected = false,
    this.onSelectedChanged,
    this.dueSoonDays = 2,
    this.reviewAgeWarningDays = 3,
    this.statusStartedAt,
    this.statusLabel,
    this.now,
  });

  final ScrumTask task;
  final VoidCallback onPressed;
  final bool selected;
  final ValueChanged<bool>? onSelectedChanged;
  final int dueSoonDays;
  final int reviewAgeWarningDays;
  final DateTime? statusStartedAt;
  final String? statusLabel;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: task.id,
      feedback: SizedBox(
        width: 292,
        child: _ScrumTaskCardSurface(
          task: task,
          selected: selected,
          dueSoonDays: dueSoonDays,
          reviewAgeWarningDays: reviewAgeWarningDays,
          statusStartedAt: statusStartedAt,
          statusLabel: statusLabel,
          now: now,
          elevated: true,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: .42,
        child: _ScrumTaskCardSurface(
          task: task,
          selected: selected,
          dueSoonDays: dueSoonDays,
          reviewAgeWarningDays: reviewAgeWarningDays,
          statusStartedAt: statusStartedAt,
          statusLabel: statusLabel,
          now: now,
          onPressed: onPressed,
          onSelectedChanged: onSelectedChanged,
        ),
      ),
      child: _ScrumTaskCardSurface(
        task: task,
        selected: selected,
        dueSoonDays: dueSoonDays,
        reviewAgeWarningDays: reviewAgeWarningDays,
        statusStartedAt: statusStartedAt,
        statusLabel: statusLabel,
        now: now,
        onPressed: onPressed,
        onSelectedChanged: onSelectedChanged,
      ),
    );
  }
}

/// Preview for the complete task card in a selected state.
@Preview(group: 'Ky Scrumboard', name: 'Task card', size: Size(360, 300))
Widget scrumTaskCardPreview() {
  final now = DateTime(2026, 1, 10);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 320,
          child: ScrumTaskCard(
            task: ScrumTask(
              id: 'card-preview',
              title: 'Checkout readiness review',
              description: 'Validate payment copy and final release signals.',
              assignee: 'Alya Rahman',
              storyPoints: 5,
              createdAt: DateTime(2026, 1, 3),
              dueAt: now.add(const Duration(days: 1)),
              status: ScrumTaskStatus.review,
              priority: ScrumTaskPriority.high,
              label: 'Payments',
              accentColor: const Color(0xFF2563EB),
            ),
            selected: true,
            statusStartedAt: DateTime(2026, 1, 6),
            statusLabel: 'Review',
            now: now,
            onPressed: () {},
            onSelectedChanged: (_) {},
          ),
        ),
      ),
    ),
  );
}

class _ScrumTaskCardSurface extends StatelessWidget {
  const _ScrumTaskCardSurface({
    required this.task,
    required this.selected,
    required this.dueSoonDays,
    required this.reviewAgeWarningDays,
    this.statusStartedAt,
    this.statusLabel,
    this.now,
    this.onPressed,
    this.onSelectedChanged,
    this.elevated = false,
  });

  final ScrumTask task;
  final bool selected;
  final int dueSoonDays;
  final int reviewAgeWarningDays;
  final DateTime? statusStartedAt;
  final String? statusLabel;
  final DateTime? now;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onSelectedChanged;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFF2563EB).withValues(alpha: .06)
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: elevated ? 8 : 0,
      shadowColor: Colors.black.withValues(alpha: .14),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2563EB)
                  : ScrumBoardPalette.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScrumTaskCardHeader(
                task: task,
                selected: selected,
                onSelectedChanged: onSelectedChanged,
              ),
              const SizedBox(height: 12),
              ScrumTaskCardContent(
                title: task.title,
                description: task.description,
              ),
              const SizedBox(height: 14),
              ScrumTaskCardFooter(
                task: task,
                dueSoonDays: dueSoonDays,
                reviewAgeWarningDays: reviewAgeWarningDays,
                statusStartedAt: statusStartedAt,
                statusLabel: statusLabel,
                now: now,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
