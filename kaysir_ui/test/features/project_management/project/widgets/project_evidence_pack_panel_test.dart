import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_evidence_pack_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_evidence_pack_panel.dart';

void main() {
  testWidgets('project evidence pack panel renders readiness checks', (
    tester,
  ) async {
    const summary = ProjectEvidencePackSummary(
      vocabulary: ProjectStatusUpdateVocabulary.software,
      audience: ProjectStatusUpdateAudience.sponsor,
      title: 'Software evidence pack',
      subtitle: '2 ready - 1 review - 1 missing',
      items: [
        ProjectEvidencePackItem(
          title: 'QA and acceptance pack',
          detail: 'Collect release evidence.',
          icon: Icons.verified_outlined,
          status: ProjectEvidenceStatus.ready,
          kind: ProjectEvidenceKind.domain,
        ),
        ProjectEvidencePackItem(
          title: 'Recover release plan evidence',
          detail: 'Revise overdue work item proof.',
          icon: Icons.event_busy_outlined,
          status: ProjectEvidenceStatus.needsReview,
          kind: ProjectEvidenceKind.schedule,
        ),
        ProjectEvidencePackItem(
          title: 'Prepare sponsor sign-off',
          detail: 'Make the decision route visible.',
          icon: Icons.verified_user_outlined,
          status: ProjectEvidenceStatus.missing,
          kind: ProjectEvidenceKind.signOff,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectEvidencePackPanel(summary: summary),
          ),
        ),
      ),
    );

    expect(find.text('Software evidence pack'), findsOneWidget);
    expect(
      find.textContaining('2 ready - 1 review - 1 missing'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('QA and acceptance pack'), findsOneWidget);
    expect(find.text('Recover release plan evidence'), findsOneWidget);
    expect(find.text('Prepare sponsor sign-off'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Review'), findsWidgets);
    expect(find.text('Missing'), findsWidgets);
  });
}
