import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_queue_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/analytics/survey_fieldwork_insights.dart';
import 'package:ky_survey/analytics/survey_insights.dart';
import 'package:ky_survey/analytics/survey_response_insights.dart';
import 'package:ky_survey/analytics/survey_response_quality_insights.dart';
import 'package:ky_survey/analytics/survey_response_review_insights.dart';
import 'package:ky_survey/analytics/survey_response_sync_readiness.dart';
import 'package:ky_survey/logic/survey_evidence_upload_activity_tracker.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_response_review.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/screens/survey_dashboard_screen.dart';
import 'package:ky_survey/widgets/dashboard/survey_dashboard_content.dart';
import 'package:ky_survey/widgets/dashboard/survey_evidence_sync_activity_strip.dart';

void main() {
  testWidgets(
    'SurveyDashboardContent renders header and forwards role changes',
    (tester) async {
      SurveyRole? selectedRole;

      await tester.pumpWidget(
        _dashboardContent(onRoleChanged: (role) => selectedRole = role),
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Admin workspace'), findsOneWidget);
      expect(find.byType(SurveyEvidenceSyncActivityStrip), findsNothing);

      await tester.ensureVisible(find.text('Analyst'));
      await tester.tap(find.text('Analyst'));

      expect(selectedRole, SurveyRole.analyst);
    },
  );

  testWidgets('SurveyDashboardContent shows active sync activity near header', (
    tester,
  ) async {
    final survey = _survey();
    final response = _response(id: 'active-upload');
    final evidenceSyncInsights = SurveyEvidenceSyncInsights(
      surveys: [survey],
      responses: [response],
    );
    final activeTask = SurveyEvidenceUploadPlanner(
      insights: evidenceSyncInsights,
    ).createPlan().uploadableTasks.single;
    var openedSyncActivity = false;

    await tester.pumpWidget(
      _dashboardContent(
        selectedSection: SurveyWorkspaceSection.analytics,
        surveys: [survey],
        responses: [response],
        activeEvidenceUploadKeys: {
          SurveyEvidenceUploadActivityTracker.keyFor(activeTask),
        },
        onOpenEvidenceSyncActivity: () => openedSyncActivity = true,
      ),
    );

    expect(find.text('Analytics'), findsOneWidget);
    expect(find.byType(SurveyEvidenceSyncActivityStrip), findsOneWidget);
    expect(find.text('Evidence upload running'), findsOneWidget);
    expect(find.text('1 upload running'), findsOneWidget);

    await tester.tap(find.byType(SurveyEvidenceSyncActivityStrip));
    await tester.pump();

    expect(openedSyncActivity, isTrue);
  });

  testWidgets('SurveyDashboardContent scopes roles through the header', (
    tester,
  ) async {
    SurveyRole? selectedRole;

    await tester.pumpWidget(
      _dashboardContent(
        availableRoles: const [SurveyRole.admin, SurveyRole.analyst],
        onRoleChanged: (role) => selectedRole = role,
      ),
    );

    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Analyst'), findsOneWidget);
    expect(find.text('Participant'), findsNothing);

    await tester.tap(find.text('Analyst'));

    expect(selectedRole, SurveyRole.analyst);
  });

  testWidgets(
    'SurveyDashboardContent makes report viewer analytics review workflow read-only',
    (tester) async {
      final survey = _survey();
      final response = _response(id: 'review-ready');
      SurveyResponseReviewStatus? selectedStatus;

      await tester.pumpWidget(
        _dashboardContent(
          role: SurveyRole.reportViewer,
          selectedSection: SurveyWorkspaceSection.analytics,
          surveys: [survey],
          responses: [response],
          onResponseReviewStatusChanged: (_, status) => selectedStatus = status,
        ),
      );

      expect(find.text('Review Workflow'), findsOneWidget);
      expect(
        find.text('Review decisions are read-only for this role.'),
        findsOneWidget,
      );
      expect(find.text('Pending Review'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Approve'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Follow-up'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Reject'), findsNothing);
      expect(selectedStatus, isNull);
    },
  );

  testWidgets(
    'SurveyDashboardContent disables report viewer evidence sync commands',
    (tester) async {
      final survey = _survey();
      final response = _response(id: 'sync-ready');
      SurveyEvidenceUploadPlan? selectedPlan;

      await tester.pumpWidget(
        _dashboardContent(
          role: SurveyRole.reportViewer,
          selectedSection: SurveyWorkspaceSection.reports,
          surveys: [survey],
          responses: [response],
          onRunEvidenceUploadPlan: (plan) => selectedPlan = plan,
        ),
      );

      expect(find.text('Evidence Upload Plan'), findsOneWidget);
      expect(find.text('Queue upload'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Queue upload'), findsNothing);
      expect(find.text('View only'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Upload ready'), findsNothing);
      expect(selectedPlan, isNull);
    },
  );

  testWidgets(
    'SurveyDashboardContent keeps report viewer overview actions read-only',
    (tester) async {
      final survey = _survey().copyWith(responseCount: 1, targetResponses: 5);
      final response = _response(id: 'overview-sync');
      Survey? openedSurvey;
      SurveyResponseSyncReadiness? openedResponse;
      SurveyEvidenceUploadPlan? selectedPlan;

      await tester.pumpWidget(
        _dashboardContent(
          role: SurveyRole.reportViewer,
          selectedSection: SurveyWorkspaceSection.overview,
          surveys: [survey],
          responses: [response],
          onOpenSurvey: (survey) => openedSurvey = survey,
          onOpenResponse: (response) => openedResponse = response,
          onRunEvidenceUploadPlan: (plan) => selectedPlan = plan,
        ),
      );

      expect(find.text('Survey Operations Center'), findsOneWidget);
      expect(find.text('Collection Progress'), findsOneWidget);
      expect(find.text('Retail Audit'), findsWidgets);

      await tester.ensureVisible(find.text('Retail Audit').first);
      await tester.tap(find.text('Retail Audit').first);
      await tester.pump();

      expect(find.text('View only'), findsNWidgets(2));
      expect(find.byTooltip('Read-only survey summary'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Upload ready'), findsNothing);
      expect(openedSurvey, isNull);
      expect(openedResponse, isNull);
      expect(selectedPlan, isNull);
    },
  );

  testWidgets('SurveyDashboardScreen opens reports from sync activity strip', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SurveyDashboardScreen(
            initialRole: SurveyRole.admin,
            evidenceUploadQueueInsights: SurveyEvidenceUploadQueueInsights(
              queue: SurveyEvidenceUploadQueue(
                entries: [
                  SurveyEvidenceUploadQueueEntry(
                    id: 'response-1:evidence-1',
                    surveyId: 'survey-1',
                    responseId: 'response-1',
                    evidenceId: 'evidence-1',
                    action: SurveyEvidenceUploadAction.queueUpload,
                    priority: 2,
                    status: SurveyEvidenceUploadQueueStatus.uploading,
                    createdAt: _now,
                    updatedAt: _now,
                  ),
                ],
              ),
              now: _now,
            ),
          ),
        ),
      ),
    );

    expect(_contentText('Overview'), findsOneWidget);
    expect(find.text('Evidence upload running'), findsOneWidget);

    await tester.tap(find.byType(SurveyEvidenceSyncActivityStrip));
    await tester.pump();

    expect(_contentText('Reports'), findsOneWidget);
  });

  testWidgets('SurveyDashboardScreen scopes available header roles', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SurveyDashboardScreen(
            initialRole: SurveyRole.admin,
            availableRoles: [SurveyRole.admin, SurveyRole.analyst],
          ),
        ),
      ),
    );

    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Analyst'), findsOneWidget);
    expect(find.text('Participant'), findsNothing);
  });

  testWidgets('SurveyDashboardScreen resolves unavailable initial roles', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SurveyDashboardScreen(
            initialRole: SurveyRole.reportViewer,
            availableRoles: [SurveyRole.admin, SurveyRole.analyst],
          ),
        ),
      ),
    );

    expect(find.text('Admin workspace'), findsOneWidget);
    expect(find.byTooltip('Switch to Report Room'), findsNothing);
    expect(find.byTooltip('Switch to Insight Lab'), findsOneWidget);
  });

  testWidgets('SurveyDashboardScreen reapplies role scope after updates', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SurveyDashboardScreen(
            initialRole: SurveyRole.admin,
            availableRoles: [SurveyRole.admin, SurveyRole.analyst],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Analyst'));
    await tester.pump();

    expect(find.text('Analyst workspace'), findsOneWidget);
    expect(_contentText('Analytics'), findsOneWidget);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SurveyDashboardScreen(
            initialRole: SurveyRole.admin,
            availableRoles: [SurveyRole.admin],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Admin workspace'), findsOneWidget);
    expect(_contentText('Analytics'), findsOneWidget);
    expect(find.text('Analyst'), findsNothing);
  });
}

Widget _dashboardContent({
  SurveyRole role = SurveyRole.admin,
  SurveyWorkspaceSection selectedSection = SurveyWorkspaceSection.overview,
  List<Survey> surveys = const [],
  List<SurveyResponse> responses = const [],
  Set<String> activeEvidenceUploadKeys = const {},
  List<SurveyRole> availableRoles = SurveyRole.values,
  ValueChanged<SurveyRole>? onRoleChanged,
  VoidCallback? onOpenEvidenceSyncActivity,
  ValueChanged<Survey>? onOpenSurvey,
  ValueChanged<SurveyResponseSyncReadiness>? onOpenResponse,
  void Function(SurveyResponse, SurveyResponseReviewStatus)?
  onResponseReviewStatusChanged,
  void Function(SurveyEvidenceUploadPlan)? onRunEvidenceUploadPlan,
}) {
  final evidenceSyncInsights = SurveyEvidenceSyncInsights(
    surveys: surveys,
    responses: responses,
  );
  final responseQualityInsights = SurveyResponseQualityInsights(
    surveys: surveys,
    responses: responses,
  );

  return MaterialApp(
    home: Scaffold(
      body: SurveyDashboardContent(
        role: role,
        selectedSection: selectedSection,
        insights: SurveyInsights(surveys),
        fieldworkInsights: SurveyFieldworkInsights(
          surveys: surveys,
          assignments: const [],
        ),
        responseInsights: SurveyResponseInsights(
          surveys: surveys,
          responses: responses,
        ),
        evidenceSyncInsights: evidenceSyncInsights,
        responseQualityInsights: responseQualityInsights,
        responseReviewInsights: SurveyResponseReviewInsights(
          surveys: surveys,
          responses: responses,
          qualityInsights: responseQualityInsights,
        ),
        responseSyncReadiness: SurveyResponseSyncReadinessInsights.evaluate(
          surveys: surveys,
          responses: responses,
        ),
        surveys: surveys,
        isWide: true,
        onRoleChanged: onRoleChanged ?? (_) {},
        availableRoles: availableRoles,
        onEditSurvey: (_) {},
        onOpenSurvey: onOpenSurvey ?? (_) {},
        onOpenResponse: onOpenResponse ?? (_) {},
        onAssignmentStatusChanged: (_, _) {},
        onResponseReviewStatusChanged:
            onResponseReviewStatusChanged ?? (_, _) {},
        onStatusChanged: (_, _) {},
        onRunEvidenceUploadPlan: onRunEvidenceUploadPlan ?? (_) {},
        runEvidenceUploadPlanLabel: 'Upload ready',
        onQueueEvidenceUpload: (_) {},
        onRetryEvidenceUpload: (_) {},
        onFixEvidenceUpload: (_) {},
        onMonitorEvidenceUpload: (_) {},
        activeEvidenceUploadKeys: activeEvidenceUploadKeys,
        onOpenEvidenceSyncActivity: onOpenEvidenceSyncActivity,
      ),
    ),
  );
}

Finder _contentText(String text) {
  return find.descendant(
    of: find.byType(SurveyDashboardContent),
    matching: find.text(text),
  );
}

final _now = DateTime(2026, 6, 10, 10);

Survey _survey() {
  return Survey(
    id: 'retail-audit',
    title: 'Retail Audit',
    description: 'Dashboard sync activity',
    createdAt: DateTime(2026),
    questions: const [],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'display-image',
        kind: SurveyEvidenceKind.image,
        label: 'Display image',
        requireUploaded: true,
      ),
    ],
  );
}

SurveyResponse _response({required String id}) {
  return SurveyResponse(
    id: id,
    surveyId: 'retail-audit',
    respondentId: 'participant-$id',
    respondentName: 'Participant $id',
    startedAt: _now.subtract(const Duration(minutes: 20)),
    status: SurveyResponseStatus.submitted,
    evidence: [
      SurveyEvidence.attachment(
        id: 'evidence-$id',
        attachment: SurveyAttachment(
          id: 'attachment-$id',
          type: SurveyAttachmentType.image,
          fileName: '$id.jpg',
          capturedAt: _now.subtract(const Duration(minutes: 10)),
          localPath: '/local/$id.jpg',
        ),
        metadata: const {'requirementId': 'display-image'},
      ),
    ],
  );
}
