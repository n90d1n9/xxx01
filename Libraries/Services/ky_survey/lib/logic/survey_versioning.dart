import '../models/survey.dart';
import '../models/survey_response.dart';
import '../models/survey_version.dart';

class SurveyVersioning {
  const SurveyVersioning._();

  static int nextVersionNumber(Survey survey) {
    var latestVersion = survey.currentVersion;
    for (final version in survey.versions) {
      if (version.versionNumber > latestVersion) {
        latestVersion = version.versionNumber;
      }
    }

    return latestVersion + 1;
  }

  static SurveyVersion createSnapshot({
    required Survey survey,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? note,
  }) {
    final versionNumber = nextVersionNumber(survey);
    final timestamp = createdAt ?? publishedAt ?? DateTime.now();

    return SurveyVersion(
      id: '${survey.id}-v$versionNumber',
      surveyId: survey.id,
      versionNumber: versionNumber,
      title: survey.title,
      description: survey.description,
      sections: [...survey.sections],
      questions: [...survey.questions],
      evidenceRequirements: [...survey.evidenceRequirements],
      createdAt: timestamp,
      publishedAt: publishedAt,
      note: note,
    );
  }

  static Survey publishSnapshot({
    required Survey survey,
    DateTime? publishedAt,
    String? note,
  }) {
    final timestamp = publishedAt ?? DateTime.now();
    final version = createSnapshot(
      survey: survey,
      createdAt: timestamp,
      publishedAt: timestamp,
      note: note,
    );

    return survey.copyWith(
      versions: [...survey.versions, version],
      currentVersion: version.versionNumber,
      activeVersionId: version.id,
      publishedAt: survey.publishedAt ?? timestamp,
      updatedAt: timestamp,
    );
  }

  static Survey surveyForResponse({
    required Survey survey,
    required SurveyResponse response,
  }) {
    final versionId = response.surveyVersionId;
    if (versionId == null) {
      return survey;
    }

    final version = survey.versionById(versionId);
    if (version == null) {
      return survey;
    }

    return surveyFromVersion(survey: survey, version: version);
  }

  static Survey surveyFromVersion({
    required Survey survey,
    required SurveyVersion version,
  }) {
    return survey.copyWith(
      title: version.title,
      description: version.description,
      sections: version.sections,
      questions: version.questions,
      evidenceRequirements: version.evidenceRequirements,
      currentVersion: version.versionNumber,
      activeVersionId: version.id,
    );
  }
}
