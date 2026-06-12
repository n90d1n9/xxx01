import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_workspace_survey_selector.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_workspace_intent.dart';

void main() {
  group('SurveyWorkspaceSurveySelector', () {
    test('selects a survey by workspace intent id', () {
      final first = _survey(id: 'first', createdAt: DateTime(2026, 1, 1));
      final second = _survey(id: 'second', createdAt: DateTime(2026, 1, 2));

      final selected = SurveyWorkspaceSurveySelector.surveyForIntent(
        const SurveyWorkspaceIntent.builder(surveyId: 'second'),
        [first, second],
      );

      expect(selected, second);
    });

    test('returns null when an explicit workspace intent id is missing', () {
      final survey = _survey(id: 'available', createdAt: DateTime(2026, 1, 1));

      final selected = SurveyWorkspaceSurveySelector.surveyForIntent(
        const SurveyWorkspaceIntent.intake(surveyId: 'missing'),
        [survey],
      );

      expect(selected, isNull);
    });

    test('falls back to the most recently active survey without an id', () {
      final older = _survey(
        id: 'older',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 5),
      );
      final newer = _survey(
        id: 'newer',
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 7),
      );

      expect(
        SurveyWorkspaceSurveySelector.surveyForIntent(
          const SurveyWorkspaceIntent.intake(),
          [older, newer],
        ),
        newer,
      );
      expect(
        SurveyWorkspaceSurveySelector.mostRecentSurvey([older, newer]),
        newer,
      );
      expect(SurveyWorkspaceSurveySelector.mostRecentSurvey(const []), isNull);
    });
  });
}

Survey _survey({
  required String id,
  required DateTime createdAt,
  DateTime? updatedAt,
}) {
  return Survey(
    id: id,
    title: '$id survey',
    description: 'Workspace selector test',
    questions: const [],
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
