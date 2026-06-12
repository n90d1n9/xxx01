import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_activity_tracker.dart';
import 'package:ky_survey/logic/survey_response_evidence_summary.dart';
import 'package:ky_survey/logic/survey_response_session_summary.dart';
import 'package:ky_survey/logic/survey_response_view_intent.dart';
import 'package:ky_survey/logic/survey_evidence_upload_execution_feedback.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/widgets/evidence_response/evidence_upload_execution_feedback_snack_bar.dart';
import 'package:ky_survey/widgets/evidence_response/evidence_upload_review_sheet.dart';
import 'package:ky_survey/widgets/survey_response_evidence_checklist.dart';
import 'package:ky_survey/widgets/survey_response_intent_banner.dart';
import 'package:ky_survey/widgets/survey_response_navigation_bar.dart';

void main() {
  group('response intent widgets', () {
    testWidgets('intent banner renders a contextual action', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _WidgetHarness(
          child: SurveyResponseIntentBanner(
            intent: const SurveyResponseViewerIntent(
              focus: SurveyResponseViewerFocus.evidenceIssue,
              title: 'Fix evidence',
              detail: 'Display image is required',
            ),
            actionLabel: 'Open evidence',
            onAction: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Fix evidence'), findsOneWidget);
      expect(find.text('Display image is required'), findsOneWidget);
      expect(find.text('Open evidence'), findsOneWidget);

      await tester.tap(find.text('Open evidence'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('evidence checklist highlights the next action', (
      tester,
    ) async {
      final survey = _evidenceSurvey();
      final summary = SurveyResponseEvidenceSummary.evaluate(
        survey: survey,
        response: _responseFor(survey),
      );
      SurveyEvidenceRequirement? selectedRequirement;
      SurveyEvidenceRequirementStatus? selectedStatus;

      await tester.pumpWidget(
        _WidgetHarness(
          child: SurveyResponseEvidenceChecklist(
            summary: summary,
            highlighted: true,
            onRequirementSelected: (requirement) {
              selectedRequirement = requirement;
            },
            onRequirementStatusSelected: (status) {
              selectedStatus = status;
            },
          ),
        ),
      );

      expect(find.text('Evidence checklist'), findsOneWidget);
      expect(find.text('Display image'), findsOneWidget);
      expect(find.text('Next action'), findsOneWidget);

      await tester.tap(find.text('Display image'));
      await tester.pump();

      expect(selectedRequirement?.id, 'image-q1');
      expect(selectedStatus?.requirement.id, 'image-q1');
      expect(selectedStatus?.requirement.questionId, 'name');
    });

    testWidgets('upload review sheet renders failed upload context', (
      tester,
    ) async {
      final item = _uploadItem();
      SurveyEvidenceSyncItem? selectedItem;
      SurveyEvidenceUploadTask? retryTask;

      await tester.pumpWidget(
        _WidgetHarness(
          child: SurveyEvidenceUploadReviewSheet(
            items: [item],
            focusedQuestionId: 'name',
            onItemSelected: (item) => selectedItem = item,
            onRetryUpload: (task) => retryTask = task,
          ),
        ),
      );

      expect(find.text('Evidence upload review'), findsOneWidget);
      expect(find.text('1 failed upload needs review'), findsOneWidget);
      expect(find.text('Display image'), findsOneWidget);
      expect(find.text('network timeout'), findsOneWidget);
      expect(
        find.text(
          'Retry from the evidence upload queue or capture a replacement.',
        ),
        findsOneWidget,
      );
      expect(find.text('Retry upload'), findsOneWidget);

      await tester.tap(find.text('Retry upload'));
      await tester.pump();

      expect(retryTask?.item, same(item));
      await tester.tap(find.text('Focus question'));
      await tester.pump();

      expect(selectedItem, same(item));
    });

    testWidgets('upload review sheet disables active upload actions', (
      tester,
    ) async {
      final item = _uploadItem();
      final task = SurveyEvidenceUploadTask.fromSyncItem(item);
      var retryCount = 0;

      await tester.pumpWidget(
        _WidgetHarness(
          child: SurveyEvidenceUploadReviewSheet(
            items: [item],
            activeUploadKeys: {
              SurveyEvidenceUploadActivityTracker.keyFor(task),
            },
            onRetryUpload: (_) => retryCount += 1,
          ),
        ),
      );

      expect(find.text('Uploading...'), findsOneWidget);
      expect(find.text('Retry upload'), findsNothing);
      expect(
        find.text(
          'Upload is in progress. Actions are paused until this attempt finishes.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Uploading...'), warnIfMissed: false);
      await tester.pump();

      expect(retryCount, 0);
    });

    testWidgets('upload execution snackbar uses feedback tone and copy', (
      tester,
    ) async {
      late SnackBar snackBar;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              snackBar = SurveyEvidenceUploadExecutionSnackBar.build(
                context,
                const SurveyEvidenceUploadExecutionFeedback(
                  tone: SurveyEvidenceUploadExecutionFeedbackTone.error,
                  title: 'Upload failed',
                  message: 'Display image: network timeout',
                ),
              );
              return Scaffold(body: snackBar.content);
            },
          ),
        ),
      );

      expect(find.text('Upload failed'), findsOneWidget);
      expect(find.text('Display image: network timeout'), findsOneWidget);
      expect(snackBar.backgroundColor, ThemeData().colorScheme.error);
      expect(snackBar.behavior, SnackBarBehavior.floating);
    });

    testWidgets('navigation bar uses intent submit copy', (tester) async {
      var submitted = false;
      final survey = _simpleSurvey();
      final response = _responseFor(
        survey,
      ).upsertAnswer(questionId: 'name', value: 'Kaysir Mart');
      final summary = SurveyResponseSessionSummary.evaluate(
        survey: survey,
        response: response,
      );

      await tester.pumpWidget(
        _WidgetHarness(
          child: SurveyResponseNavigationBar(
            summary: summary,
            pageCount: 1,
            selectedPageIndex: 0,
            onPrevious: null,
            onNext: null,
            onSubmit: () => submitted = true,
            submitLabel: 'Submit now',
          ),
        ),
      );

      expect(find.text('Submit now'), findsOneWidget);

      await tester.tap(find.text('Submit now'));
      await tester.pump();

      expect(submitted, isTrue);
    });
  });
}

class _WidgetHarness extends StatelessWidget {
  final Widget child;

  const _WidgetHarness({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      ),
    );
  }
}

Survey _simpleSurvey() {
  return Survey(
    id: 'simple-survey',
    title: 'Simple Survey',
    description: 'Submit-ready survey',
    createdAt: DateTime(2026),
    questions: [
      Question(
        id: 'name',
        text: 'Store name',
        type: QuestionType.singleLineText,
        required: true,
      ),
    ],
  );
}

Survey _evidenceSurvey() {
  return _simpleSurvey().copyWith(
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'image-q1',
        kind: SurveyEvidenceKind.image,
        scope: SurveyEvidenceScope.question,
        questionId: 'name',
        label: 'Display image',
      ),
    ],
  );
}

SurveyResponse _responseFor(Survey survey) {
  return SurveyResponse(
    id: 'response-1',
    surveyId: survey.id,
    respondentId: 'participant-1',
    respondentName: 'Participant',
    startedAt: DateTime(2026),
  );
}

SurveyEvidenceSyncItem _uploadItem() {
  final survey = _evidenceSurvey().copyWith(
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'image-q1',
        kind: SurveyEvidenceKind.image,
        scope: SurveyEvidenceScope.question,
        questionId: 'name',
        label: 'Display image',
        requireUploaded: true,
      ),
    ],
  );
  final response = _responseFor(survey);
  final attachment = SurveyAttachment(
    id: 'attachment-1',
    type: SurveyAttachmentType.image,
    fileName: 'display.jpg',
    capturedAt: DateTime(2026, 1, 2, 9, 30),
    uploadStatus: SurveyAttachmentUploadStatus.failed,
    uploadError: 'network timeout',
  );
  final evidence = SurveyEvidence.attachment(
    id: 'evidence-1',
    attachment: attachment,
    scope: SurveyEvidenceScope.question,
    questionId: 'name',
    metadata: const {'requirementId': 'image-q1'},
  );

  return SurveyEvidenceSyncItem(
    survey: survey,
    response: response,
    evidence: evidence,
    attachment: attachment,
    requirement: survey.evidenceRequirements.single,
    issues: const [],
  );
}
