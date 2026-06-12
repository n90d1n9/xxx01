import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_evidence_sync_activity_summary.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/widgets/dashboard/survey_dashboard_header.dart';
import 'package:ky_survey/widgets/dashboard/survey_evidence_sync_activity_strip.dart';

void main() {
  group('SurveyDashboardHeader', () {
    testWidgets('renders section context, role changes, and sync action', (
      tester,
    ) async {
      SurveyRole? selectedRole;
      var openedSyncActivity = false;

      await tester.pumpWidget(
        _headerHarness(
          availableRoles: const [SurveyRole.admin, SurveyRole.analyst],
          syncActivitySummary: const SurveyEvidenceSyncActivitySummary(
            activeUploadCount: 1,
          ),
          onRoleChanged: (role) => selectedRole = role,
          onOpenEvidenceSyncActivity: () => openedSyncActivity = true,
        ),
      );

      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Admin workspace'), findsOneWidget);
      expect(find.text('Participant'), findsNothing);
      expect(find.byType(SurveyEvidenceSyncActivityStrip), findsOneWidget);
      expect(find.text('Evidence upload running'), findsOneWidget);

      await tester.ensureVisible(find.text('Analyst'));
      await tester.tap(find.text('Analyst'));

      expect(selectedRole, SurveyRole.analyst);

      await tester.tap(find.byType(SurveyEvidenceSyncActivityStrip));
      await tester.pump();

      expect(openedSyncActivity, isTrue);
    });

    testWidgets('hides the sync strip when no evidence activity exists', (
      tester,
    ) async {
      await tester.pumpWidget(_headerHarness());

      expect(find.text('Reports'), findsOneWidget);
      expect(find.byType(SurveyEvidenceSyncActivityStrip), findsNothing);
    });
  });
}

Widget _headerHarness({
  SurveyEvidenceSyncActivitySummary syncActivitySummary =
      const SurveyEvidenceSyncActivitySummary(),
  List<SurveyRole> availableRoles = SurveyRole.values,
  ValueChanged<SurveyRole>? onRoleChanged,
  VoidCallback? onOpenEvidenceSyncActivity,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SurveyDashboardHeader(
          role: SurveyRole.admin,
          selectedSection: SurveyWorkspaceSection.reports,
          isWide: true,
          syncActivitySummary: syncActivitySummary,
          onRoleChanged: onRoleChanged ?? (_) {},
          availableRoles: availableRoles,
          onOpenEvidenceSyncActivity: onOpenEvidenceSyncActivity,
        ),
      ),
    ),
  );
}
