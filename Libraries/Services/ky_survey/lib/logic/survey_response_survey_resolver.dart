import '../models/question.dart';
import '../models/survey.dart';
import '../models/survey_response.dart';
import 'question_visibility_evaluator.dart';
import 'survey_versioning.dart';

class SurveyResponseSurveyResolver {
  final List<Survey> surveys;

  const SurveyResponseSurveyResolver({required this.surveys});

  Survey? rootSurveyForResponse(SurveyResponse response) {
    for (final survey in surveys) {
      if (survey.id == response.surveyId) {
        return survey;
      }
    }

    return null;
  }

  Survey? surveyForResponse(SurveyResponse response) {
    final survey = rootSurveyForResponse(response);
    if (survey == null) {
      return null;
    }

    return SurveyVersioning.surveyForResponse(
      survey: survey,
      response: response,
    );
  }

  List<Question> visibleQuestionsForResponse(SurveyResponse response) {
    final survey = surveyForResponse(response);
    if (survey == null) {
      return const [];
    }

    return QuestionVisibilityEvaluator.visibleQuestions(
      survey.questions,
      response,
    );
  }
}
