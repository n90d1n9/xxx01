import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_delivery_command_view_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_command_service.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_saved_lens_service.dart';
import 'package:kaysir/features/project_management/project/states/project_delivery_command_provider.dart';

void main() {
  test('project delivery command providers keep command filters in state', () {
    final container = _containerWithMemoryViewStore();
    addTearDown(container.dispose);

    final allCommands = container.read(filteredProjectDeliveryCommandsProvider);
    expect(allCommands, isNotEmpty);

    container
        .read(projectDeliveryCommandViewProvider.notifier)
        .setLevel(ProjectDeliveryCommandLevel.warning);

    final warningCommands = container.read(
      filteredProjectDeliveryCommandsProvider,
    );
    expect(warningCommands, isNotEmpty);
    expect(
      warningCommands.every(
        (command) => command.level == ProjectDeliveryCommandLevel.warning,
      ),
      isTrue,
    );

    final warningKind = warningCommands.first.kind;
    container
        .read(projectDeliveryCommandViewProvider.notifier)
        .setKind(warningKind);

    final matchingWarningCommands = container.read(
      filteredProjectDeliveryCommandsProvider,
    );
    expect(matchingWarningCommands, isNotEmpty);
    expect(
      matchingWarningCommands.every(
        (command) =>
            command.level == ProjectDeliveryCommandLevel.warning &&
            command.kind == warningKind,
      ),
      isTrue,
    );

    container.read(projectDeliveryCommandViewProvider.notifier).resetFilter();

    expect(
      container.read(projectDeliveryCommandFilterProvider),
      ProjectDeliveryCommandFilter.empty,
    );
    expect(
      container
          .read(filteredProjectDeliveryCommandsProvider)
          .map((command) => command.id),
      allCommands.map((command) => command.id),
    );
  });

  test('project delivery saved lens providers switch role lenses', () {
    final container = _containerWithMemoryViewStore();
    addTearDown(container.dispose);

    expect(
      container.read(projectDeliverySavedLensesProvider).map((lens) => lens.id),
      contains('firefight'),
    );

    container
        .read(projectDeliveryCommandViewProvider.notifier)
        .setProfile(ProjectDeliverySavedLensProfile.financePartner);

    expect(
      container.read(projectDeliverySavedLensesProvider).map((lens) => lens.id),
      containsAll(['budget-control', 'critical-funding']),
    );
    expect(
      container.read(projectDeliverySavedLensesProvider).map((lens) => lens.id),
      isNot(contains('dependency-desk')),
    );
  });

  test(
    'project delivery command view provider persists view preferences',
    () async {
      final store = MemoryProjectDeliveryCommandViewSnapshotStore();
      final firstContainer = _containerWithMemoryViewStore(store);
      addTearDown(firstContainer.dispose);

      await firstContainer
          .read(projectDeliveryCommandViewProvider.notifier)
          .hydrate();
      firstContainer
          .read(projectDeliveryCommandViewProvider.notifier)
          .setProfile(ProjectDeliverySavedLensProfile.releaseDesk);
      firstContainer
          .read(projectDeliveryCommandViewProvider.notifier)
          .setFilter(
            const ProjectDeliveryCommandFilter(
              kind: ProjectDeliveryCommandKind.schedule,
            ),
          );
      await firstContainer
          .read(projectDeliveryCommandViewProvider.notifier)
          .flushPersistence();

      final secondContainer = _containerWithMemoryViewStore(store);
      addTearDown(secondContainer.dispose);

      await secondContainer
          .read(projectDeliveryCommandViewProvider.notifier)
          .hydrate();

      expect(
        secondContainer.read(projectDeliverySavedLensProfileProvider),
        ProjectDeliverySavedLensProfile.releaseDesk,
      );
      expect(
        secondContainer.read(projectDeliveryCommandFilterProvider),
        const ProjectDeliveryCommandFilter(
          kind: ProjectDeliveryCommandKind.schedule,
        ),
      );
    },
  );
}

ProviderContainer _containerWithMemoryViewStore([
  MemoryProjectDeliveryCommandViewSnapshotStore? store,
]) {
  return ProviderContainer(
    overrides: [
      projectDeliveryCommandViewRepositoryProvider.overrideWithValue(
        ProjectDeliveryCommandViewRepository(
          store: store ?? MemoryProjectDeliveryCommandViewSnapshotStore(),
        ),
      ),
    ],
  );
}
