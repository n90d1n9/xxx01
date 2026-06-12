import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_status_update_preferences_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';
import 'package:kaysir/features/project_management/project/states/project_status_update_provider.dart';

void main() {
  test(
    'project status update provider persists selected wording controls',
    () async {
      final store = MemoryProjectStatusUpdatePreferencesSnapshotStore();
      final firstContainer = _containerWithMemoryStore(store);
      addTearDown(firstContainer.dispose);

      await firstContainer
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .hydrate();
      firstContainer
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .setVocabulary(ProjectStatusUpdateVocabulary.wedding);
      firstContainer
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .setAudience(ProjectStatusUpdateAudience.client);
      await firstContainer
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .flushPersistence();

      final secondContainer = _containerWithMemoryStore(store);
      addTearDown(secondContainer.dispose);

      await secondContainer
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .hydrate();

      expect(
        secondContainer.read(projectStatusUpdateVocabularyIdProvider),
        ProjectStatusUpdateVocabulary.wedding.id,
      );
      expect(
        secondContainer.read(selectedProjectStatusUpdateVocabularyProvider),
        ProjectStatusUpdateVocabulary.wedding,
      );
      expect(
        secondContainer.read(projectStatusUpdateAudienceIdProvider),
        ProjectStatusUpdateAudience.client.id,
      );
      expect(
        secondContainer.read(selectedProjectStatusUpdateAudienceProvider),
        ProjectStatusUpdateAudience.client,
      );
    },
  );

  test(
    'project status update provider persists project-specific wording controls',
    () async {
      final store = MemoryProjectStatusUpdatePreferencesSnapshotStore();
      final firstContainer = _containerWithMemoryStore(store);
      addTearDown(firstContainer.dispose);

      await firstContainer
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .hydrate();
      firstContainer
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .setVocabulary(ProjectStatusUpdateVocabulary.construction);
      firstContainer
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .setProjectVocabulary(
            projectId: 'mobile-field-app',
            vocabulary: ProjectStatusUpdateVocabulary.software,
          );
      firstContainer
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .setProjectAudience(
            projectId: 'mobile-field-app',
            audience: ProjectStatusUpdateAudience.team,
          );
      await firstContainer
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .flushPersistence();

      final secondContainer = _containerWithMemoryStore(store);
      addTearDown(secondContainer.dispose);

      await secondContainer
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .hydrate();

      expect(
        secondContainer.read(selectedProjectStatusUpdateVocabularyProvider),
        ProjectStatusUpdateVocabulary.construction,
      );
      expect(
        secondContainer.read(
          selectedProjectStatusUpdateVocabularyForProjectProvider(
            'mobile-field-app',
          ),
        ),
        ProjectStatusUpdateVocabulary.software,
      );
      expect(
        secondContainer.read(
          selectedProjectStatusUpdateAudienceForProjectProvider(
            'mobile-field-app',
          ),
        ),
        ProjectStatusUpdateAudience.team,
      );
      expect(
        secondContainer.read(
          selectedProjectStatusUpdateVocabularyForProjectProvider(
            'warehouse-automation',
          ),
        ),
        ProjectStatusUpdateVocabulary.construction,
      );
    },
  );

  test(
    'project status update provider falls back to project domain profile',
    () {
      final container = _containerWithMemoryStore();
      addTearDown(container.dispose);

      expect(
        container.read(
          selectedProjectStatusUpdateVocabularyForProjectProvider(
            'retail-modernization',
          ),
        ),
        ProjectStatusUpdateVocabulary.retailOperations,
      );
      expect(
        container.read(
          selectedProjectStatusUpdateAudienceForProjectProvider(
            'retail-modernization',
          ),
        ),
        ProjectStatusUpdateAudience.team,
      );
      expect(
        container.read(
          selectedProjectStatusUpdateVocabularyForProjectProvider(
            'mobile-field-app',
          ),
        ),
        ProjectStatusUpdateVocabulary.software,
      );
    },
  );

  test(
    'project status update provider lets global controls override domain',
    () {
      final container = _containerWithMemoryStore();
      addTearDown(container.dispose);

      container
          .read(projectStatusUpdatePreferencesProvider.notifier)
          .setVocabulary(ProjectStatusUpdateVocabulary.construction);

      expect(
        container.read(
          selectedProjectStatusUpdateVocabularyForProjectProvider(
            'retail-modernization',
          ),
        ),
        ProjectStatusUpdateVocabulary.construction,
      );
      expect(
        container.read(
          selectedProjectStatusUpdateAudienceForProjectProvider(
            'retail-modernization',
          ),
        ),
        ProjectStatusUpdateAudience.stakeholder,
      );
    },
  );

  test('project status update provider ignores empty preference ids', () {
    final container = _containerWithMemoryStore();
    addTearDown(container.dispose);

    container
        .read(projectStatusUpdatePreferencesProvider.notifier)
        .setVocabularyId('   ');
    container
        .read(projectStatusUpdatePreferencesProvider.notifier)
        .setAudienceId('   ');

    expect(
      container.read(projectStatusUpdateVocabularyIdProvider),
      ProjectStatusUpdateVocabulary.general.id,
    );
    expect(
      container.read(projectStatusUpdateAudienceIdProvider),
      ProjectStatusUpdateAudience.stakeholder.id,
    );
  });

  test('project status update provider can reset a project override', () {
    final container = _containerWithMemoryStore();
    addTearDown(container.dispose);

    container
        .read(projectStatusUpdatePreferencesProvider.notifier)
        .setProjectVocabulary(
          projectId: 'mobile-field-app',
          vocabulary: ProjectStatusUpdateVocabulary.software,
        );
    container
        .read(projectStatusUpdatePreferencesProvider.notifier)
        .resetProject('mobile-field-app');

    expect(
      container.read(
        selectedProjectStatusUpdateVocabularyForProjectProvider(
          'mobile-field-app',
        ),
      ),
      ProjectStatusUpdateVocabulary.software,
    );
  });
}

ProviderContainer _containerWithMemoryStore([
  MemoryProjectStatusUpdatePreferencesSnapshotStore? store,
]) {
  return ProviderContainer(
    overrides: [
      projectStatusUpdatePreferencesRepositoryProvider.overrideWithValue(
        ProjectStatusUpdatePreferencesRepository(
          store: store ?? MemoryProjectStatusUpdatePreferencesSnapshotStore(),
        ),
      ),
    ],
  );
}
