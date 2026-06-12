import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_preferences_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';

void main() {
  test('project status update preferences serialize default wording', () {
    const preferences = ProjectStatusUpdatePreferences(
      vocabularyId: 'construction',
      audienceId: 'sponsor',
    );

    expect(preferences.toJson(), {
      'vocabularyId': 'construction',
      'audienceId': 'sponsor',
    });
    expect(
      ProjectStatusUpdatePreferences.fromJson(preferences.toJson()),
      preferences,
    );
  });

  test('project status update preferences serialize project selections', () {
    final preferences = ProjectStatusUpdatePreferences.initial
        .withProjectSelection(
          projectId: 'mobile-field-app',
          selection: const ProjectStatusUpdatePreferenceSelection(
            vocabularyId: 'software',
            audienceId: 'team',
          ),
        )
        .withProjectSelection(
          projectId: 'grand-hall-wedding',
          selection: const ProjectStatusUpdatePreferenceSelection(
            vocabularyId: 'wedding',
            audienceId: 'client',
          ),
        );

    final restored = ProjectStatusUpdatePreferences.fromJson(
      preferences.toJson(),
    );

    expect(restored, preferences);
    expect(
      restored.selectionForProject('mobile-field-app'),
      const ProjectStatusUpdatePreferenceSelection(
        vocabularyId: 'software',
        audienceId: 'team',
      ),
    );
    expect(
      restored.selectionForProject('unknown-project'),
      ProjectStatusUpdatePreferenceSelection.initial,
    );
  });

  test('project status update preferences tolerate stale snapshots', () {
    expect(
      ProjectStatusUpdatePreferences.fromJson(const {}),
      ProjectStatusUpdatePreferences.initial,
    );
    expect(
      ProjectStatusUpdatePreferences.fromJson(const {'vocabularyId': ''}),
      ProjectStatusUpdatePreferences.initial,
    );
    expect(
      ProjectStatusUpdatePreferences.fromJson(const {'vocabularyId': 42}),
      ProjectStatusUpdatePreferences.initial,
    );
    expect(
      ProjectStatusUpdatePreferences.fromJson(const {
        'vocabularyId': 'software',
      }),
      const ProjectStatusUpdatePreferences(
        vocabularyId: 'software',
        audienceId: ProjectStatusUpdatePreferences.defaultAudienceId,
      ),
    );
    expect(
      ProjectStatusUpdatePreferences.fromJson(const {
        'projectSelections': {
          'mobile-field-app': {'vocabularyId': 'software'},
          'invalid': 'not-a-map',
        },
      }).selectionForProject('mobile-field-app'),
      const ProjectStatusUpdatePreferenceSelection(
        vocabularyId: 'software',
        audienceId: ProjectStatusUpdatePreferences.defaultAudienceId,
      ),
    );
  });

  test('status update vocabulary resolver falls back predictably', () {
    expect(
      resolveStatusUpdateVocabulary(
        availableVocabularies: ProjectStatusUpdateVocabulary.defaults,
        vocabularyId: 'software',
      ),
      ProjectStatusUpdateVocabulary.software,
    );
    expect(
      resolveStatusUpdateVocabulary(
        availableVocabularies: const [
          ProjectStatusUpdateVocabulary.software,
          ProjectStatusUpdateVocabulary.wedding,
        ],
        vocabularyId: 'missing-domain',
      ),
      ProjectStatusUpdateVocabulary.software,
    );
    expect(
      resolveStatusUpdateVocabulary(
        availableVocabularies: const [],
        vocabularyId: 'missing-domain',
      ),
      ProjectStatusUpdateVocabulary.general,
    );
  });

  test('status update audience resolver falls back predictably', () {
    expect(
      resolveStatusUpdateAudience(
        availableAudiences: ProjectStatusUpdateAudience.values,
        audienceId: ProjectStatusUpdateAudience.client.id,
      ),
      ProjectStatusUpdateAudience.client,
    );
    expect(
      resolveStatusUpdateAudience(
        availableAudiences: const [
          ProjectStatusUpdateAudience.sponsor,
          ProjectStatusUpdateAudience.team,
        ],
        audienceId: 'missing-audience',
      ),
      ProjectStatusUpdateAudience.sponsor,
    );
    expect(
      resolveStatusUpdateAudience(
        availableAudiences: const [],
        audienceId: 'missing-audience',
      ),
      ProjectStatusUpdateAudience.stakeholder,
    );
  });
}
