import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/widgets/evidence_upload_task_action_button.dart';

void main() {
  testWidgets('evidence upload task action button disables active uploads', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SurveyEvidenceUploadTaskActionButton(
            task: _uploadTask(action: SurveyEvidenceUploadAction.retryUpload),
            active: true,
            onPressed: () => tapped = true,
            style: SurveyEvidenceUploadTaskActionButtonStyle.outlined,
          ),
        ),
      ),
    );

    expect(find.text('Uploading...'), findsOneWidget);

    await tester.tap(find.text('Uploading...'), warnIfMissed: false);
    await tester.pump();

    expect(tapped, isFalse);
  });

  testWidgets('evidence upload task action button forwards available actions', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SurveyEvidenceUploadTaskActionButton(
            task: _uploadTask(action: SurveyEvidenceUploadAction.queueUpload),
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Queue upload'), findsOneWidget);

    await tester.tap(find.text('Queue upload'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}

SurveyEvidenceUploadTask _uploadTask({
  required SurveyEvidenceUploadAction action,
}) {
  final survey = Survey(
    id: 'survey-1',
    title: 'Field Audit',
    description: 'Upload action button test',
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
    id: 'photo-1',
    type: SurveyAttachmentType.image,
    fileName: 'photo-1.dat',
    capturedAt: DateTime(2026),
    localPath: '/local/photo-1.dat',
  );
  final evidence = SurveyEvidence.attachment(
    id: 'photo-1',
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

  return SurveyEvidenceUploadTask(item: item, action: action);
}
