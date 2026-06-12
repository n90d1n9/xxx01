import '../models/survey_response.dart';

class SurveyResponseDraftSelector {
  const SurveyResponseDraftSelector._();

  static SurveyResponse? activeDraftFor({
    required Iterable<SurveyResponse> responses,
    required String surveyId,
    required String respondentId,
    String? collectorId,
    String? surveyVersionId,
  }) {
    SurveyResponse? selected;

    for (final response in activeDraftsFor(
      responses: responses,
      surveyId: surveyId,
      respondentId: respondentId,
      collectorId: collectorId,
      surveyVersionId: surveyVersionId,
    )) {
      if (selected == null ||
          lastActivityAt(response).isAfter(lastActivityAt(selected))) {
        selected = response;
      }
    }

    return selected;
  }

  static List<SurveyResponse> activeDraftsFor({
    required Iterable<SurveyResponse> responses,
    required String surveyId,
    required String respondentId,
    String? collectorId,
    String? surveyVersionId,
  }) {
    return responses
        .where((response) {
          return response.status == SurveyResponseStatus.draft &&
              response.surveyId == surveyId &&
              response.respondentId == respondentId &&
              response.collectorId == collectorId &&
              response.surveyVersionId == surveyVersionId;
        })
        .toList(growable: false);
  }

  static DateTime lastActivityAt(SurveyResponse response) {
    var latest = response.startedAt;
    for (final answer in response.answers) {
      if (answer.answeredAt.isAfter(latest)) {
        latest = answer.answeredAt;
      }
    }

    return latest;
  }
}
