import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_playbook_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_playbook_panel.dart';

void main() {
  testWidgets('project domain playbook panel renders checks', (tester) async {
    const summary = ProjectDomainPlaybookSummary(
      vocabulary: ProjectStatusUpdateVocabulary.software,
      audience: ProjectStatusUpdateAudience.team,
      title: 'Software operating playbook',
      subtitle: '1 urgent - 1 watch - 2 checks',
      items: [
        ProjectDomainPlaybookItem(
          title: 'Confirm release controls',
          detail: 'Lock scope, QA evidence, and rollout readiness.',
          icon: Icons.code_outlined,
          level: ProjectDomainPlaybookLevel.routine,
        ),
        ProjectDomainPlaybookItem(
          title: 'Recover release plan',
          detail: 'Overdue work needs owner and date confirmation.',
          icon: Icons.event_busy_outlined,
          level: ProjectDomainPlaybookLevel.critical,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectDomainPlaybookPanel(summary: summary),
          ),
        ),
      ),
    );

    expect(find.text('Software operating playbook'), findsOneWidget);
    expect(find.text('1 urgent - 1 watch - 2 checks'), findsOneWidget);
    expect(find.text('Confirm release controls'), findsOneWidget);
    expect(find.text('Recover release plan'), findsOneWidget);
    expect(find.text('Urgent'), findsWidgets);
    expect(find.text('Routine'), findsOneWidget);
  });
}
