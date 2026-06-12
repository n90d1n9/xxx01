import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_command_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_delivery_command_components.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('project delivery command components render summary and actions', (
    tester,
  ) async {
    var openedProject = '';
    String? focusedProject;
    String? focusedTask;
    final command = ProjectDeliveryCommand(
      id: 'cmd-1',
      projectId: 'mobile-field-app',
      projectName: 'Mobile Field App',
      taskId: 'task-1',
      title: 'API contract drift',
      detail: 'Service history endpoints need a signed payload contract.',
      level: ProjectDeliveryCommandLevel.critical,
      kind: ProjectDeliveryCommandKind.risk,
      icon: Icons.block_outlined,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 1100,
              child: Column(
                children: [
                  ProjectDeliveryCommandSummaryGrid(
                    summary: ProjectDeliveryCommandSummary(commands: [command]),
                  ),
                  const SizedBox(height: 16),
                  ProjectDeliveryCommandQueue(
                    commands: [command],
                    onOpenProject: (projectId) => openedProject = projectId,
                    onFocusGantt: (projectId, taskId) {
                      focusedProject = projectId;
                      focusedTask = taskId;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Command Items'), findsOneWidget);
    expect(find.text('API contract drift'), findsOneWidget);
    expect(
      find.text(
        'Mobile Field App - Service history endpoints need a signed payload contract.',
      ),
      findsOneWidget,
    );
    expect(find.text('Critical'), findsWidgets);

    await tester.tap(find.text('Gantt'));
    await tester.pump();
    expect(focusedProject, 'mobile-field-app');
    expect(focusedTask, 'task-1');

    await tester.tap(find.text('Project'));
    await tester.pump();
    expect(openedProject, 'mobile-field-app');
  });

  testWidgets('project delivery command queue renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProjectDeliveryCommandQueue(commands: [])),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No command items'), findsOneWidget);
  });

  testWidgets('project delivery command filtered queue filters commands', (
    tester,
  ) async {
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
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 1100,
              child: ProjectDeliveryCommandFilteredQueue(commands: commands),
            ),
          ),
        ),
      ),
    );

    expect(find.text('All Priorities'), findsOneWidget);
    expect(find.text('All Signals'), findsOneWidget);
    expect(find.text('API contract drift'), findsOneWidget);
    expect(find.text('Budget pressure'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Warning'));
    await tester.pump();

    expect(find.text('API contract drift'), findsNothing);
    expect(find.text('Budget pressure'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Risks'));
    await tester.pump();

    expect(find.text('No matching command items'), findsOneWidget);
    expect(find.text('Reset filters'), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pump();

    expect(find.text('API contract drift'), findsOneWidget);
    expect(find.text('Budget pressure'), findsOneWidget);
  });
}
