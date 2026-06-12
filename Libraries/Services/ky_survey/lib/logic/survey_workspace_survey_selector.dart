import '../models/survey.dart';
import '../models/survey_workspace_intent.dart';

/// Selects surveys for workspace shortcuts and launch intents.
class SurveyWorkspaceSurveySelector {
  const SurveyWorkspaceSurveySelector._();

  static Survey? mostRecentSurvey(List<Survey> surveys) {
    Survey? result;
    for (final survey in surveys) {
      final resultDate = result == null ? null : _activityDate(result);
      if (resultDate == null || _activityDate(survey).isAfter(resultDate)) {
        result = survey;
      }
    }
    return result;
  }

  static Survey? surveyForIntent(
    SurveyWorkspaceIntent intent,
    List<Survey> surveys,
  ) {
    final surveyId = intent.surveyId;
    if (surveyId == null) {
      return mostRecentSurvey(surveys);
    }

    for (final survey in surveys) {
      if (survey.id == surveyId) {
        return survey;
      }
    }

    return null;
  }

  static DateTime _activityDate(Survey survey) {
    return survey.updatedAt ?? survey.createdAt;
  }
}
