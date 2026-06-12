import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_evidence_focus_target.dart';
import 'package:ky_survey/logic/survey_response_evidence_summary.dart';
import 'package:ky_survey/logic/survey_response_focus_state.dart';
import 'package:ky_survey/logic/survey_response_section_flow.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';

void main() {
  group('SurveyResponseEvidenceFocusTarget', () {
    test('focuses question-scoped evidence on its response section', () {
      final fixture = _focusTargetFixture(
        requirement: const SurveyEvidenceRequirement(
          id: 'gps-check-in',
          kind: SurveyEvidenceKind.location,
          scope: SurveyEvidenceScope.question,
          questionId: 'store-name',
          label: 'GPS check-in',
        ),
      );
      final status = fixture.statusById('gps-check-in');

      final target = SurveyResponseEvidenceFocusTarget.resolve(
        sectionFlow: fixture.sectionFlow,
        status: status,
      );
      final focused = target.applyTo(const SurveyResponseFocusState());

      expect(target.pageIndex, 0);
      expect(target.questionId, 'store-name');
      expect(target.pageTitle, 'Visit');
      expect(target.locationSuffix, ' - check Visit');
      expect(focused.selectedPageIndex, 0);
      expect(focused.focusedQuestionId, 'store-name');
      expect(focused.focusedRequirementId, 'gps-check-in');
      expect(focused.questionFocusRequestId, 1);
      expect(focused.evidenceFocusRequestId, 1);
    });

    test('keeps response-level evidence focused on the checklist', () {
      final fixture = _focusTargetFixture(
        requirement: const SurveyEvidenceRequirement(
          id: 'interview-audio',
          kind: SurveyEvidenceKind.audio,
          scope: SurveyEvidenceScope.response,
          label: 'Interview audio',
        ),
      );
      final status = fixture.statusById('interview-audio');

      final target = SurveyResponseEvidenceFocusTarget.resolve(
        sectionFlow: fixture.sectionFlow,
        status: status,
      );
      final focused = target.applyTo(
        const SurveyResponseFocusState(selectedPageIndex: 1),
      );

      expect(target.pageIndex, isNull);
      expect(target.questionId, isNull);
      expect(target.pageTitle, isNull);
      expect(target.locationSuffix, ' - check evidence checklist');
      expect(focused.selectedPageIndex, 1);
      expect(focused.focusedQuestionId, isNull);
      expect(focused.focusedRequirementId, 'interview-audio');
      expect(focused.questionFocusRequestId, 0);
      expect(focused.evidenceFocusRequestId, 1);
    });

    test(
      'falls back to the checklist when a question target is unavailable',
      () {
        final fixture = _focusTargetFixture(
          requirement: const SurveyEvidenceRequirement(
            id: 'missing-question-photo',
            kind: SurveyEvidenceKind.image,
            scope: SurveyEvidenceScope.question,
            questionId: 'removed-question',
            label: 'Removed question photo',
          ),
        );
        final status = fixture.statusById('missing-question-photo');

        final target = SurveyResponseEvidenceFocusTarget.resolve(
          sectionFlow: fixture.sectionFlow,
          status: status,
        );
        final focused = target.applyTo(
          const SurveyResponseFocusState(selectedPageIndex: 1),
        );

        expect(target.pageIndex, isNull);
        expect(target.questionId, 'removed-question');
        expect(target.locationSuffix, ' - check evidence checklist');
        expect(focused.selectedPageIndex, 1);
        expect(focused.focusedQuestionId, isNull);
        expect(focused.focusedRequirementId, 'missing-question-photo');
      },
    );
  });
}

_FocusTargetFixture _focusTargetFixture({
  required SurveyEvidenceRequirement requirement,
}) {
  final survey = Survey(
    id: 'evidence-focus-target-survey',
    title: 'Evidence Focus Target Survey',
    description: 'Evidence focus behavior',
    createdAt: DateTime(2026),
    sections: const [
      SurveySection(id: 'visit', title: 'Visit', order: 0),
      SurveySection(id: 'stock', title: 'Stock', order: 1),
    ],
    evidenceRequirements: [requirement],
    questions: [
      Question(
        id: 'store-name',
        text: 'Store name',
        type: QuestionType.singleLineText,
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
            id: 'evidence-focus-target-response',
            surveyId: survey.id,
            respondentId: 'participant',
            respondentName: 'Participant',
            startedAt: DateTime(2026),
          )
          .upsertAnswer(questionId: 'store-name', value: 'Kaysir Mart')
          .upsertAnswer(questionId: 'stock-note', value: 'Shelf looks full');

  return _FocusTargetFixture(
    sectionFlow: SurveyResponseSectionFlow(survey: survey, response: response),
    evidenceSummary: SurveyResponseEvidenceSummary.evaluate(
      survey: survey,
      response: response,
    ),
  );
}

/// Holds flow and evidence summary objects for evidence focus target tests.
class _FocusTargetFixture {
  final SurveyResponseSectionFlow sectionFlow;
  final SurveyResponseEvidenceSummary evidenceSummary;

  const _FocusTargetFixture({
    required this.sectionFlow,
    required this.evidenceSummary,
  });

  SurveyEvidenceRequirementStatus statusById(String requirementId) {
    return evidenceSummary.requirementStatuses.firstWhere(
      (status) => status.requirement.id == requirementId,
    );
  }
}
