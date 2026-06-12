import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_board_summary.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';

/// Header summary for sprint intelligence panels.
class ScrumBoardInsightsHeader extends StatelessWidget {
  const ScrumBoardInsightsHeader({super.key, required this.summary});

  final ScrumBoardSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completion = (summary.completionRate * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: .1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_graph_rounded,
                color: Color(0xFF2563EB),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sprint Intelligence',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      color: ScrumBoardPalette.ink,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    '${summary.activeTasks} active tasks',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: ScrumBoardPalette.mutedInk,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$completion%',
              style: textTheme.headlineSmall?.copyWith(
                color: ScrumBoardPalette.ink,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'complete',
                style: textTheme.labelMedium?.copyWith(
                  color: ScrumBoardPalette.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: summary.storyPointCompletionRate,
          minHeight: 8,
          borderRadius: BorderRadius.circular(99),
        ),
      ],
    );
  }
}

/// Preview for the sprint intelligence header summary.
@Preview(group: 'Ky Scrumboard', name: 'Insights header', size: Size(360, 180))
Widget scrumBoardInsightsHeaderPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 320,
          child: ScrumBoardInsightsHeader(
            summary: ScrumBoardSummary(
              totalTasks: 12,
              completedTasks: 5,
              activeTasks: 7,
              totalStoryPoints: 38,
              completedStoryPoints: 18,
              activeStoryPoints: 20,
              tasksByStatus: {
                ScrumTaskStatus.todo: 4,
                ScrumTaskStatus.inProgress: 2,
                ScrumTaskStatus.review: 1,
                ScrumTaskStatus.done: 5,
              },
            ),
          ),
        ),
      ),
    ),
  );
}
