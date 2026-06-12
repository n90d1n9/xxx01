import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_workflow_action_bar.dart';
import 'package:kaysir/features/project_management/project/widgets/project_workflow_header.dart';
import 'package:kaysir/features/project_management/project/widgets/project_workflow_issue_list.dart';
import 'package:kaysir/features/project_management/project/widgets/project_workflow_queue.dart';
import 'package:kaysir/features/project_management/project/widgets/project_workflow_submission_section.dart';
import 'package:kaysir/features/project_management/project/widgets/project_workflow_text_field.dart';

void main() {
  testWidgets('project workflow header renders status context', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final colorScheme = Theme.of(context).colorScheme;

              return ProjectWorkflowHeader(
                title: 'Approval action flow',
                subtitle: 'Design sign-off - 1 queued action - Approval route',
                icon: Icons.verified_user_outlined,
                color: colorScheme.primary,
                statusLabel: 'Approve',
                statusIcon: Icons.approval_outlined,
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Approval action flow'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.byIcon(Icons.verified_user_outlined), findsOneWidget);
  });

  testWidgets('project workflow text field reports changes', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var latestValue = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectWorkflowTextField(
            fieldKey: const ValueKey('workflow-title'),
            controller: controller,
            label: 'Workflow title',
            icon: Icons.assignment_outlined,
            onChanged: (value) => latestValue = value,
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('workflow-title')),
      'Recovery action',
    );

    expect(latestValue, 'Recovery action');
  });

  testWidgets('project workflow issue list renders validation rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectWorkflowIssueList<Map<String, String>>.fromItems(
            items: const [
              {'field': 'owner', 'message': 'Owner is required.'},
            ],
            fieldFor: (issue) => issue['field']!,
            messageFor: (issue) => issue['message']!,
          ),
        ),
      ),
    );

    expect(find.text('Owner is required.'), findsOneWidget);
    expect(find.text('owner'), findsOneWidget);
  });

  testWidgets('project workflow issue section hides when empty', (
    tester,
  ) async {
    Widget buildSection(List<Map<String, String>> issues) {
      return MaterialApp(
        home: Scaffold(
          body: ProjectWorkflowIssueSection<Map<String, String>>(
            items: issues,
            fieldFor: (issue) => issue['field']!,
            messageFor: (issue) => issue['message']!,
          ),
        ),
      );
    }

    await tester.pumpWidget(buildSection(const []));
    expect(
      find.byType(ProjectWorkflowIssueList<Map<String, String>>),
      findsNothing,
    );

    await tester.pumpWidget(
      buildSection(const [
        {'field': 'evidence', 'message': 'Evidence is required.'},
      ]),
    );

    expect(find.text('Evidence is required.'), findsOneWidget);
    expect(find.text('evidence'), findsOneWidget);
  });

  testWidgets('project workflow action bar exposes reset and submit actions', (
    tester,
  ) async {
    var resetCount = 0;
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectWorkflowActionBar(
            submitLabel: 'Queue Response',
            submitIcon: Icons.add_task_outlined,
            onReset: () => resetCount++,
            onSubmit: () => submitCount++,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.add_task_outlined), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.tap(find.text('Queue Response'));

    expect(resetCount, 1);
    expect(submitCount, 1);
  });

  testWidgets('project workflow queue switches from empty to queued tile', (
    tester,
  ) async {
    Widget buildQueue(List<String> items) {
      return MaterialApp(
        home: Scaffold(
          body: ProjectWorkflowQueue<String>.mapped(
            items: items,
            emptyTitle: 'Workflow queue empty',
            emptySubtitle: 'Queued items will appear here.',
            titleFor: (item) => item,
            subtitleFor: (_) => 'Executive escalation',
            iconFor: (_) => Icons.priority_high_rounded,
            colorFor: (context, _) => Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    await tester.pumpWidget(buildQueue(const []));
    expect(find.text('Workflow queue empty'), findsOneWidget);

    await tester.pumpWidget(buildQueue(const ['Recovery response']));
    expect(find.text('Recovery response'), findsOneWidget);
    expect(find.text('Queued'), findsOneWidget);
  });

  testWidgets('project workflow submission section wires actions and queue', (
    tester,
  ) async {
    var resetCount = 0;
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectWorkflowSubmissionSection<String>(
            submitLabel: 'Queue Response',
            submitIcon: Icons.health_and_safety_outlined,
            onReset: () => resetCount++,
            onSubmit: () => submitCount++,
            items: const ['Mitigate delivery risk'],
            emptyTitle: 'Workflow queue empty',
            emptySubtitle: 'Queued responses will appear here.',
            titleFor: (item) => item,
            subtitleFor: (_) => 'Sponsor route',
            iconFor: (_) => Icons.priority_high_rounded,
            colorFor: (context, _) => Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );

    expect(find.text('Mitigate delivery risk'), findsOneWidget);
    expect(find.byIcon(Icons.health_and_safety_outlined), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.tap(find.text('Queue Response'));

    expect(resetCount, 1);
    expect(submitCount, 1);
  });
}
