import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_board_summary.dart';
import '../../models/scrum_sprint.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';

/// Sprint progress card for date, capacity, and velocity context.
class ScrumBoardSprintProgressSection extends StatelessWidget {
  const ScrumBoardSprintProgressSection({
    super.key,
    required this.sprint,
    required this.summary,
    required this.now,
  });

  final ScrumSprint sprint;
  final ScrumBoardSummary summary;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final capacity = sprint.capacityStoryPoints;
    final velocityTarget = sprint.velocityTargetStoryPoints;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha: .07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            sprint.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(
              color: ScrumBoardPalette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sprint.goal,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: ScrumBoardPalette.mutedInk,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: sprint.timeProgressAt(now),
            minHeight: 7,
            borderRadius: BorderRadius.circular(99),
            color: const Color(0xFF7C3AED),
            backgroundColor: ScrumBoardPalette.border,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _SprintFact(
                label: 'Time',
                value:
                    '${sprint.daysElapsedAt(now)}/${sprint.durationDays} days',
              ),
              if (capacity != null)
                _SprintFact(
                  label: 'Capacity',
                  value: '${summary.totalStoryPoints}/$capacity SP',
                ),
              if (velocityTarget != null)
                _SprintFact(
                  label: 'Velocity',
                  value: '${summary.completedStoryPoints}/$velocityTarget SP',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Preview for the sprint progress card.
@Preview(group: 'Ky Scrumboard', name: 'Sprint progress', size: Size(360, 190))
Widget scrumBoardSprintProgressSectionPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 320,
          child: ScrumBoardSprintProgressSection(
            sprint: ScrumSprint(
              id: 'sprint-42',
              name: 'Sprint 42',
              goal: 'Reduce delivery risk before release handoff.',
              startAt: DateTime(2026, 1, 1),
              endAt: DateTime(2026, 1, 14),
              capacityStoryPoints: 42,
              velocityTargetStoryPoints: 24,
            ),
            summary: const ScrumBoardSummary(
              totalTasks: 12,
              completedTasks: 5,
              activeTasks: 7,
              totalStoryPoints: 38,
              completedStoryPoints: 18,
              activeStoryPoints: 20,
              tasksByStatus: {ScrumTaskStatus.done: 5},
            ),
            now: DateTime(2026, 1, 8),
          ),
        ),
      ),
    ),
  );
}

/// Compact sprint metric label.
class _SprintFact extends StatelessWidget {
  const _SprintFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label $value',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: ScrumBoardPalette.mutedInk,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
