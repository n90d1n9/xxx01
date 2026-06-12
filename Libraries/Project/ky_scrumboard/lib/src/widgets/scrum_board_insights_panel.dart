import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_activity.dart';
import '../../models/scrum_assignee_load.dart';
import '../../models/scrum_board_insight.dart';
import '../../models/scrum_board_summary.dart';
import '../../models/scrum_sprint.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'scrum_activity_timeline_section.dart';
import 'scrum_board_flow_insights.dart';
import 'scrum_board_insights_header.dart';
import 'scrum_board_sprint_progress_section.dart';
import 'scrum_board_workload_section.dart';

String defaultScrumActivityStatusLabel(ScrumTaskStatus status) => status.label;

/// Side panel that composes sprint summary, flow signals, activity, and workload.
class ScrumBoardInsightsPanel extends StatelessWidget {
  const ScrumBoardInsightsPanel({
    super.key,
    required this.summary,
    required this.insights,
    required this.assigneeLoads,
    this.recentActivities = const [],
    this.statusLabelFor = defaultScrumActivityStatusLabel,
    this.sprint,
  });

  final ScrumBoardSummary summary;
  final List<ScrumBoardInsight> insights;
  final List<ScrumAssigneeLoad> assigneeLoads;
  final List<ScrumActivity> recentActivities;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final ScrumSprint? sprint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: ScrumBoardPalette.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ScrumBoardInsightsHeader(summary: summary),
            if (sprint != null) ...[
              const SizedBox(height: 18),
              ScrumBoardSprintProgressSection(
                sprint: sprint!,
                summary: summary,
                now: DateTime.now(),
              ),
            ],
            const SizedBox(height: 18),
            ScrumBoardFlowInsights(insights: insights),
            if (recentActivities.isNotEmpty) ...[
              const SizedBox(height: 8),
              ScrumActivityTimelineSection(
                activities: recentActivities,
                statusLabelFor: statusLabelFor,
              ),
            ],
            if (assigneeLoads.isNotEmpty) ...[
              const SizedBox(height: 8),
              ScrumBoardWorkloadSection(assigneeLoads: assigneeLoads),
            ],
          ],
        ),
      ),
    );
  }
}

/// Preview for the complete sprint intelligence panel.
@Preview(group: 'Ky Scrumboard', name: 'Insights panel', size: Size(380, 720))
Widget scrumBoardInsightsPanelPreview() {
  final createdAt = DateTime(2026, 1, 8, 9);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 340,
          child: ScrumBoardInsightsPanel(
            summary: const ScrumBoardSummary(
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
            sprint: ScrumSprint(
              id: 'sprint-42',
              name: 'Sprint 42',
              goal: 'Reduce delivery risk before release handoff.',
              startAt: DateTime(2026, 1),
              endAt: DateTime(2026, 1, 14),
              capacityStoryPoints: 42,
              velocityTargetStoryPoints: 24,
            ),
            insights: const [
              ScrumBoardInsight(
                key: 'review',
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
            recentActivities: [
              ScrumActivity(
                id: 'activity-1',
                type: ScrumActivityType.taskMoved,
                createdAt: createdAt,
                taskId: 'review-copy',
                taskTitle: 'Review checkout copy',
                fromStatus: ScrumTaskStatus.inProgress,
                toStatus: ScrumTaskStatus.review,
                actor: 'Alya',
              ),
            ],
            assigneeLoads: const [
              ScrumAssigneeLoad(
                assignee: 'Alya',
                activeTasks: 3,
                activeStoryPoints: 13,
                criticalTasks: 1,
              ),
              ScrumAssigneeLoad(
                assignee: 'Bima',
                activeTasks: 2,
                activeStoryPoints: 8,
                criticalTasks: 0,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
