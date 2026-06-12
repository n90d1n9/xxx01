import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_operating_cadence_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_operating_cadence_panel.dart';

void main() {
  testWidgets('project operating cadence panel renders review rhythm', (
    tester,
  ) async {
    const summary = ProjectOperatingCadenceSummary(
      vocabulary: ProjectStatusUpdateVocabulary.software,
      audience: ProjectStatusUpdateAudience.sponsor,
      title: 'Software operating cadence',
      subtitle: 'Recovery - daily until stable - 3 steps',
      recommendedCadence: 'daily until stable',
      items: [
        ProjectOperatingCadenceItem(
          title: 'Run release recovery standup',
          detail: 'Use a short recovery loop.',
          icon: Icons.code_outlined,
          level: ProjectOperatingCadenceLevel.recovery,
          kind: ProjectOperatingCadenceKind.cadence,
        ),
        ProjectOperatingCadenceItem(
          title: 'Open unblock window',
          detail: 'Create a decision window.',
          icon: Icons.priority_high_rounded,
          level: ProjectOperatingCadenceLevel.recovery,
          kind: ProjectOperatingCadenceKind.decisionWindow,
        ),
        ProjectOperatingCadenceItem(
          title: 'Close sponsor loop',
          detail: 'Make the sponsor ask clear.',
          icon: Icons.verified_user_outlined,
          level: ProjectOperatingCadenceLevel.decision,
          kind: ProjectOperatingCadenceKind.audience,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectOperatingCadencePanel(summary: summary),
          ),
        ),
      ),
    );

    expect(find.text('Software operating cadence'), findsOneWidget);
    expect(find.textContaining('daily until stable'), findsOneWidget);
    expect(find.text('Run release recovery standup'), findsOneWidget);
    expect(find.text('Open unblock window'), findsOneWidget);
    expect(find.text('Close sponsor loop'), findsOneWidget);
    expect(find.text('Recovery'), findsWidgets);
    expect(find.text('Decision'), findsWidgets);
  });
}
