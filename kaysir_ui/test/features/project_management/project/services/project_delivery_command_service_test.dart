import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_command_service.dart';

void main() {
  test(
    'project delivery command center prioritizes blockers and dependencies',
    () {
      final today = DateTime(2026, 5, 31);
      final dependency = _task(
        id: 'dependency',
        start: DateTime(2026, 5, 1),
        end: DateTime(2026, 5, 20),
        progress: 0.4,
      );
      final blockedTask = _task(
        id: 'blocked-task',
        start: DateTime(2026, 5, 28),
        end: DateTime(2026, 6, 5),
        dependsOn: dependency.id,
      );

      final summary = buildProjectDeliveryCommandSummary(
        projects: [
          _project(
            health: ProjectHealth.blocked,
            budgetUsed: 0.72,
            timelineTaskIds: [blockedTask.id],
            risks: const [
              ProjectDeliveryRisk(
                title: 'Contract blocked',
                detail: 'Awaiting signed payload contract.',
                severity: ProjectHealth.blocked,
              ),
            ],
          ),
        ],
        tasks: [dependency, blockedTask],
        today: today,
      );

      expect(summary.totalCount, greaterThanOrEqualTo(4));
      expect(summary.criticalCount, greaterThanOrEqualTo(3));
      expect(summary.dependencyCount, 1);
      expect(summary.projectCount, 1);
      expect(
        summary.commands.first.kind,
        ProjectDeliveryCommandKind.projectBlocked,
      );
      expect(
        summary.commands.map((command) => command.title),
        contains('blocked-task dependency'),
      );
      expect(
        summary.commands.map((command) => command.title),
        contains('Budget pressure'),
      );
    },
  );

  test('project delivery command filters by priority and signal kind', () {
    const commands = [
      ProjectDeliveryCommand(
        id: 'risk',
        projectId: 'mobile-field-app',
        projectName: 'Mobile Field App',
        title: 'API contract drift',
        detail: 'Payload contract is not signed.',
        level: ProjectDeliveryCommandLevel.critical,
        kind: ProjectDeliveryCommandKind.risk,
        icon: Icons.block_outlined,
      ),
      ProjectDeliveryCommand(
        id: 'budget',
        projectId: 'warehouse-automation',
        projectName: 'Warehouse Automation',
        title: 'Budget pressure',
        detail: 'Budget is ahead of progress.',
        level: ProjectDeliveryCommandLevel.warning,
        kind: ProjectDeliveryCommandKind.budget,
        icon: Icons.account_balance_wallet_outlined,
      ),
      ProjectDeliveryCommand(
        id: 'milestone',
        projectId: 'retail-modernization',
        projectName: 'Retail Modernization',
        title: 'Pilot milestone',
        detail: 'Pilot is due soon.',
        level: ProjectDeliveryCommandLevel.watch,
        kind: ProjectDeliveryCommandKind.milestone,
        icon: Icons.flag_outlined,
      ),
    ];

    expect(
      filterProjectDeliveryCommands(
        commands: commands,
        level: ProjectDeliveryCommandLevel.warning,
      ).map((command) => command.id),
      ['budget'],
    );
    expect(
      filterProjectDeliveryCommands(
        commands: commands,
        filter: const ProjectDeliveryCommandFilter(
          level: ProjectDeliveryCommandLevel.warning,
          kind: ProjectDeliveryCommandKind.budget,
        ),
      ).map((command) => command.id),
      ['budget'],
    );
    expect(
      filterProjectDeliveryCommands(
        commands: commands,
        kind: ProjectDeliveryCommandKind.risk,
      ).map((command) => command.id),
      ['risk'],
    );
    expect(
      filterProjectDeliveryCommands(
        commands: commands,
        level: ProjectDeliveryCommandLevel.watch,
        kind: ProjectDeliveryCommandKind.budget,
      ),
      isEmpty,
    );
  });
}

ProjectPortfolioItem _project({
  ProjectHealth health = ProjectHealth.onTrack,
  double budgetUsed = 0.2,
  List<String> timelineTaskIds = const [],
  List<ProjectDeliveryRisk> risks = const [],
}) {
  return ProjectPortfolioItem(
    id: 'mobile-field-app',
    name: 'Mobile Field App',
    owner: 'Nadia Putri',
    client: 'Service Team',
    startDate: DateTime(2026, 5, 20),
    endDate: DateTime(2026, 9, 4),
    progress: 0.18,
    budgetUsed: budgetUsed,
    health: health,
    timelineTaskIds: timelineTaskIds,
    risks: risks,
    milestones: [
      ProjectMilestone(
        label: 'API Ready',
        dueDate: DateTime(2026, 6, 11),
        isComplete: false,
      ),
    ],
  );
}

gantt.GanttTask _task({
  required String id,
  required DateTime start,
  required DateTime end,
  double progress = 0,
  String? dependsOn,
}) {
  return gantt.GanttTask(
    id: id,
    title: id,
    startDate: start,
    endDate: end,
    progress: progress,
    dependsOn: dependsOn,
    projectId: id == 'blocked-task' ? 'mobile-field-app' : null,
  );
}
