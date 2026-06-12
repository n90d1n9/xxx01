import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_governance_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_governance_panel.dart';

void main() {
  testWidgets('project decision governance panel renders approval routes', (
    tester,
  ) async {
    const summary = ProjectDecisionGovernanceSummary(
      vocabulary: ProjectStatusUpdateVocabulary.software,
      audience: ProjectStatusUpdateAudience.sponsor,
      title: 'Software decision governance',
      subtitle: 'Escalate - release council escalation - 3 routes',
      decisionRoute: 'release council escalation',
      briefText:
          'Software decision governance brief\n'
          'Status: Escalate\n'
          'Route: release council escalation\n'
          'Primary governance route\n'
          '- Escalate release governance: Move blocked decisions.',
      items: [
        ProjectDecisionGovernanceItem(
          title: 'Escalate release governance',
          detail: 'Move blocked decisions.',
          icon: Icons.code_outlined,
          level: ProjectDecisionGovernanceLevel.escalate,
          kind: ProjectDecisionGovernanceKind.authority,
        ),
        ProjectDecisionGovernanceItem(
          title: 'Approve release plan recovery',
          detail: 'Confirm date, owner, and scope.',
          icon: Icons.event_busy_outlined,
          level: ProjectDecisionGovernanceLevel.escalate,
          kind: ProjectDecisionGovernanceKind.schedule,
        ),
        ProjectDecisionGovernanceItem(
          title: 'Prepare sponsor decision agenda',
          detail: 'Give sponsor approve or defer choices.',
          icon: Icons.verified_user_outlined,
          level: ProjectDecisionGovernanceLevel.approve,
          kind: ProjectDecisionGovernanceKind.communication,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectDecisionGovernancePanel(summary: summary),
          ),
        ),
      ),
    );

    expect(find.text('Software decision governance'), findsOneWidget);
    expect(find.textContaining('release council escalation'), findsWidgets);
    expect(find.text('Decision route'), findsOneWidget);
    expect(find.text('Escalate release governance'), findsOneWidget);
    expect(find.text('Approve release plan recovery'), findsOneWidget);
    expect(find.text('Prepare sponsor decision agenda'), findsOneWidget);
    expect(find.text('Escalate'), findsWidgets);
    expect(find.text('Approve'), findsWidgets);
    expect(find.text('Decision governance brief'), findsOneWidget);
    expect(find.text('Copy ready'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);

    final copyButton = find.widgetWithText(OutlinedButton, 'Copy');
    expect(copyButton, findsOneWidget);

    await tester.ensureVisible(copyButton);
    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    expect(find.text('Copied'), findsOneWidget);
  });
}
