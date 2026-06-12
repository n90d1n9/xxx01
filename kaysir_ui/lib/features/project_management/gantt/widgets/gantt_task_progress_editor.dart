import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';

import '../gantt_dashboard.dart' as gantt;

class GanttTaskProgressEditor extends StatelessWidget {
  const GanttTaskProgressEditor({
    required this.task,
    this.onProgressChanged,
    super.key,
  });

  static const progressSliderKey = ValueKey('gantt-task-progress-slider');

  final gantt.GanttTask task;
  final ValueChanged<double>? onProgressChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = task.progress.clamp(0, 1).toDouble();
    final percent = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Progress Control',
          subtitle: '$percent% complete',
          icon: Icons.tune_rounded,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: task.color.withValues(alpha: 0.12),
          iconForegroundColor: task.color,
          trailing: Text(
            '$percent%',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: task.color,
            inactiveTrackColor: task.color.withValues(alpha: 0.18),
            thumbColor: task.color,
            overlayColor: task.color.withValues(alpha: 0.12),
            trackHeight: 5,
          ),
          child: Slider(
            key: progressSliderKey,
            value: progress,
            min: 0,
            max: 1,
            divisions: 20,
            label: '$percent%',
            onChanged:
                onProgressChanged == null
                    ? null
                    : (value) => onProgressChanged!(value),
          ),
        ),
      ],
    );
  }
}
