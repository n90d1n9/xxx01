import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_queue_insights.dart';
import 'package:ky_survey/analytics/survey_insights.dart';
import 'package:ky_survey/analytics/survey_operations_center_insights.dart';
import 'package:ky_survey/analytics/survey_response_sync_readiness.dart';
import 'package:ky_survey/logic/survey_evidence_upload_activity_tracker.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue.dart';
import 'package:ky_survey/models/answer.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/widgets/dashboard/survey_operations_center_panel.dart';
import 'package:ky_survey/widgets/dashboard/survey_overview_section.dart';

void main() {
  group('SurveyOperationsCenterInsights', () {
    test('prioritizes failed queue work before ready upload work', () {
      final survey = _survey();
      final response = _response(
        id: 'ready-upload',
        answer: 'Display is clean',
        evidenceStatus: SurveyAttachmentUploadStatus.failed,
      );
      final evidenceSyncInsights = SurveyEvidenceSyncInsights(
        surveys: [survey],
        responses: [response],
      );
      final task = SurveyEvidenceUploadTask.fromSyncItem(
        evidenceSyncInsights.items.single,
      );
      final failedEntry =
          SurveyEvidenceUploadQueueEntry.fromTask(
            task,
            queuedAt: _now.subtract(const Duration(hours: 2)),
            nextAttemptAt: _now.subtract(const Duration(hours: 1)),
          ).copyWith(
            status: SurveyEvidenceUploadQueueStatus.failed,
            lastError: 'network unavailable',
            clearNextAttemptAt: true,
          );

      final insights = _operationsInsights(
        surveys: [survey],
        responses: [response],
        evidenceSyncInsights: evidenceSyncInsights,
        queueInsights: SurveyEvidenceUploadQueueInsights(
          queue: SurveyEvidenceUploadQueue(entries: [failedEntry]),
          now: _now,
        ),
      );

      expect(insights.health, SurveyOperationsCenterHealth.attention);
      expect(
        insights.primaryAction.kind,
        SurveyOperationsCenterActionKind.requeueFailedUploads,
      );
      expect(insights.readyEvidenceUploadCount, 1);
      expect(insights.queueDepth, 1);
      expect(insights.detailLabel, '2 items need follow-up');
    });

    test('uses the fieldwork queue when responses need review', () {
      final survey = _survey();
      final response = _response(id: 'missing-answer');

      final insights = _operationsInsights(
        surveys: [survey],
        responses: [response],
      );

      expect(insights.health, SurveyOperationsCenterHealth.attention);
      expect(
        insights.primaryAction.kind,
        SurveyOperationsCenterActionKind.openFieldworkQueue,
      );
      expect(insights.nextResponseAction?.response.id, 'missing-answer');
      expect(insights.primaryAction.title, 'Review fieldwork blockers');
    });
  });

  group('SurveyOperationsCenterPanel', () {
    testWidgets('runs the upload plan from the primary operation', (
      tester,
    ) async {
      final survey = _survey();
      final response = _response(
        id: 'ready-upload',
        answer: 'Display is clean',
        evidenceStatus: SurveyAttachmentUploadStatus.local,
      );
      final insights = _operationsInsights(
        surveys: [survey],
        responses: [response],
      );
      SurveyEvidenceUploadPlan? selectedPlan;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SurveyOperationsCenterPanel(
              insights: insights,
              runEvidenceUploadPlanLabel: 'Upload now',
              onRunEvidenceUploadPlan: (plan) => selectedPlan = plan,
            ),
          ),
        ),
      );

      expect(find.text('Survey Operations Center'), findsOneWidget);
      expect(find.text('Upload ready evidence'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Upload now'));
      await tester.pump();

      expect(selectedPlan?.uploadableTasks.length, 1);
    });

    testWidgets(
      'pauses upload plan command when ready work is already active',
      (tester) async {
        final survey = _survey();
        final response = _response(
          id: 'ready-upload',
          answer: 'Display is clean',
          evidenceStatus: SurveyAttachmentUploadStatus.local,
        );
        final insights = _operationsInsights(
          surveys: [survey],
          responses: [response],
        );
        final activeTask = insights.uploadPlan.uploadableTasks.single;
        SurveyEvidenceUploadPlan? selectedPlan;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SurveyOperationsCenterPanel(
                insights: insights,
                runEvidenceUploadPlanLabel: 'Upload now',
                activeEvidenceUploadKeys: {
                  SurveyEvidenceUploadActivityTracker.keyFor(activeTask),
                },
                onRunEvidenceUploadPlan: (plan) => selectedPlan = plan,
              ),
            ),
          ),
        );

        expect(
          find.widgetWithText(FilledButton, 'Uploading...'),
          findsOneWidget,
        );

        await tester.tap(
          find.widgetWithText(FilledButton, 'Uploading...'),
          warnIfMissed: false,
        );
        await tester.pump();

        expect(selectedPlan, isNull);
      },
    );

    testWidgets('shows primary operation status without a direct command', (
      tester,
    ) async {
      final survey = _survey();
      final response = _response(
        id: 'ready-upload',
        answer: 'Display is clean',
        evidenceStatus: SurveyAttachmentUploadStatus.local,
      );
      final insights = _operationsInsights(
        surveys: [survey],
        responses: [response],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SurveyOperationsCenterPanel(insights: insights)),
        ),
      );

      expect(find.text('Upload ready evidence'), findsOneWidget);
      expect(find.text('View only'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Upload ready'), findsNothing);
    });

    testWidgets('is available from the survey overview section', (
      tester,
    ) async {
      final survey = _survey();
      final response = _response(
        id: 'ready-upload',
        answer: 'Display is clean',
        evidenceStatus: SurveyAttachmentUploadStatus.local,
      );
      final evidenceSyncInsights = SurveyEvidenceSyncInsights(
        surveys: [survey],
        responses: [response],
      );
      final responseReadiness = SurveyResponseSyncReadinessInsights.evaluate(
        surveys: [survey],
        responses: [response],
        now: _now,
      );
      SurveyEvidenceUploadPlan? selectedPlan;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SurveyOverviewSection(
                insights: SurveyInsights([survey]),
                responseSyncReadiness: responseReadiness,
                evidenceSyncInsights: evidenceSyncInsights,
                surveys: [survey],
                onOpenSurvey: (_) {},
                runEvidenceUploadPlanLabel: 'Upload now',
                onRunEvidenceUploadPlan: (plan) => selectedPlan = plan,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Survey Operations Center'), findsOneWidget);
      expect(find.text('Upload ready evidence'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Upload now'));
      await tester.pump();

      expect(selectedPlan?.uploadableTasks.length, 1);
    });
  });
}

final _now = DateTime(2026, 6, 9, 10);

SurveyOperationsCenterInsights _operationsInsights({
  required List<Survey> surveys,
  required List<SurveyResponse> responses,
  SurveyEvidenceSyncInsights? evidenceSyncInsights,
  SurveyEvidenceUploadQueueInsights? queueInsights,
}) {
  final syncInsights =
      evidenceSyncInsights ??
      SurveyEvidenceSyncInsights(surveys: surveys, responses: responses);

  return SurveyOperationsCenterInsights.evaluate(
    responseReadiness: SurveyResponseSyncReadinessInsights.evaluate(
      surveys: surveys,
      responses: responses,
      now: _now,
    ),
    evidenceSyncInsights: syncInsights,
    uploadQueueInsights: queueInsights,
  );
}

Survey _survey() {
  return Survey(
    id: 'retail-audit',
    title: 'Retail Audit',
    description: 'Store audit',
    createdAt: DateTime(2026),
    questions: [
      Question(
        id: 'q1',
        text: 'What did you observe?',
        type: QuestionType.singleLineText,
        required: true,
      ),
    ],
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

SurveyResponse _response({
  required String id,
  String? answer,
  SurveyAttachmentUploadStatus? evidenceStatus,
}) {
  return SurveyResponse(
    id: id,
    surveyId: 'retail-audit',
    respondentId: 'participant-$id',
    respondentName: 'Participant $id',
    startedAt: _now.subtract(const Duration(minutes: 12)),
    answers: answer == null
        ? const []
        : [
            ResponseAnswer(
              questionId: 'q1',
              value: answer,
              answeredAt: _now.subtract(const Duration(minutes: 4)),
            ),
          ],
    evidence: evidenceStatus == null
        ? const []
        : [_imageEvidence(id: id, status: evidenceStatus)],
  );
}

SurveyEvidence _imageEvidence({
  required String id,
  required SurveyAttachmentUploadStatus status,
}) {
  return SurveyEvidence.attachment(
    id: 'evidence-$id',
    attachment: SurveyAttachment(
      id: 'attachment-$id',
      type: SurveyAttachmentType.image,
      fileName: '$id.jpg',
      capturedAt: _now.subtract(const Duration(minutes: 2)),
      localPath: '/local/$id.jpg',
      uploadStatus: status,
      uploadError: status == SurveyAttachmentUploadStatus.failed
          ? 'network unavailable'
          : null,
    ),
    metadata: const {'requirementId': 'display-image'},
  );
}
