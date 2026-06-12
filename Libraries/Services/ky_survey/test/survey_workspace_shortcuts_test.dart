import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/widgets/dashboard/survey_workspace_shortcuts.dart';

void main() {
  group('SurveyWorkspaceShortcutBuilder', () {
    test('builds disabled survey-specific shortcuts without surveys', () {
      final shortcuts = SurveyWorkspaceShortcutBuilder(
        surveys: const [],
        onOpenSurveyList: () {},
        onCreateSurvey: () {},
        onEditSurvey: (_) {},
        onOpenSurvey: (_) {},
      ).build();

      expect(shortcuts.map((shortcut) => shortcut.label), [
        'Survey list',
        'New builder',
        'Latest builder',
        'Intake screen',
      ]);
      expect(shortcuts[2].subtitle, 'Create a survey first');
      expect(shortcuts[2].onPressed, isNull);
      expect(shortcuts[3].onPressed, isNull);
    });

    test('uses the most recently active survey for builder and intake', () {
      final older = _survey(
        id: 'older',
        title: 'Older Survey',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 5),
      );
      final newer = _survey(
        id: 'newer',
        title: 'Newer Survey',
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 7),
      );
      Survey? editedSurvey;
      Survey? openedSurvey;

      final shortcuts = SurveyWorkspaceShortcutBuilder(
        surveys: [older, newer],
        onOpenSurveyList: () {},
        onCreateSurvey: () {},
        onEditSurvey: (survey) => editedSurvey = survey,
        onOpenSurvey: (survey) => openedSurvey = survey,
      ).build();

      expect(
        SurveyWorkspaceShortcutBuilder.mostRecentSurvey([older, newer]),
        newer,
      );
      expect(shortcuts[2].subtitle, 'Newer Survey');
      expect(shortcuts[3].subtitle, 'Newer Survey');

      shortcuts[2].onPressed?.call();
      shortcuts[3].onPressed?.call();

      expect(editedSurvey, newer);
      expect(openedSurvey, newer);
    });

    test('filters screen shortcuts to actions allowed by role', () {
      final survey = _survey(
        id: 'participant',
        title: 'Participant Survey',
        createdAt: DateTime(2026, 1, 8),
      );
      Survey? openedSurvey;

      final participantShortcuts = SurveyWorkspaceShortcutBuilder(
        role: SurveyRole.participant,
        surveys: [survey],
        onOpenSurveyList: () {},
        onCreateSurvey: () {},
        onEditSurvey: (_) {},
        onOpenSurvey: (survey) => openedSurvey = survey,
      ).build();
      final analystShortcuts = SurveyWorkspaceShortcutBuilder(
        role: SurveyRole.analyst,
        surveys: [survey],
        onOpenSurveyList: () {},
        onCreateSurvey: () {},
        onEditSurvey: (_) {},
        onOpenSurvey: (_) {},
      ).build();

      expect(participantShortcuts.map((shortcut) => shortcut.label), [
        'Intake screen',
      ]);
      expect(participantShortcuts.single.subtitle, 'Participant Survey');

      participantShortcuts.single.onPressed?.call();

      expect(openedSurvey, survey);
      expect(analystShortcuts, isEmpty);
    });
  });
}

Survey _survey({
  required String id,
  required String title,
  required DateTime createdAt,
  DateTime? updatedAt,
}) {
  return Survey(
    id: id,
    title: title,
    description: 'Shortcut test',
    createdAt: createdAt,
    updatedAt: updatedAt,
    questions: const [],
  );
}
