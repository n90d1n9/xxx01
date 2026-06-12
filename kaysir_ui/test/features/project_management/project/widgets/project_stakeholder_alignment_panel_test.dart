import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_stakeholder_alignment_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_stakeholder_alignment_panel.dart';

void main() {
  testWidgets('project stakeholder alignment panel renders routes', (
    tester,
  ) async {
    const summary = ProjectStakeholderAlignmentSummary(
      vocabulary: ProjectStatusUpdateVocabulary.software,
      audience: ProjectStatusUpdateAudience.sponsor,
      title: 'Software stakeholder alignment',
      subtitle: '1 blocked - 1 decision - 1 aligned',
      items: [
        ProjectStakeholderAlignmentItem(
          title: 'Escalate sponsor decision',
          detail: 'Sponsor should unblock delivery constraints.',
          icon: Icons.priority_high_rounded,
          status: ProjectStakeholderAlignmentStatus.blocked,
          role: ProjectStakeholderAlignmentRole.sponsor,
        ),
        ProjectStakeholderAlignmentItem(
          title: 'Reset client confidence path',
          detail: 'Give the client timing and decision asks.',
          icon: Icons.handshake_outlined,
          status: ProjectStakeholderAlignmentStatus.decision,
          role: ProjectStakeholderAlignmentRole.client,
        ),
        ProjectStakeholderAlignmentItem(
          title: 'Sync team execution path',
          detail: 'Team roles are visible.',
          icon: Icons.groups_outlined,
          status: ProjectStakeholderAlignmentStatus.aligned,
          role: ProjectStakeholderAlignmentRole.team,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectStakeholderAlignmentPanel(summary: summary),
          ),
        ),
      ),
    );

    expect(find.text('Software stakeholder alignment'), findsOneWidget);
    expect(
      find.textContaining('1 blocked - 1 decision - 1 aligned'),
      findsOneWidget,
    );
    expect(find.text('Escalate sponsor decision'), findsOneWidget);
    expect(find.text('Reset client confidence path'), findsOneWidget);
    expect(find.text('Sync team execution path'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('Decision'), findsWidgets);
    expect(find.text('Aligned'), findsWidgets);
  });
}
