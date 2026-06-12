import 'package:flutter/material.dart';

import '../../models/scrum_board_summary.dart';
import '../../models/scrum_sprint.dart';
import '../scrum_board_palette.dart';
import 'scrum_metric_card.dart';

class ScrumBoardHeader extends StatelessWidget {
  const ScrumBoardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.summary,
    this.sprint,
    required this.onCreateTask,
  });

  final String title;
  final String subtitle;
  final ScrumBoardSummary summary;
  final ScrumSprint? sprint;
  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completion = (summary.completionRate * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(
          bottom: BorderSide(color: ScrumBoardPalette.border),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final heading = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  color: ScrumBoardPalette.ink,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _subtitleText,
                style: textTheme.bodyMedium?.copyWith(
                  color: ScrumBoardPalette.mutedInk,
                ),
              ),
            ],
          );

          final action = FilledButton.icon(
            onPressed: onCreateTask,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New task'),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading,
                    const SizedBox(height: 16),
                    Align(alignment: Alignment.centerLeft, child: action),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: heading),
                    const SizedBox(width: 16),
                    action,
                  ],
                ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ScrumMetricCard(
                    label: 'Tasks',
                    value: '${summary.totalTasks}',
                    icon: Icons.task_alt_rounded,
                    color: const Color(0xFF2563EB),
                  ),
                  ScrumMetricCard(
                    label: 'Active points',
                    value: '${summary.activeStoryPoints}',
                    icon: Icons.bolt_rounded,
                    color: const Color(0xFF0891B2),
                  ),
                  ScrumMetricCard(
                    label: 'Done',
                    value: '$completion%',
                    icon: Icons.verified_rounded,
                    color: const Color(0xFF16A34A),
                  ),
                  if (sprint?.capacityStoryPoints != null)
                    ScrumMetricCard(
                      label: 'Capacity',
                      value:
                          '${summary.totalStoryPoints}/${sprint!.capacityStoryPoints} SP',
                      icon: Icons.speed_rounded,
                      color: const Color(0xFFD97706),
                    ),
                  if (sprint != null)
                    ScrumMetricCard(
                      label: 'Sprint',
                      value: '${sprint!.daysRemainingAt(DateTime.now())}d left',
                      icon: Icons.event_rounded,
                      color: const Color(0xFF7C3AED),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String get _subtitleText {
    final sprintGoal = sprint?.goal.trim();
    if (sprintGoal == null || sprintGoal.isEmpty) return subtitle;
    return '$subtitle Goal: $sprintGoal';
  }
}
