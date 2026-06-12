import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/logic/survey_response_focus_state.dart';
import 'package:ky_survey/logic/survey_response_section_flow.dart';
import 'package:ky_survey/logic/survey_response_upload_review_focus_target.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';

void main() {
  group('SurveyResponseUploadReviewFocusTarget', () {
    test('focuses question-scoped requirement uploads as evidence', () {
      final fixture = _uploadReviewFixture(
        requirement: const SurveyEvidenceRequirement(
          id: 'photo-check',
          kind: SurveyEvidenceKind.image,
          scope: SurveyEvidenceScope.question,
          questionId: 'store-photo',
          label: 'Store photo',
          requireUploaded: true,
        ),
        evidenceQuestionId: 'store-photo',
      );

      final target = SurveyResponseUploadReviewFocusTarget.resolve(
        sectionFlow: fixture.sectionFlow,
        item: fixture.item,
      );
      final focused = target.applyTo(const SurveyResponseFocusState());

      expect(target.canFocus, isTrue);
      expect(target.questionId, 'store-photo');
      expect(target.pageIndex, 0);
      expect(focused.selectedPageIndex, 0);
      expect(focused.focusedQuestionId, 'store-photo');
      expect(focused.focusedRequirementId, 'photo-check');
      expect(focused.questionFocusRequestId, 1);
      expect(focused.evidenceFocusRequestId, 1);
    });

    test('focuses question uploads without requirements as answer context', () {
      final fixture = _uploadReviewFixture(evidenceQuestionId: 'stock-note');

      final target = SurveyResponseUploadReviewFocusTarget.resolve(
        sectionFlow: fixture.sectionFlow,
        item: fixture.item,
      );
      final focused = target.applyTo(const SurveyResponseFocusState());

      expect(target.canFocus, isTrue);
      expect(target.questionId, 'stock-note');
      expect(target.pageIndex, 1);
      expect(focused.selectedPageIndex, 1);
      expect(focused.focusedQuestionId, 'stock-note');
      expect(focused.focusedRequirementId, isNull);
      expect(focused.questionFocusRequestId, 1);
      expect(focused.evidenceFocusRequestId, 0);
    });

    test('keeps current focus for response-level uploads', () {
      final fixture = _uploadReviewFixture(
        requirement: const SurveyEvidenceRequirement(
          id: 'interview-audio',
          kind: SurveyEvidenceKind.image,
          scope: SurveyEvidenceScope.response,
          label: 'Interview attachment',
          requireUploaded: true,
        ),
        evidenceScope: SurveyEvidenceScope.response,
      );
      const initial = SurveyResponseFocusState(
        selectedPageIndex: 1,
        focusedQuestionId: 'stock-note',
        questionFocusRequestId: 2,
      );

      final target = SurveyResponseUploadReviewFocusTarget.resolve(
        sectionFlow: fixture.sectionFlow,
        item: fixture.item,
      );
      final focused = target.applyTo(initial);

      expect(target.canFocus, isFalse);
      expect(target.questionId, isNull);
      expect(target.pageIndex, isNull);
      expect(target.fallbackMessage, contains('upload-photo.jpg'));
      expect(focused.selectedPageIndex, 1);
      expect(focused.focusedQuestionId, 'stock-note');
      expect(focused.questionFocusRequestId, 2);
      expect(focused.evidenceFocusRequestId, 0);
    });

    test('keeps current focus for stale question targets', () {
      final fixture = _uploadReviewFixture(
        requirement: const SurveyEvidenceRequirement(
          id: 'removed-photo',
          kind: SurveyEvidenceKind.image,
          scope: SurveyEvidenceScope.question,
          questionId: 'removed-question',
          label: 'Removed photo',
          requireUploaded: true,
        ),
        evidenceQuestionId: 'removed-question',
      );
      const initial = SurveyResponseFocusState(selectedPageIndex: 1);

      final target = SurveyResponseUploadReviewFocusTarget.resolve(
        sectionFlow: fixture.sectionFlow,
        item: fixture.item,
      );
      final focused = target.applyTo(initial);

      expect(target.canFocus, isFalse);
      expect(target.questionId, 'removed-question');
      expect(target.pageIndex, isNull);
      expect(focused.selectedPageIndex, 1);
      expect(focused.focusedRequirementId, isNull);
    });
  });
}

_UploadReviewFocusFixture _uploadReviewFixture({
  SurveyEvidenceRequirement? requirement,
  SurveyEvidenceScope evidenceScope = SurveyEvidenceScope.question,
  String? evidenceQuestionId,
}) {
  final survey = Survey(
    id: 'upload-review-focus-survey',
    title: 'Upload Review Focus Survey',
    description: 'Upload review focus behavior',
    createdAt: DateTime(2026),
    sections: const [
      SurveySection(id: 'visit', title: 'Visit', order: 0),
      SurveySection(id: 'stock', title: 'Stock', order: 1),
    ],
    evidenceRequirements: [?requirement],
    questions: [
      Question(
        id: 'store-photo',
        text: 'Store photo',
        type: QuestionType.singleLineText,
        required: false,
        sectionId: 'visit',
      ),
      Question(
        id: 'stock-note',
        text: 'Stock note',
        type: QuestionType.singleLineText,
        required: false,
        sectionId: 'stock',
      ),
    ],
  );
  final response = SurveyResponse(
    id: 'upload-review-focus-response',
    surveyId: survey.id,
    respondentId: 'participant',
    respondentName: 'Participant',
    startedAt: DateTime(2026),
  );
  final attachment = SurveyAttachment(
    id: 'upload-attachment',
    type: SurveyAttachmentType.image,
    fileName: 'upload-photo.jpg',
    capturedAt: DateTime(2026, 1, 2),
    uploadStatus: SurveyAttachmentUploadStatus.failed,
  );
  final evidence = SurveyEvidence.attachment(
    id: 'upload-evidence',
    attachment: attachment,
    scope: evidenceScope,
    questionId: evidenceQuestionId,
    metadata: {if (requirement != null) 'requirementId': requirement.id},
  );

  return _UploadReviewFocusFixture(
    sectionFlow: SurveyResponseSectionFlow(survey: survey, response: response),
    item: SurveyEvidenceSyncItem(
      survey: survey,
      response: response,
      evidence: evidence,
      attachment: attachment,
      requirement: requirement,
      issues: const [],
    ),
  );
}

/// Holds flow and sync item objects for upload review focus target tests.
class _UploadReviewFocusFixture {
  final SurveyResponseSectionFlow sectionFlow;
  final SurveyEvidenceSyncItem item;

  const _UploadReviewFocusFixture({
    required this.sectionFlow,
    required this.item,
  });
}
