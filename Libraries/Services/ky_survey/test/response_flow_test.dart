import 'package:ky_survey/logic/question_visibility_evaluator.dart';
import 'package:ky_survey/logic/survey_preview_session.dart';
import 'package:ky_survey/logic/survey_response_answer_sanitizer.dart';
import 'package:ky_survey/logic/survey_response_draft_selector.dart';
import 'package:ky_survey/logic/survey_response_section_flow.dart';
import 'package:ky_survey/logic/survey_response_session_summary.dart';
import 'package:ky_survey/models/option.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/question_visibility_rule.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:ky_survey/validation/survey_response_validator.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyResponseSectionFlow', () {
    test('groups visible questions by section and unsectioned page', () {
      final survey = Survey(
        id: 'flow-survey',
        title: 'Flow Survey',
        description: 'Sectioned runtime',
        createdAt: DateTime(2026),
        sections: const [
          SurveySection(id: 'context', title: 'Context', order: 0),
          SurveySection(id: 'follow-up', title: 'Follow-up', order: 1),
        ],
        questions: [
          Question(
            id: 'q1',
            text: 'Need follow up?',
            type: QuestionType.singleChoice,
            required: true,
            sectionId: 'context',
            options: [
              Option(id: 'yes', text: 'Yes'),
              Option(id: 'no', text: 'No'),
            ],
          ),
          Question(
            id: 'q2',
            text: 'Explain the issue',
            type: QuestionType.multiLineText,
            required: true,
            sectionId: 'follow-up',
            visibilityRules: const [
              QuestionVisibilityRule(
                sourceQuestionId: 'q1',
                operator: QuestionVisibilityOperator.equals,
                value: 'yes',
              ),
            ],
          ),
          Question(
            id: 'q3',
            text: 'General note',
            type: QuestionType.singleLineText,
            required: false,
          ),
        ],
      );
      final response = SurveyResponse(
        id: 'r1',
        surveyId: 'flow-survey',
        respondentId: 'u1',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
      ).upsertAnswer(questionId: 'q1', value: 'no');

      final flow = SurveyResponseSectionFlow(
        survey: survey,
        response: response,
      );
      final pages = flow.pages;

      expect(flow.visibleQuestionCount, 2);
      expect(flow.answeredQuestionCount, 1);
      expect(pages.map((page) => page.title), ['Context', 'General']);
      expect(pages.first.questions.single.id, 'q1');
      expect(pages.last.questions.single.id, 'q3');
      expect(pages.last.questionNumberAt(0), 2);
      expect(flow.pageIndexForQuestion('q1'), 0);
      expect(flow.pageIndexForQuestion('q3'), 1);
      expect(flow.pageIndexForQuestion('q2'), isNull);
      expect(flow.pageIndexForQuestion('missing'), isNull);
      expect(flow.completionRate, 0.5);
    });

    test('reveals conditional section pages when answers match', () {
      final survey = Survey(
        id: 'flow-survey',
        title: 'Flow Survey',
        description: 'Sectioned runtime',
        createdAt: DateTime(2026),
        sections: const [
          SurveySection(id: 'context', title: 'Context', order: 0),
          SurveySection(id: 'follow-up', title: 'Follow-up', order: 1),
        ],
        questions: [
          Question(
            id: 'q1',
            text: 'Need follow up?',
            type: QuestionType.singleChoice,
            required: true,
            sectionId: 'context',
            options: [
              Option(id: 'yes', text: 'Yes'),
              Option(id: 'no', text: 'No'),
            ],
          ),
          Question(
            id: 'q2',
            text: 'Explain the issue',
            type: QuestionType.multiLineText,
            required: true,
            sectionId: 'follow-up',
            visibilityRules: const [
              QuestionVisibilityRule(
                sourceQuestionId: 'q1',
                operator: QuestionVisibilityOperator.equals,
                value: 'yes',
              ),
            ],
          ),
        ],
      );
      final response = SurveyResponse(
        id: 'r2',
        surveyId: 'flow-survey',
        respondentId: 'u2',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
      ).upsertAnswer(questionId: 'q1', value: 'yes');

      final pages = SurveyResponseSectionFlow(
        survey: survey,
        response: response,
      ).pages;

      expect(pages.map((page) => page.title), ['Context', 'Follow-up']);
      expect(pages.last.unansweredRequiredQuestions.single.id, 'q2');
      expect(pages.last.questionNumberAt(0), 2);
    });

    test('locates validation issues on their response section page', () {
      final survey = Survey(
        id: 'issue-flow',
        title: 'Issue Flow',
        description: 'Section issue routing',
        createdAt: DateTime(2026),
        sections: const [
          SurveySection(id: 'identity', title: 'Identity', order: 0),
          SurveySection(id: 'metrics', title: 'Metrics', order: 1),
        ],
        questions: [
          Question(
            id: 'name',
            text: 'Store name',
            type: QuestionType.singleLineText,
            required: true,
            sectionId: 'identity',
          ),
          Question(
            id: 'visitors',
            text: 'Visitor count',
            type: QuestionType.number,
            required: true,
            sectionId: 'metrics',
          ),
          Question(
            id: 'note',
            text: 'General note',
            type: QuestionType.singleLineText,
            required: true,
          ),
        ],
      );
      final response =
          SurveyResponse(
                id: 'issue-response',
                surveyId: survey.id,
                respondentId: 'u1',
                respondentName: 'Participant',
                startedAt: DateTime(2026),
              )
              .upsertAnswer(questionId: 'name', value: 'Kaysir Mart')
              .upsertAnswer(questionId: 'visitors', value: 'many');

      final validation = SurveyResponseValidator.validate(
        questions: survey.questions,
        response: response,
      );
      final flow = SurveyResponseSectionFlow(
        survey: survey,
        response: response,
      );
      final statuses = flow.pageStatuses(validation);

      expect(statuses.map((status) => status.page.title), [
        'Identity',
        'Metrics',
        'General',
      ]);
      expect(statuses.map((status) => status.issueCount), [0, 1, 1]);
      expect(statuses.map((status) => status.invalidIssueCount), [0, 1, 0]);
      expect(statuses.map((status) => status.requiredIssueCount), [0, 0, 1]);
      expect(statuses.map((status) => status.answerProgressLabel), [
        '1 of 1 answered',
        '1 of 1 answered',
        '0 of 1 answered',
      ]);
      expect(statuses.map((status) => status.statusLabel), [
        'Section ready',
        '1 answer issue',
        '1 answer issue',
      ]);
      expect(statuses.map((status) => status.detailLabel), [
        'Required answers complete',
        '1 invalid answer',
        '1 required missing',
      ]);
      expect(statuses.first.isComplete, isTrue);
      expect(statuses.skip(1).every((status) => status.hasIssues), isTrue);
      expect(flow.firstIssuePageIndex(validation), 1);
    });
  });

  group('SurveyPreviewSession', () {
    final survey = Survey(
      id: 'preview-survey',
      title: 'Preview Survey',
      description: 'Builder preview',
      createdAt: DateTime(2026),
      sections: const [
        SurveySection(id: 'intro', title: 'Intro', order: 0),
        SurveySection(id: 'follow-up', title: 'Follow-up', order: 1),
      ],
      questions: [
        Question(
          id: 'q1',
          text: 'Need follow up?',
          type: QuestionType.singleChoice,
          required: true,
          sectionId: 'intro',
          options: [
            Option(id: 'yes', text: 'Yes'),
            Option(id: 'no', text: 'No'),
          ],
        ),
        Question(
          id: 'q2',
          text: 'Explain',
          type: QuestionType.multiLineText,
          required: true,
          sectionId: 'follow-up',
          visibilityRules: const [
            QuestionVisibilityRule(
              sourceQuestionId: 'q1',
              operator: QuestionVisibilityOperator.equals,
              value: 'yes',
            ),
          ],
        ),
      ],
    );

    test('creates a deterministic local response session', () {
      final session = SurveyPreviewSession.initial(
        survey,
        startedAt: DateTime(2026, 1, 1, 9),
      );

      expect(session.response.id, 'preview-preview-survey');
      expect(session.response.surveyId, survey.id);
      expect(session.response.respondentId, 'preview-participant');
      expect(session.response.metadata['source'], 'builderPreview');
      expect(session.sectionFlow.pages.map((page) => page.title), ['Intro']);
      expect(
        session.summary(now: DateTime(2026, 1, 1, 9, 1)).canSubmit,
        isFalse,
      );
    });

    test('updates answers and applies conditional visibility cleanup', () {
      final session = SurveyPreviewSession.initial(
        survey,
        startedAt: DateTime(2026),
      );

      final withFollowUp = session
          .updateAnswer(questionId: 'q1', value: 'yes')
          .updateAnswer(questionId: 'q2', value: 'Needs repair');
      final withoutFollowUp = withFollowUp.updateAnswer(
        questionId: 'q1',
        value: 'no',
      );

      expect(withFollowUp.sectionFlow.pages.map((page) => page.title), [
        'Intro',
        'Follow-up',
      ]);
      expect(withFollowUp.summary(now: DateTime(2026)).canSubmit, isTrue);
      expect(withoutFollowUp.response.valueFor('q2'), isNull);
      expect(withoutFollowUp.sectionFlow.pages.map((page) => page.title), [
        'Intro',
      ]);
      expect(withoutFollowUp.summary(now: DateTime(2026)).canSubmit, isTrue);
    });

    test('syncs preview answers when the survey structure changes', () {
      final session =
          SurveyPreviewSession.initial(survey, startedAt: DateTime(2026))
              .updateAnswer(questionId: 'q1', value: 'yes')
              .updateAnswer(questionId: 'q2', value: 'Needs repair');
      final updatedSurvey = survey.copyWith(
        questions: [
          survey.questions.first.copyWith(
            options: [Option(id: 'no', text: 'No')],
          ),
        ],
      );

      final synced = session.forSurvey(updatedSurvey);

      expect(synced.survey.questions, hasLength(1));
      expect(synced.response.valueFor('q1'), 'yes');
      expect(synced.response.valueFor('q2'), isNull);
      expect(synced.sectionFlow.visibleQuestionCount, 1);
    });
  });

  group('SurveyResponseDraftSelector', () {
    test('returns the latest active draft for the same respondent', () {
      final olderDraft =
          SurveyResponse(
            id: 'older',
            surveyId: 'survey-1',
            respondentId: 'respondent-1',
            respondentName: 'Participant',
            startedAt: DateTime(2026, 1, 1, 9),
          ).upsertAnswer(
            questionId: 'q1',
            value: 'Older',
            answeredAt: DateTime(2026, 1, 1, 9, 5),
          );
      final newerDraft =
          SurveyResponse(
            id: 'newer',
            surveyId: 'survey-1',
            respondentId: 'respondent-1',
            respondentName: 'Participant',
            startedAt: DateTime(2026, 1, 1, 10),
          ).upsertAnswer(
            questionId: 'q1',
            value: 'Newer',
            answeredAt: DateTime(2026, 1, 1, 10, 2),
          );
      final submitted = SurveyResponse(
        id: 'submitted',
        surveyId: 'survey-1',
        respondentId: 'respondent-1',
        respondentName: 'Participant',
        startedAt: DateTime(2026, 1, 1, 11),
      ).submit(submittedAt: DateTime(2026, 1, 1, 11, 1));

      final selected = SurveyResponseDraftSelector.activeDraftFor(
        responses: [olderDraft, submitted, newerDraft],
        surveyId: 'survey-1',
        respondentId: 'respondent-1',
      );

      expect(selected?.id, 'newer');
      expect(
        SurveyResponseDraftSelector.lastActivityAt(olderDraft),
        DateTime(2026, 1, 1, 9, 5),
      );
    });

    test('keeps collector and respondent draft sessions isolated', () {
      final collectorDraft = SurveyResponse(
        id: 'collector-draft',
        surveyId: 'survey-1',
        respondentId: 'respondent-1',
        respondentName: 'Participant',
        collectorId: 'collector-1',
        collectorName: 'Collector',
        startedAt: DateTime(2026, 1, 1, 9),
      );
      final anonymousDraft = SurveyResponse(
        id: 'anonymous-draft',
        surveyId: 'survey-1',
        respondentId: 'anonymous',
        respondentName: 'Participant',
        startedAt: DateTime(2026, 1, 1, 10),
      );

      final noCollector = SurveyResponseDraftSelector.activeDraftFor(
        responses: [collectorDraft, anonymousDraft],
        surveyId: 'survey-1',
        respondentId: 'respondent-1',
      );
      final withCollector = SurveyResponseDraftSelector.activeDraftFor(
        responses: [collectorDraft, anonymousDraft],
        surveyId: 'survey-1',
        respondentId: 'respondent-1',
        collectorId: 'collector-1',
      );

      expect(noCollector, isNull);
      expect(withCollector?.id, 'collector-draft');
    });

    test('ignores discarded drafts when resuming a response session', () {
      final discarded = SurveyResponse(
        id: 'discarded',
        surveyId: 'survey-1',
        respondentId: 'respondent-1',
        respondentName: 'Participant',
        startedAt: DateTime(2026, 1, 1, 9),
        status: SurveyResponseStatus.discarded,
      );

      final selected = SurveyResponseDraftSelector.activeDraftFor(
        responses: [discarded],
        surveyId: 'survey-1',
        respondentId: 'respondent-1',
      );

      expect(selected, isNull);
    });

    test('keeps drafts isolated by survey version', () {
      final versionOneDraft = SurveyResponse(
        id: 'v1-draft',
        surveyId: 'survey-1',
        surveyVersionId: 'survey-1-v1',
        respondentId: 'respondent-1',
        respondentName: 'Participant',
        startedAt: DateTime(2026, 1, 1, 9),
      );
      final versionTwoDraft = SurveyResponse(
        id: 'v2-draft',
        surveyId: 'survey-1',
        surveyVersionId: 'survey-1-v2',
        respondentId: 'respondent-1',
        respondentName: 'Participant',
        startedAt: DateTime(2026, 1, 1, 10),
      );

      final selected = SurveyResponseDraftSelector.activeDraftFor(
        responses: [versionTwoDraft, versionOneDraft],
        surveyId: 'survey-1',
        respondentId: 'respondent-1',
        surveyVersionId: 'survey-1-v1',
      );

      expect(selected?.id, 'v1-draft');
    });
  });

  group('SurveyResponseSessionSummary', () {
    final survey = Survey(
      id: 'session-survey',
      title: 'Session Survey',
      description: 'Runtime summary',
      createdAt: DateTime(2026),
      questions: [
        Question(
          id: 'name',
          text: 'Store name',
          type: QuestionType.singleLineText,
          required: true,
        ),
        Question(
          id: 'visitors',
          text: 'Visitor count',
          type: QuestionType.number,
          required: true,
        ),
        Question(
          id: 'notes',
          text: 'Notes',
          type: QuestionType.multiLineText,
          required: false,
        ),
      ],
    );

    test('summarizes missing required answers before submission', () {
      final response = SurveyResponse(
        id: 'session-1',
        surveyId: survey.id,
        respondentId: 'u1',
        respondentName: 'Participant',
        startedAt: DateTime(2026, 1, 1, 10),
      );

      final summary = SurveyResponseSessionSummary.evaluate(
        survey: survey,
        response: response,
        now: DateTime(2026, 1, 1, 10, 3),
      );

      expect(summary.canSubmit, isFalse);
      expect(summary.visibleQuestionCount, 3);
      expect(summary.answeredQuestionCount, 0);
      expect(summary.missingRequiredCount, 2);
      expect(summary.invalidIssueCount, 0);
      expect(summary.primaryStatusLabel, '2 required missing');
      expect(summary.secondaryStatusLabel, 'No answers yet • 3m session');
      expect(summary.requiredProgressLabel, '0 of 2 required answered');
    });

    test(
      'highlights invalid answered values separately from missing answers',
      () {
        final response =
            SurveyResponse(
                  id: 'session-2',
                  surveyId: survey.id,
                  respondentId: 'u2',
                  respondentName: 'Participant',
                  startedAt: DateTime(2026, 1, 1, 10),
                )
                .upsertAnswer(
                  questionId: 'name',
                  value: 'Kaysir Mart',
                  answeredAt: DateTime(2026, 1, 1, 10, 1),
                )
                .upsertAnswer(
                  questionId: 'visitors',
                  value: 'many',
                  answeredAt: DateTime(2026, 1, 1, 10, 2),
                );

        final summary = SurveyResponseSessionSummary.evaluate(
          survey: survey,
          response: response,
          now: DateTime(2026, 1, 1, 10, 5),
        );

        expect(summary.canSubmit, isFalse);
        expect(summary.answeredQuestionCount, 2);
        expect(summary.missingRequiredCount, 0);
        expect(summary.invalidIssueCount, 1);
        expect(summary.primaryStatusLabel, '1 answer issue');
        expect(summary.firstIssueMessage, 'Visitor count must be a number');
        expect(summary.secondaryStatusLabel, 'Last saved 10:02 • 5m session');
        expect(summary.requiredProgressLabel, '2 of 2 required answered');
      },
    );

    test(
      'marks complete drafts as ready and submitted responses as locked',
      () {
        final completeDraft =
            SurveyResponse(
                  id: 'session-3',
                  surveyId: survey.id,
                  respondentId: 'u3',
                  respondentName: 'Participant',
                  startedAt: DateTime(2026, 1, 1, 10),
                )
                .upsertAnswer(questionId: 'name', value: 'Kaysir Mart')
                .upsertAnswer(questionId: 'visitors', value: 12);

        final draftSummary = SurveyResponseSessionSummary.evaluate(
          survey: survey,
          response: completeDraft,
          now: DateTime(2026, 1, 1, 10, 30),
        );
        final submittedSummary = SurveyResponseSessionSummary.evaluate(
          survey: survey,
          response: completeDraft.submit(
            submittedAt: DateTime(2026, 1, 1, 10, 12),
          ),
          now: DateTime(2026, 1, 1, 10, 30),
        );

        expect(draftSummary.canSubmit, isTrue);
        expect(draftSummary.completionPercent, 67);
        expect(draftSummary.primaryStatusLabel, 'Ready to submit');
        expect(submittedSummary.canSubmit, isFalse);
        expect(submittedSummary.primaryStatusLabel, 'Submitted');
        expect(submittedSummary.sessionDuration, const Duration(minutes: 12));
      },
    );
  });

  group('QuestionVisibilityEvaluator', () {
    final ratingQuestion = Question(
      id: 'rating',
      text: 'Rate your visit',
      type: QuestionType.rating,
      required: true,
      minRating: 1,
      maxRating: 5,
    );
    final followUpQuestion = Question(
      id: 'follow-up',
      text: 'What should we improve?',
      type: QuestionType.multiLineText,
      required: true,
      visibilityRules: const [
        QuestionVisibilityRule(
          sourceQuestionId: 'rating',
          operator: QuestionVisibilityOperator.lessThanOrEqual,
          value: 3,
        ),
      ],
    );

    test('hides follow-up questions when conditions do not match', () {
      final response = SurveyResponse(
        id: 'r1',
        surveyId: 's1',
        respondentId: 'u1',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
      ).upsertAnswer(questionId: 'rating', value: 5);

      final visibleQuestions = QuestionVisibilityEvaluator.visibleQuestions([
        ratingQuestion,
        followUpQuestion,
      ], response);

      expect(visibleQuestions.map((question) => question.id), ['rating']);
      expect(response.unansweredRequiredQuestions(visibleQuestions), isEmpty);
      expect(response.completionRate(visibleQuestions), 1);
    });

    test('shows required follow-ups when conditions match', () {
      final response = SurveyResponse(
        id: 'r2',
        surveyId: 's1',
        respondentId: 'u2',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
      ).upsertAnswer(questionId: 'rating', value: 2);

      final visibleQuestions = QuestionVisibilityEvaluator.visibleQuestions([
        ratingQuestion,
        followUpQuestion,
      ], response);
      final unanswered = response.unansweredRequiredQuestions(visibleQuestions);

      expect(visibleQuestions.map((question) => question.id), [
        'rating',
        'follow-up',
      ]);
      expect(unanswered.single.id, 'follow-up');
      expect(response.completionRate(visibleQuestions), 0.5);
    });
  });

  group('SurveyResponseAnswerSanitizer', () {
    final questions = [
      Question(
        id: 'has-issue',
        text: 'Has an issue?',
        type: QuestionType.singleChoice,
        required: true,
        options: [
          Option(id: 'yes', text: 'Yes'),
          Option(id: 'no', text: 'No'),
        ],
      ),
      Question(
        id: 'issue-detail',
        text: 'Issue detail',
        type: QuestionType.multiLineText,
        required: false,
        visibilityRules: const [
          QuestionVisibilityRule(
            sourceQuestionId: 'has-issue',
            operator: QuestionVisibilityOperator.equals,
            value: 'yes',
          ),
        ],
      ),
      Question(
        id: 'issue-photo',
        text: 'Issue photo note',
        type: QuestionType.singleLineText,
        required: false,
        visibilityRules: const [
          QuestionVisibilityRule(
            sourceQuestionId: 'issue-detail',
            operator: QuestionVisibilityOperator.answered,
          ),
        ],
      ),
    ];

    test('prunes stale hidden answers until cascading logic settles', () {
      final response =
          SurveyResponse(
                id: 'sanitize-1',
                surveyId: 'survey-1',
                respondentId: 'respondent-1',
                respondentName: 'Participant',
                startedAt: DateTime(2026),
              )
              .upsertAnswer(questionId: 'has-issue', value: 'yes')
              .upsertAnswer(questionId: 'issue-detail', value: 'Broken shelf')
              .upsertAnswer(questionId: 'issue-photo', value: 'Photo later')
              .upsertAnswer(questionId: 'has-issue', value: 'no');

      final sanitization = SurveyResponseAnswerSanitizer.sanitize(
        questions: questions,
        response: response,
      );

      expect(sanitization.changed, isTrue);
      expect(sanitization.removedQuestionIds, {'issue-detail', 'issue-photo'});
      expect(sanitization.response.valueFor('has-issue'), 'no');
      expect(sanitization.response.valueFor('issue-detail'), isNull);
      expect(sanitization.response.valueFor('issue-photo'), isNull);
      expect(sanitization.response.answers.map((answer) => answer.questionId), [
        'has-issue',
      ]);
    });

    test('keeps visible conditional answers and removes unknown answers', () {
      final response =
          SurveyResponse(
                id: 'sanitize-2',
                surveyId: 'survey-1',
                respondentId: 'respondent-1',
                respondentName: 'Participant',
                startedAt: DateTime(2026),
              )
              .upsertAnswer(questionId: 'has-issue', value: 'yes')
              .upsertAnswer(questionId: 'issue-detail', value: 'Broken shelf')
              .upsertAnswer(questionId: 'unknown', value: 'stale');

      final sanitization = SurveyResponseAnswerSanitizer.sanitize(
        questions: questions,
        response: response,
      );

      expect(sanitization.changed, isTrue);
      expect(sanitization.removedQuestionIds, {'unknown'});
      expect(sanitization.response.valueFor('has-issue'), 'yes');
      expect(sanitization.response.valueFor('issue-detail'), 'Broken shelf');
      expect(sanitization.response.valueFor('unknown'), isNull);
    });

    test('returns the same response when all answers remain visible', () {
      final response = SurveyResponse(
        id: 'sanitize-3',
        surveyId: 'survey-1',
        respondentId: 'respondent-1',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
      ).upsertAnswer(questionId: 'has-issue', value: 'no');

      final sanitization = SurveyResponseAnswerSanitizer.sanitize(
        questions: questions,
        response: response,
      );

      expect(sanitization.changed, isFalse);
      expect(identical(sanitization.response, response), isTrue);
    });
  });
}
