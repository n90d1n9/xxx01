import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_activity_tracker.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/widgets/dashboard/survey_evidence_upload_plan_panel.dart';

void main() {
  testWidgets('upload plan panel disables actions for active uploads', (
    tester,
  ) async {
    final activeTask = _uploadTask(evidenceId: 'photo-active');
    final readyTask = _uploadTask(evidenceId: 'photo-ready');
    final activeKey = SurveyEvidenceUploadActivityTracker.keyFor(activeTask);
    SurveyEvidenceUploadTask? queuedTask;
    SurveyEvidenceUploadPlan? selectedPlan;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SurveyEvidenceUploadPlanPanel(
            plan: SurveyEvidenceUploadPlan(tasks: [activeTask, readyTask]),
            runUploadPlanLabel: 'Upload now',
            activeUploadKeys: {activeKey},
            onRunUploadPlan: (plan) => selectedPlan = plan,
            onQueueUpload: (task) => queuedTask = task,
          ),
        ),
      ),
    );

    expect(find.text('1 ready • 1 uploading'), findsOneWidget);
    expect(find.text('Uploading...'), findsOneWidget);
    expect(find.text('Queue upload'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Queue upload'));
    await tester.pump();

    expect(queuedTask, same(readyTask));

    await tester.tap(find.widgetWithText(FilledButton, 'Upload now'));
    await tester.pump();

    expect(selectedPlan?.tasks, [activeTask, readyTask]);
  });
}

SurveyEvidenceUploadTask _uploadTask({required String evidenceId}) {
  final survey = Survey(
    id: 'survey-1',
    title: 'Field Audit',
    description: 'Upload panel test',
    createdAt: DateTime(2026),
    questions: const [],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'upload-required',
        kind: SurveyEvidenceKind.image,
        label: 'Upload evidence',
        requireUploaded: true,
      ),
    ],
  );
  final response = SurveyResponse(
    id: 'response-1',
    surveyId: survey.id,
    respondentId: 'participant-1',
    respondentName: 'Participant',
    startedAt: DateTime(2026),
  );
  final attachment = SurveyAttachment(
    id: evidenceId,
    type: SurveyAttachmentType.image,
    fileName: '$evidenceId.dat',
    capturedAt: DateTime(2026),
    localPath: '/local/$evidenceId.dat',
  );
  final evidence = SurveyEvidence.attachment(
    id: evidenceId,
    attachment: attachment,
    metadata: const {'requirementId': 'upload-required'},
  );
  final item = SurveyEvidenceSyncItem(
    survey: survey,
    response: response,
    evidence: evidence,
    attachment: attachment,
    requirement: survey.evidenceRequirements.single,
    issues: const [],
  );

  return SurveyEvidenceUploadTask(
    item: item,
    action: SurveyEvidenceUploadAction.queueUpload,
  );
}
