import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_board_insight.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';

/// Flow signal section that summarizes the most important board insights.
class ScrumBoardFlowInsights extends StatelessWidget {
  const ScrumBoardFlowInsights({
    super.key,
    required this.insights,
    this.maxVisibleInsights = 4,
  });

  final List<ScrumBoardInsight> insights;
  final int maxVisibleInsights;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Flow signals',
          style: textTheme.labelLarge?.copyWith(
            color: ScrumBoardPalette.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        for (final insight in insights.take(maxVisibleInsights)) ...[
          _ScrumBoardInsightRow(insight: insight),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Preview for workflow insight rows.
@Preview(group: 'Ky Scrumboard', name: 'Flow insights', size: Size(360, 260))
Widget scrumBoardFlowInsightsPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 320,
          child: ScrumBoardFlowInsights(
            insights: [
              ScrumBoardInsight(
                key: 'wip',
                title: 'Review WIP is high',
                description: 'Three tasks are waiting for validation.',
                severity: ScrumBoardInsightSeverity.warning,
                relatedStatus: ScrumTaskStatus.review,
              ),
              ScrumBoardInsight(
                key: 'velocity',
                title: 'Velocity target is on track',
                description: 'Completed story points are trending well.',
                severity: ScrumBoardInsightSeverity.positive,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Single insight row with severity color and compact copy.
class _ScrumBoardInsightRow extends StatelessWidget {
  const _ScrumBoardInsightRow({required this.insight});

  final ScrumBoardInsight insight;

  @override
  Widget build(BuildContext context) {
    final color = ScrumBoardPalette.insightColor(insight.severity);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconFor(insight.severity), size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: ScrumBoardPalette.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.description,
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

IconData _iconFor(ScrumBoardInsightSeverity severity) {
  switch (severity) {
    case ScrumBoardInsightSeverity.positive:
      return Icons.check_circle_rounded;
    case ScrumBoardInsightSeverity.info:
      return Icons.info_rounded;
    case ScrumBoardInsightSeverity.warning:
      return Icons.warning_amber_rounded;
    case ScrumBoardInsightSeverity.critical:
      return Icons.error_rounded;
  }
}
