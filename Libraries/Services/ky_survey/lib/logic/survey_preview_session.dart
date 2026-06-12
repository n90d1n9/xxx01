import '../models/survey.dart';
import '../models/survey_response.dart';
import 'survey_response_answer_sanitizer.dart';
import 'survey_response_section_flow.dart';
import 'survey_response_session_summary.dart';

class SurveyPreviewSession {
  final Survey survey;
  final SurveyResponse response;

  const SurveyPreviewSession({required this.survey, required this.response});

  factory SurveyPreviewSession.initial(Survey survey, {DateTime? startedAt}) {
    return SurveyPreviewSession(
      survey: survey,
      response: SurveyResponse(
        id: 'preview-${survey.id}',
        surveyId: survey.id,
        respondentId: 'preview-participant',
        respondentName: 'Preview Participant',
        startedAt: startedAt ?? DateTime.now(),
        metadata: const {'source': 'builderPreview'},
      ),
    );
  }

  SurveyPreviewSession forSurvey(Survey updatedSurvey) {
    final syncedResponse = response.surveyId == updatedSurvey.id
        ? response
        : response.copyWith(surveyId: updatedSurvey.id);

    return SurveyPreviewSession(
      survey: updatedSurvey,
      response: SurveyResponseAnswerSanitizer.pruneHiddenAnswers(
        questions: updatedSurvey.questions,
        response: syncedResponse,
      ),
    );
  }

  SurveyPreviewSession updateAnswer({
    required String questionId,
    required dynamic value,
    DateTime? answeredAt,
  }) {
    final updatedResponse = response.upsertAnswer(
      questionId: questionId,
      value: value,
      answeredAt: answeredAt,
    );

    return SurveyPreviewSession(
      survey: survey,
      response: SurveyResponseAnswerSanitizer.pruneHiddenAnswers(
        questions: survey.questions,
        response: updatedResponse,
      ),
    );
  }

  SurveyPreviewSession reset({DateTime? startedAt}) {
    return SurveyPreviewSession.initial(survey, startedAt: startedAt);
  }

  SurveyResponseSectionFlow get sectionFlow {
    return SurveyResponseSectionFlow(survey: survey, response: response);
  }

  SurveyResponseSessionSummary summary({DateTime? now}) {
    return SurveyResponseSessionSummary.evaluate(
      survey: survey,
      response: response,
      now: now,
    );
  }
}
