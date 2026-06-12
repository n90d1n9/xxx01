import 'package:ky_survey/analytics/survey_fieldwork_insights.dart';
import 'package:ky_survey/analytics/survey_insights.dart';
import 'package:ky_survey/analytics/survey_logic_insights.dart';
import 'package:ky_survey/analytics/survey_response_insights.dart';
import 'package:ky_survey/analytics/survey_response_quality_insights.dart';
import 'package:ky_survey/analytics/survey_response_review_insights.dart';
import 'package:ky_survey/analytics/survey_structure_insights.dart';
import 'package:ky_survey/models/option.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/question_visibility_rule.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_assignment.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_response_quality.dart';
import 'package:ky_survey/models/survey_response_review.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:ky_survey/models/survey_status.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyInsights', () {
    test('aggregates role dashboard metrics', () {
      final surveys = [
        Survey(
          id: 's1',
          title: 'Customer Pulse',
          description: 'Monthly feedback',
          createdAt: DateTime(2026),
          status: SurveyStatus.collecting,
          responseCount: 75,
          targetResponses: 100,
          questions: [
            Question(
              id: 'q1',
              text: 'Rate us',
              type: QuestionType.rating,
              required: true,
            ),
          ],
        ),
        Survey(
          id: 's2',
          title: 'Draft Audit',
          description: 'Internal review',
          createdAt: DateTime(2026),
          responseCount: 0,
          targetResponses: 50,
          questions: [
            Question(
              id: 'q2',
              text: 'Notes',
              type: QuestionType.multiLineText,
              required: false,
            ),
          ],
        ),
      ];

      final insights = SurveyInsights(surveys);

      expect(insights.totalSurveys, 2);
      expect(insights.liveSurveys, 1);
      expect(insights.draftSurveys, 1);
      expect(insights.totalQuestions, 2);
      expect(insights.requiredQuestions, 1);
      expect(insights.totalResponses, 75);
      expect(insights.responseProgress, closeTo(0.5, 0.001));
      expect(insights.questionTypeCounts[QuestionType.rating], 1);
    });
  });

  group('SurveyFieldworkInsights', () {
    final survey = Survey(
      id: 'field-1',
      title: 'Outlet Visit',
      description: 'Field survey',
      createdAt: DateTime(2026),
      status: SurveyStatus.collecting,
      targetResponses: 17,
      questions: const [],
    );
    final now = DateTime(2026, 1, 10, 12);
    final assignments = [
      _assignment(
        id: 'blocked',
        surveyId: survey.id,
        assigneeId: 'raka',
        status: SurveyAssignmentStatus.blocked,
        targetResponses: 4,
        completedResponses: 1,
        dueAt: DateTime(2026, 1, 8),
      ),
      _assignment(
        id: 'active',
        surveyId: survey.id,
        assigneeId: 'ari',
        status: SurveyAssignmentStatus.inProgress,
        targetResponses: 6,
        completedResponses: 3,
        dueAt: DateTime(2026, 1, 9),
      ),
      _assignment(
        id: 'review',
        surveyId: survey.id,
        assigneeId: 'nadia',
        status: SurveyAssignmentStatus.needsReview,
        targetResponses: 2,
        completedResponses: 2,
        dueAt: DateTime(2026, 1, 11),
      ),
      _assignment(
        id: 'done',
        surveyId: survey.id,
        assigneeId: 'dimas',
        status: SurveyAssignmentStatus.completed,
        targetResponses: 5,
        completedResponses: 5,
        dueAt: DateTime(2026, 1, 4),
      ),
    ];

    test('aggregates fieldwork workload and survey summaries', () {
      final insights = SurveyFieldworkInsights(
        surveys: [survey],
        assignments: assignments,
      );
      final summary = insights.summaryForSurvey(survey, now: now);

      expect(insights.totalAssignments, 4);
      expect(insights.activeAssignments, 3);
      expect(insights.completedAssignments, 1);
      expect(insights.overdueAssignments(now: now), 2);
      expect(insights.targetResponses, 17);
      expect(insights.completedResponses, 11);
      expect(insights.completionRate, closeTo(11 / 17, 0.001));
      expect(insights.assignmentsForAssignee('ari'), hasLength(1));
      expect(summary.assignmentCount, 4);
      expect(summary.activeAssignments, 3);
      expect(summary.overdueAssignments, 2);
      expect(summary.completionRate, closeTo(11 / 17, 0.001));
    });

    test('prioritizes blocked and active work before completed items', () {
      final insights = SurveyFieldworkInsights(
        surveys: [survey],
        assignments: assignments,
      );
      final queue = insights.nextAssignments(limit: assignments.length);

      expect(queue.first.status, SurveyAssignmentStatus.blocked);
      expect(queue.last.status, SurveyAssignmentStatus.completed);
      expect(queue.map((assignment) => assignment.id), [
        'blocked',
        'active',
        'review',
        'done',
      ]);
    });
  });

  group('SurveyStructureInsights', () {
    test('summarizes sectioned and unsectioned questions', () {
      final survey = Survey(
        id: 'structure',
        title: 'Structure Survey',
        description: 'Structure analytics',
        createdAt: DateTime(2026),
        sections: const [
          SurveySection(id: 's1', title: 'First', order: 0),
          SurveySection(id: 's2', title: 'Second', order: 1),
        ],
        questions: [
          Question(
            id: 'q1',
            text: 'Required',
            type: QuestionType.singleLineText,
            required: true,
            sectionId: 's1',
          ),
          Question(
            id: 'q2',
            text: 'Optional',
            type: QuestionType.multiLineText,
            required: false,
          ),
        ],
      );

      final insights = SurveyStructureInsights([survey]);
      final summaries = insights.summariesForSurvey(survey);

      expect(insights.totalSections, 2);
      expect(insights.sectionedSurveyCount, 1);
      expect(insights.unsectionedQuestionCount, 1);
      expect(summaries.map((summary) => summary.section.id), [
        's1',
        's2',
        'unsectioned',
      ]);
      expect(summaries.first.requiredQuestionCount, 1);
      expect(summaries.last.questionCount, 1);
    });
  });

  group('SurveyLogicInsights', () {
    test('summarizes branching depth, issues, and section complexity', () {
      final survey = Survey(
        id: 'logic-map',
        title: 'Logic Map',
        description: 'Branching survey',
        createdAt: DateTime(2026),
        sections: const [
          SurveySection(id: 'profile', title: 'Profile', order: 0),
          SurveySection(id: 'risk', title: 'Risk', order: 1),
        ],
        questions: [
          Question(
            id: 'q1',
            text: 'Eligible?',
            type: QuestionType.singleChoice,
            required: true,
            sectionId: 'profile',
            options: [
              Option(id: 'yes', text: 'Yes'),
              Option(id: 'no', text: 'No'),
            ],
          ),
          Question(
            id: 'q2',
            text: 'Age',
            type: QuestionType.number,
            required: true,
            sectionId: 'profile',
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
            text: 'Risk reason',
            type: QuestionType.singleLineText,
            required: false,
            sectionId: 'risk',
            visibilityRules: const [
              QuestionVisibilityRule(
                sourceQuestionId: 'q2',
                operator: QuestionVisibilityOperator.greaterThanOrEqual,
                value: 18,
              ),
            ],
          ),
          Question(
            id: 'q4',
            text: 'Invalid option branch',
            type: QuestionType.singleLineText,
            required: false,
            sectionId: 'risk',
            visibilityRules: const [
              QuestionVisibilityRule(
                sourceQuestionId: 'q1',
                operator: QuestionVisibilityOperator.equals,
                value: 'maybe',
              ),
            ],
          ),
          Question(
            id: 'q5',
            text: 'Missing source branch',
            type: QuestionType.singleLineText,
            required: false,
            visibilityRules: const [
              QuestionVisibilityRule(sourceQuestionId: 'missing'),
            ],
          ),
          Question(
            id: 'q6',
            text: 'Forward branch',
            type: QuestionType.singleLineText,
            required: false,
            visibilityRules: const [
              QuestionVisibilityRule(sourceQuestionId: 'q7'),
            ],
          ),
          Question(
            id: 'q7',
            text: 'Later source',
            type: QuestionType.singleLineText,
            required: false,
          ),
        ],
      );

      final insights = SurveyLogicInsights(survey);

      expect(insights.rootQuestionCount, 2);
      expect(insights.conditionalQuestionCount, 5);
      expect(insights.totalVisibilityRules, 5);
      expect(insights.maxDependencyDepth, 2);
      expect(
        insights.dependentQuestionIds('q1'),
        containsAll(['q2', 'q3', 'q4']),
      );
      expect(
        insights.issues.map((issue) => issue.type),
        containsAll([
          SurveyLogicIssueType.optionValueMismatch,
          SurveyLogicIssueType.missingSource,
          SurveyLogicIssueType.forwardDependency,
        ]),
      );

      final riskSummary = insights.sectionSummaries.firstWhere(
        (summary) => summary.id == 'risk',
      );
      final generalSummary = insights.sectionSummaries.firstWhere(
        (summary) => summary.id == 'general',
      );

      expect(riskSummary.questionCount, 2);
      expect(riskSummary.conditionalQuestionCount, 2);
      expect(riskSummary.maxDependencyDepth, 2);
      expect(riskSummary.issueCount, 1);
      expect(generalSummary.issueCount, 2);
    });

    test('reports every question in a dependency cycle', () {
      final survey = Survey(
        id: 'cycle-map',
        title: 'Cycle Map',
        description: 'Imported invalid logic',
        createdAt: DateTime(2026),
        questions: [
          Question(
            id: 'q1',
            text: 'First',
            type: QuestionType.singleLineText,
            required: false,
            visibilityRules: const [
              QuestionVisibilityRule(sourceQuestionId: 'q2'),
            ],
          ),
          Question(
            id: 'q2',
            text: 'Second',
            type: QuestionType.singleLineText,
            required: false,
            visibilityRules: const [
              QuestionVisibilityRule(sourceQuestionId: 'q1'),
            ],
          ),
        ],
      );

      final cycleIssues = SurveyLogicInsights(
        survey,
      ).issues.where((issue) => issue.type == SurveyLogicIssueType.cycle);

      expect(
        cycleIssues.map((issue) => issue.question.id),
        containsAll(['q1', 'q2']),
      );
    });
  });

  group('SurveyResponseQualityInsights', () {
    test('flags invalid, hidden, and unusually fast responses', () {
      final survey = Survey(
        id: 'quality-survey',
        title: 'Quality Survey',
        description: 'Quality review',
        createdAt: DateTime(2026),
        questions: [
          Question(
            id: 'q1',
            text: 'Need follow up?',
            type: QuestionType.singleChoice,
            required: true,
            options: [
              Option(id: 'yes', text: 'Yes'),
              Option(id: 'no', text: 'No'),
            ],
          ),
          Question(
            id: 'q2',
            text: 'Follow up notes',
            type: QuestionType.multiLineText,
            required: false,
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
      final hiddenAnswerResponse =
          SurveyResponse(
                id: 'hidden',
                surveyId: 'quality-survey',
                respondentId: 'u1',
                respondentName: 'Hidden Answer',
                startedAt: DateTime(2026, 1, 1, 10),
              )
              .upsertAnswer(questionId: 'q1', value: 'no')
              .upsertAnswer(questionId: 'q2', value: 'Should be hidden')
              .submit(submittedAt: DateTime(2026, 1, 1, 10, 2));
      final invalidFastResponse =
          SurveyResponse(
                id: 'invalid-fast',
                surveyId: 'quality-survey',
                respondentId: 'u2',
                respondentName: 'Invalid Fast',
                startedAt: DateTime(2026, 1, 1, 11),
              )
              .upsertAnswer(questionId: 'q1', value: 'bad')
              .submit(submittedAt: DateTime(2026, 1, 1, 11, 0, 5));

      final insights = SurveyResponseQualityInsights(
        surveys: [survey],
        responses: [hiddenAnswerResponse, invalidFastResponse],
      );
      final signals = insights.signals();

      expect(
        signals.map((signal) => signal.type),
        containsAll([
          SurveyResponseQualitySignalType.hiddenAnswer,
          SurveyResponseQualitySignalType.validationIssue,
          SurveyResponseQualitySignalType.tooFast,
        ]),
      );
      expect(insights.flaggedResponseCount(), 2);
      expect(insights.criticalSignalCount(), 1);
      expect(insights.cleanSubmittedResponseCount(), 0);
      expect(
        insights.reviewQueue().first.severity,
        SurveyResponseQualitySeverity.critical,
      );
      expect(insights.summaryForSurvey(survey).signalCount, 3);
    });
  });

  group('SurveyResponseReviewInsights', () {
    test('summarizes review progress and prioritizes review queue', () {
      final survey = Survey(
        id: 'review-survey',
        title: 'Review Survey',
        description: 'Review workflow',
        createdAt: DateTime(2026),
        questions: [
          Question(
            id: 'q1',
            text: 'Pick one',
            type: QuestionType.singleChoice,
            required: true,
            options: [
              Option(id: 'yes', text: 'Yes'),
              Option(id: 'no', text: 'No'),
            ],
          ),
        ],
      );
      final approved =
          SurveyResponse(
                id: 'approved',
                surveyId: 'review-survey',
                respondentId: 'u1',
                respondentName: 'Approved',
                startedAt: DateTime(2026, 1, 1, 10),
              )
              .upsertAnswer(questionId: 'q1', value: 'yes')
              .submit(submittedAt: DateTime(2026, 1, 1, 10, 4))
              .review(
                status: SurveyResponseReviewStatus.approved,
                reviewerName: 'Lead',
                reviewedAt: DateTime(2026, 1, 1, 12),
              );
      final pendingInvalid =
          SurveyResponse(
                id: 'pending-invalid',
                surveyId: 'review-survey',
                respondentId: 'u2',
                respondentName: 'Pending Invalid',
                startedAt: DateTime(2026, 1, 1, 11),
              )
              .upsertAnswer(questionId: 'q1', value: 'bad')
              .submit(submittedAt: DateTime(2026, 1, 1, 11, 4));
      final followUp =
          SurveyResponse(
                id: 'follow-up',
                surveyId: 'review-survey',
                respondentId: 'u3',
                respondentName: 'Follow Up',
                startedAt: DateTime(2026, 1, 1, 12),
              )
              .upsertAnswer(questionId: 'q1', value: 'yes')
              .submit(submittedAt: DateTime(2026, 1, 1, 12, 4))
              .review(
                status: SurveyResponseReviewStatus.needsFollowUp,
                reviewerName: 'Lead',
              );
      final qualityInsights = SurveyResponseQualityInsights(
        surveys: [survey],
        responses: [approved, pendingInvalid, followUp],
      );
      final reviewInsights = SurveyResponseReviewInsights(
        surveys: [survey],
        responses: [approved, pendingInvalid, followUp],
        qualityInsights: qualityInsights,
      );
      final queue = reviewInsights.reviewQueue();
      final summary = reviewInsights.summaryForSurvey(survey);

      expect(reviewInsights.pendingReviewCount, 1);
      expect(reviewInsights.approvedCount, 1);
      expect(reviewInsights.needsFollowUpCount, 1);
      expect(reviewInsights.reviewProgress, closeTo(1 / 3, 0.001));
      expect(queue.map((item) => item.response.id), [
        'follow-up',
        'pending-invalid',
      ]);
      expect(queue.last.hasCriticalSignal, isTrue);
      expect(summary.pendingReview, 1);
      expect(summary.approved, 1);
      expect(summary.needsFollowUp, 1);
    });
  });

  group('SurveyResponseInsights', () {
    test('summarizes submitted responses and ignores draft analytics', () {
      final survey = Survey(
        id: 's1',
        title: 'Outlet Audit',
        description: 'Field audit',
        createdAt: DateTime(2026),
        questions: [
          Question(
            id: 'q1',
            text: 'Was the product visible?',
            type: QuestionType.singleChoice,
            required: true,
            options: [
              Option(id: 'yes', text: 'Yes'),
              Option(id: 'no', text: 'No'),
            ],
          ),
          Question(
            id: 'q2',
            text: 'Display quality',
            type: QuestionType.rating,
            required: true,
          ),
        ],
      );
      final submittedOne =
          SurveyResponse(
                id: 'r1',
                surveyId: 's1',
                respondentId: 'u1',
                respondentName: 'Ari',
                startedAt: DateTime(2026),
              )
              .upsertAnswer(questionId: 'q1', value: 'yes')
              .upsertAnswer(questionId: 'q2', value: 4)
              .submit();
      final submittedTwo =
          SurveyResponse(
                id: 'r2',
                surveyId: 's1',
                respondentId: 'u2',
                respondentName: 'Nadia',
                startedAt: DateTime(2026),
              )
              .upsertAnswer(questionId: 'q1', value: 'no')
              .upsertAnswer(questionId: 'q2', value: 2)
              .submit();
      final draft = SurveyResponse(
        id: 'r3',
        surveyId: 's1',
        respondentId: 'u3',
        respondentName: 'Draft',
        startedAt: DateTime(2026),
      ).upsertAnswer(questionId: 'q1', value: 'yes');

      final insights = SurveyResponseInsights(
        surveys: [survey],
        responses: [submittedOne, submittedTwo, draft],
      );
      final summary = insights.summaryForSurvey(survey);
      final breakdowns = insights.questionBreakdowns(survey);

      expect(insights.submittedResponseCount, 2);
      expect(insights.draftResponseCount, 1);
      expect(summary.submittedResponses, 2);
      expect(summary.draftResponses, 1);
      expect(summary.averageCompletion, 1);
      expect(breakdowns[0].optionCounts, {'Yes': 1, 'No': 1});
      expect(breakdowns[1].averageRating, 3);
    });

    test('uses visibility rules for completion and missing counts', () {
      final survey = Survey(
        id: 'logic-survey',
        title: 'Branching Survey',
        description: 'Conditional analytics',
        createdAt: DateTime(2026),
        questions: [
          Question(
            id: 'q1',
            text: 'Need follow up?',
            type: QuestionType.singleChoice,
            required: true,
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
      final hiddenFollowUp = SurveyResponse(
        id: 'r1',
        surveyId: 'logic-survey',
        respondentId: 'u1',
        respondentName: 'No Follow Up',
        startedAt: DateTime(2026),
      ).upsertAnswer(questionId: 'q1', value: 'no').submit();
      final visibleFollowUpMissing = SurveyResponse(
        id: 'r2',
        surveyId: 'logic-survey',
        respondentId: 'u2',
        respondentName: 'Needs Follow Up',
        startedAt: DateTime(2026),
      ).upsertAnswer(questionId: 'q1', value: 'yes').submit();

      final insights = SurveyResponseInsights(
        surveys: [survey],
        responses: [hiddenFollowUp, visibleFollowUpMissing],
      );
      final summary = insights.summaryForSurvey(survey);
      final followUpBreakdown = insights.questionBreakdowns(survey)[1];

      expect(summary.averageCompletion, 0.75);
      expect(followUpBreakdown.missingRequiredCount, 1);
    });
  });
}

SurveyAssignment _assignment({
  required String id,
  required String surveyId,
  required String assigneeId,
  required SurveyAssignmentStatus status,
  required int targetResponses,
  required int completedResponses,
  required DateTime dueAt,
}) {
  return SurveyAssignment(
    id: id,
    surveyId: surveyId,
    assigneeId: assigneeId,
    assigneeName: assigneeId,
    territory: 'Jakarta',
    status: status,
    targetResponses: targetResponses,
    completedResponses: completedResponses,
    dueAt: dueAt,
    assignedAt: DateTime(2026, 1),
  );
}
