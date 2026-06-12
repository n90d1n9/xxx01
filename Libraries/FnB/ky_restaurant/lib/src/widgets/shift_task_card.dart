import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_card_controls.dart';
import 'restaurant_card_header.dart';
import 'restaurant_mini_stat.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_card_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays a shift follow-up task with progress, ownership, and completion action.
class RestaurantShiftTaskCard extends StatelessWidget {
  const RestaurantShiftTaskCard({
    super.key,
    required this.task,
    required this.onCompleteTask,
    this.focused = false,
  });

  final RestaurantShiftTask task;
  final ValueChanged<String>? onCompleteTask;
  final bool focused;

  bool get _isComplete => task.progress >= 1;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusStyle = restaurantStatusStyle(colors, task.status);

    return Semantics(
      container: true,
      selected: focused,
      label:
          '${task.title}, owner ${task.owner}, due ${task.dueLabel}, '
          '${(task.progress.clamp(0.0, 1.0) * 100).round()}% complete',
      child: RestaurantStatusCardSurface(
        statusStyle: statusStyle,
        isFocused: focused,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantCardHeader(
              icon: _isComplete
                  ? Icons.task_alt_rounded
                  : Icons.pending_actions_outlined,
              foregroundColor: statusStyle.foreground,
              backgroundColor: statusStyle.background,
              title: task.title,
              titleMaxLines: 2,
              subtitle: task.owner,
              trailing: RestaurantStatusPill(
                status: task.status,
                label: task.dueLabel,
                compact: true,
              ),
            ),
            const SizedBox(height: 12),
            RestaurantProgressBar(
              value: task.progress,
              status: task.status,
              semanticLabel: '${task.title} progress',
            ),
            const SizedBox(height: 12),
            RestaurantCardMetricRow(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                RestaurantMiniStat(
                  icon: Icons.person_outline_rounded,
                  label: 'Owner',
                  value: task.owner,
                  semanticLabel: '${task.title} owner, ${task.owner}',
                ),
                RestaurantMiniStat(
                  icon: Icons.schedule_outlined,
                  label: 'Due',
                  value: task.dueLabel,
                  semanticLabel: '${task.title} due, ${task.dueLabel}',
                ),
                RestaurantSignalChip(
                  icon: _isComplete
                      ? Icons.check_circle_outline
                      : Icons.timelapse_outlined,
                  label: _isComplete ? 'Complete' : 'In progress',
                  foregroundColor: statusStyle.foreground,
                  backgroundColor: statusStyle.background,
                ),
              ],
            ),
            if (onCompleteTask != null && !_isComplete) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: RestaurantCardActionButton(
                  icon: Icons.check_rounded,
                  label: 'Done',
                  foregroundColor: statusStyle.foreground,
                  backgroundColor: statusStyle.background,
                  onPressed: () => onCompleteTask!(task.id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
