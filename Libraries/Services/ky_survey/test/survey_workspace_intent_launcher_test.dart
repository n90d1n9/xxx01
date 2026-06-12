import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_workspace_intent_launcher.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/models/survey_workspace_intent.dart';

void main() {
  group('SurveyWorkspaceIntentLauncher', () {
    test('ignores workspace-only intents', () {
      final calls = <String>[];

      _launcher(calls: calls).launch(const SurveyWorkspaceIntent.overview());

      expect(calls, isEmpty);
    });

    test('dispatches survey list and create survey intents', () {
      final calls = <String>[];
      final launcher = _launcher(calls: calls);

      launcher.launch(const SurveyWorkspaceIntent.surveyList());
      launcher.launch(const SurveyWorkspaceIntent.newBuilder());

      expect(calls, ['list', 'create']);
    });

    test('dispatches edit and intake intents to matching surveys', () {
      final calls = <String>[];
      final first = _survey(id: 'first', createdAt: DateTime(2026, 1, 1));
      final second = _survey(id: 'second', createdAt: DateTime(2026, 1, 2));
      final launcher = _launcher(calls: calls, surveys: [first, second]);

      launcher.launch(const SurveyWorkspaceIntent.builder(surveyId: 'second'));
      launcher.launch(const SurveyWorkspaceIntent.intake(surveyId: 'first'));

      expect(calls, ['edit:second', 'open:first']);
    });

    test('uses latest survey when a survey-specific intent has no id', () {
      final calls = <String>[];
      final older = _survey(
        id: 'older',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 3),
      );
      final newer = _survey(
        id: 'newer',
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 5),
      );
      final launcher = _launcher(calls: calls, surveys: [older, newer]);

      launcher.launch(
        const SurveyWorkspaceIntent(
          launchTarget: SurveyWorkspaceLaunchTarget.editSurvey,
        ),
      );

      expect(calls, ['edit:newer']);
    });

    test('reports unavailable survey-specific intents', () {
      final calls = <String>[];
      final launcher = _launcher(calls: calls);

      launcher.launch(const SurveyWorkspaceIntent.intake(surveyId: 'missing'));

      expect(calls, ['unavailable:Intake screen']);
    });

    test('reports role-disabled launch targets as unavailable', () {
      final calls = <String>[];
      final survey = _survey(id: 'survey', createdAt: DateTime(2026, 1, 3));
      final launcher = _launcher(calls: calls, surveys: [survey]);

      launcher.launch(
        const SurveyWorkspaceIntent.newBuilder(role: SurveyRole.interviewer),
      );
      launcher.launch(
        const SurveyWorkspaceIntent.builder(
          role: SurveyRole.interviewer,
          surveyId: 'survey',
          openEditor: true,
        ),
      );
      launcher.launch(
        const SurveyWorkspaceIntent.intake(
          role: SurveyRole.interviewer,
          surveyId: 'survey',
        ),
      );

      expect(calls, [
        'unavailable:New builder',
        'unavailable:Builder',
        'open:survey',
      ]);
    });
  });
}

SurveyWorkspaceIntentLauncher _launcher({
  required List<String> calls,
  List<Survey> surveys = const [],
}) {
  return SurveyWorkspaceIntentLauncher(
    surveys: surveys,
    onOpenSurveyList: () => calls.add('list'),
    onCreateSurvey: () => calls.add('create'),
    onEditSurvey: (survey) => calls.add('edit:${survey.id}'),
    onOpenSurvey: (survey) => calls.add('open:${survey.id}'),
    onUnavailable: (intent) =>
        calls.add('unavailable:${intent.launchTarget.label}'),
  );
}

Survey _survey({
  required String id,
  required DateTime createdAt,
  DateTime? updatedAt,
}) {
  return Survey(
    id: id,
    title: '$id survey',
    description: 'Workspace intent launcher test',
    questions: const [],
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
