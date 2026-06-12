import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_focus_state.dart';
import 'package:ky_survey/logic/survey_response_view_intent.dart';
import 'package:ky_survey/logic/survey_response_viewer_focus_resolver.dart';
import 'package:ky_survey/logic/survey_response_viewer_snapshot.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';

void main() {
  group('SurveyResponseViewerFocusResolver', () {
    test('preserves the existing focus state without an intent', () {
      const initial = SurveyResponseFocusState(
        selectedPageIndex: 1,
        focusedQuestionId: 'stock-note',
        questionFocusRequestId: 2,
      );

      final resolved = SurveyResponseViewerFocusResolver.resolveInitialFocus(
        intent: null,
        snapshot: _viewerSnapshot(),
        initialState: initial,
      );

      expect(resolved.selectedPageIndex, 1);
      expect(resolved.focusedQuestionId, 'stock-note');
      expect(resolved.questionFocusRequestId, 2);
    });

    test('prioritizes an explicit intent question target', () {
      final resolved = SurveyResponseViewerFocusResolver.resolveInitialFocus(
        intent: const SurveyResponseViewerIntent(
          focus: SurveyResponseViewerFocus.uploadIssue,
          title: 'Review upload',
          detail: 'Attachment needs attention',
          focusQuestionId: 'stock-note',
        ),
        snapshot: _viewerSnapshot(),
      );

      expect(resolved.selectedPageIndex, 1);
      expect(resolved.focusedQuestionId, 'stock-note');
      expect(resolved.questionFocusRequestId, 1);
    });

    test('focuses the first answer issue when resuming answers', () {
      final resolved = SurveyResponseViewerFocusResolver.resolveInitialFocus(
        intent: const SurveyResponseViewerIntent(
          focus: SurveyResponseViewerFocus.answerIssue,
          title: 'Resume answers',
          detail: 'Answers need attention',
        ),
        snapshot: _viewerSnapshot(),
      );

      expect(resolved.selectedPageIndex, 0);
      expect(resolved.focusedQuestionId, 'visitors');
      expect(resolved.questionFocusRequestId, 1);
      expect(resolved.focusedRequirementId, isNull);
    });

    test('focuses question-scoped evidence requirements', () {
      final resolved = SurveyResponseViewerFocusResolver.resolveInitialFocus(
        intent: const SurveyResponseViewerIntent(
          focus: SurveyResponseViewerFocus.evidenceIssue,
          title: 'Fix evidence',
          detail: 'GPS evidence is missing',
        ),
        snapshot: _viewerSnapshot(),
      );

      expect(resolved.selectedPageIndex, 0);
      expect(resolved.focusedQuestionId, 'store-name');
      expect(resolved.focusedRequirementId, 'gps-check-in');
      expect(resolved.questionFocusRequestId, 1);
      expect(resolved.evidenceFocusRequestId, 1);
    });

    test(
      'focuses response-level evidence without changing the selected page',
      () {
        final resolved = SurveyResponseViewerFocusResolver.resolveInitialFocus(
          intent: const SurveyResponseViewerIntent(
            focus: SurveyResponseViewerFocus.evidenceIssue,
            title: 'Fix evidence',
            detail: 'Interview audio is missing',
          ),
          snapshot: _viewerSnapshot(responseLevelEvidence: true),
          initialState: const SurveyResponseFocusState(selectedPageIndex: 1),
        );

        expect(resolved.selectedPageIndex, 1);
        expect(resolved.focusedQuestionId, isNull);
        expect(resolved.focusedRequirementId, 'interview-audio');
        expect(resolved.questionFocusRequestId, 0);
        expect(resolved.evidenceFocusRequestId, 1);
      },
    );

    test(
      'falls back to the checklist when evidence question target is gone',
      () {
        final resolved = SurveyResponseViewerFocusResolver.resolveInitialFocus(
          intent: const SurveyResponseViewerIntent(
            focus: SurveyResponseViewerFocus.evidenceIssue,
            title: 'Fix evidence',
            detail: 'Photo evidence is missing',
          ),
          snapshot: _viewerSnapshot(staleQuestionEvidence: true),
          initialState: const SurveyResponseFocusState(selectedPageIndex: 1),
        );

        expect(resolved.selectedPageIndex, 1);
        expect(resolved.focusedQuestionId, isNull);
        expect(resolved.focusedRequirementId, 'removed-question-photo');
        expect(resolved.questionFocusRequestId, 0);
        expect(resolved.evidenceFocusRequestId, 1);
      },
    );

    test('moves submit review intents to the final page', () {
      final resolved = SurveyResponseViewerFocusResolver.resolveInitialFocus(
        intent: const SurveyResponseViewerIntent(
          focus: SurveyResponseViewerFocus.submitReview,
          title: 'Ready to submit',
          detail: 'Review before sending',
        ),
        snapshot: _viewerSnapshot(),
      );

      expect(resolved.selectedPageIndex, 1);
      expect(resolved.focusedQuestionId, isNull);
      expect(resolved.focusedRequirementId, isNull);
    });
  });
}

SurveyResponseViewerSnapshot _viewerSnapshot({
  bool responseLevelEvidence = false,
  bool staleQuestionEvidence = false,
}) {
  final fixture = _FocusResolverFixture.create(
    responseLevelEvidence: responseLevelEvidence,
    staleQuestionEvidence: staleQuestionEvidence,
  );
  return SurveyResponseViewerSnapshot.evaluate(
    survey: fixture.survey,
    response: fixture.response,
    requestedPageIndex: 0,
  );
}

/// Provides survey and response data for focus resolver tests.
class _FocusResolverFixture {
  final Survey survey;
  final SurveyResponse response;

  const _FocusResolverFixture({required this.survey, required this.response});

  factory _FocusResolverFixture.create({
    required bool responseLevelEvidence,
    required bool staleQuestionEvidence,
  }) {
    final survey = Survey(
      id: 'focus-resolver-survey',
      title: 'Focus Resolver Survey',
      description: 'Initial focus rules',
      createdAt: DateTime(2026),
      sections: const [
        SurveySection(id: 'visit', title: 'Visit', order: 0),
        SurveySection(id: 'stock', title: 'Stock', order: 1),
      ],
      evidenceRequirements: [
        responseLevelEvidence
            ? const SurveyEvidenceRequirement(
                id: 'interview-audio',
                kind: SurveyEvidenceKind.audio,
                scope: SurveyEvidenceScope.response,
                label: 'Interview audio',
              )
            : staleQuestionEvidence
            ? const SurveyEvidenceRequirement(
                id: 'removed-question-photo',
                kind: SurveyEvidenceKind.image,
                scope: SurveyEvidenceScope.question,
                questionId: 'removed-question',
                label: 'Removed question photo',
              )
            : const SurveyEvidenceRequirement(
                id: 'gps-check-in',
                kind: SurveyEvidenceKind.location,
                scope: SurveyEvidenceScope.question,
                questionId: 'store-name',
                label: 'GPS check-in',
              ),
      ],
      questions: [
        Question(
          id: 'store-name',
          text: 'Store name',
          type: QuestionType.singleLineText,
          required: true,
          sectionId: 'visit',
        ),
        Question(
          id: 'visitors',
          text: 'Visitor count',
          type: QuestionType.number,
          required: true,
          sectionId: 'visit',
        ),
        Question(
          id: 'stock-note',
          text: 'Stock note',
          type: QuestionType.singleLineText,
          required: true,
          sectionId: 'stock',
        ),
      ],
    );
    final response =
        SurveyResponse(
              id: 'focus-resolver-response',
              surveyId: survey.id,
              respondentId: 'participant',
              respondentName: 'Participant',
              startedAt: DateTime(2026),
            )
            .upsertAnswer(questionId: 'store-name', value: 'Kaysir Mart')
            .upsertAnswer(questionId: 'visitors', value: 'many');

    return _FocusResolverFixture(survey: survey, response: response);
  }
}
