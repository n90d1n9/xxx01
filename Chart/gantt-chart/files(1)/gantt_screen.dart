import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/gantt_providers.dart';
import '../../shared/theme/gantt_theme.dart';
import 'gantt_toolbar.dart';
import 'gantt_chart_viewport.dart';
import 'task_detail_panel.dart';
import 'gantt_status_bar.dart';

/// Top-level Gantt screen that combines toolbar, chart, detail panel, status bar.
class GanttScreen extends ConsumerWidget {
  const GanttScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedTaskIdProvider);

    return Scaffold(
      backgroundColor: GanttTheme.surface0,
      body: Column(
        children: [
          const GanttToolbar(),
          Expanded(
            child: Row(
              children: [
                const Expanded(child: GanttChartViewport()),
                // Slide-in detail panel
                AnimatedSize(
                  duration: GanttAnimations.normal,
                  curve: Curves.easeInOut,
                  child: selectedId != null
                      ? const TaskDetailPanel()
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const GanttStatusBar(),
        ],
      ),
    );
  }
}
