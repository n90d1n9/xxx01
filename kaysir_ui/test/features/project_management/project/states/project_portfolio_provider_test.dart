import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_created_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_view_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_focus_service.dart';
import 'package:kaysir/features/project_management/project/services/project_portfolio_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_priority_service.dart';
import 'package:kaysir/features/project_management/project/services/project_saved_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_view_service.dart';
import 'package:kaysir/features/project_management/project/states/project_portfolio_provider.dart';

void main() {
  test('project portfolio providers filter and resolve detail records', () {
    final container = _containerWithMemoryViewStore();
    addTearDown(container.dispose);

    expect(container.read(projectPortfolioProvider), hasLength(4));
    expect(
      container
          .read(filteredProjectPortfolioProvider)
          .map((project) => project.id),
      [
        'mobile-field-app',
        'warehouse-automation',
        'finance-close-suite',
        'retail-modernization',
      ],
    );

    container
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setSearchQuery('mobile');
    expect(
      container
          .read(filteredProjectPortfolioProvider)
          .map((project) => project.id),
      ['mobile-field-app'],
    );

    container
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setSearchQuery('');
    container
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setHealthFilter(ProjectHealth.atRisk);

    expect(
      container
          .read(filteredProjectPortfolioProvider)
          .map((project) => project.id),
      ['warehouse-automation'],
    );

    final detail = container.read(projectByIdProvider('retail-modernization'));
    expect(detail?.owner, 'Maya Santoso');
  });

  test('project portfolio providers sort project board views', () {
    final container = _containerWithMemoryViewStore();
    addTearDown(container.dispose);

    container
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setSortOption(ProjectPortfolioSortOption.dueDate);

    expect(
      container
          .read(filteredProjectPortfolioProvider)
          .map((project) => project.id),
      [
        'finance-close-suite',
        'warehouse-automation',
        'retail-modernization',
        'mobile-field-app',
      ],
    );
  });

  test('project portfolio providers apply saved view presets', () {
    final container = _containerWithMemoryViewStore();
    addTearDown(container.dispose);

    container
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setViewPreset(ProjectPortfolioViewPreset.budgetPressure);

    expect(
      container.read(projectSortProvider),
      ProjectPortfolioSortOption.budget,
    );
    expect(
      container.read(projectTableColumnProfileProvider),
      ProjectTableColumnProfile.financial,
    );

    expect(
      container
          .read(filteredProjectPortfolioProvider)
          .map((project) => project.id),
      ['warehouse-automation'],
    );

    container
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setViewPreset(ProjectPortfolioViewPreset.domainGaps);

    expect(
      container.read(projectSortProvider),
      ProjectPortfolioSortOption.domainContext,
    );
    expect(
      container.read(projectTableColumnProfileProvider),
      ProjectTableColumnProfile.domainContext,
    );
    expect(
      container.read(projectDomainGapFocusProvider),
      ProjectDomainGapFocus.missingAny,
    );

    expect(
      container
          .read(filteredProjectPortfolioProvider)
          .map((project) => project.id),
      [
        'mobile-field-app',
        'warehouse-automation',
        'finance-close-suite',
        'retail-modernization',
      ],
    );
  });

  test('project portfolio providers filter by domain readiness', () {
    final container = _containerWithMemoryViewStore();
    addTearDown(container.dispose);

    container
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setDomainReadinessFilter(ProjectDomainReadinessFilter.inProgress);
    expect(
      container.read(projectTableColumnProfileProvider),
      ProjectTableColumnProfile.domainContext,
    );

    expect(
      container
          .read(filteredProjectPortfolioProvider)
          .map((project) => project.id),
      ['retail-modernization'],
    );

    container
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setDomainReadinessFilter(ProjectDomainReadinessFilter.needsContext);

    expect(
      container
          .read(filteredProjectPortfolioProvider)
          .map((project) => project.id),
      ['mobile-field-app', 'warehouse-automation', 'finance-close-suite'],
    );
  });

  test('project portfolio providers filter by domain gap focus', () {
    final container = _containerWithMemoryViewStore();
    addTearDown(container.dispose);

    container
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setDomainGapFocus(ProjectDomainGapFocus.missingRequired);

    expect(
      container.read(projectDomainGapFocusProvider),
      ProjectDomainGapFocus.missingRequired,
    );
    expect(
      container.read(projectTableColumnProfileProvider),
      ProjectTableColumnProfile.domainContext,
    );
    expect(
      container
          .read(filteredProjectPortfolioProvider)
          .map((project) => project.id),
      ['mobile-field-app', 'warehouse-automation', 'finance-close-suite'],
    );
  });

  test('created project records flow through portfolio providers', () {
    final container = _containerWithMemoryViewStore();
    addTearDown(container.dispose);

    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      name: 'Campus Renovation',
      client: 'Education Office',
      owner: 'Dewi Lestari',
      sponsor: 'Academic Operations',
      businessDomain: 'Construction',
      summary:
          'Coordinates classroom renovation, inspection proof, and opening readiness.',
      progress: 0.2,
      budgetUsed: 0.1,
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'permit-id',
          label: 'Permit ID',
          type: ProjectCustomAttributeType.text,
          value: 'IMB-2026-77',
          isPinned: true,
        ),
      ],
    );

    final created = container
        .read(createdProjectPortfolioProvider.notifier)
        .createFromDraft(
          draft: draft,
          existingProjects: container.read(projectPortfolioProvider),
        );

    expect(created.id, 'campus-renovation');
    expect(container.read(projectPortfolioProvider), hasLength(5));
    expect(
      container.read(projectByIdProvider('campus-renovation'))?.client,
      'Education Office',
    );

    container
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setSearchQuery('campus');
    expect(
      container
          .read(filteredProjectPortfolioProvider)
          .map((project) => project.id),
      ['campus-renovation'],
    );

    container
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setSearchQuery('imb-2026-77');
    expect(
      container
          .read(filteredProjectPortfolioProvider)
          .map((project) => project.id),
      ['campus-renovation'],
    );
  });

  test('created project provider persists local project records', () async {
    final store = MemoryProjectCreatedPortfolioSnapshotStore();
    final firstContainer = _containerWithMemoryViewStore(null, store);
    addTearDown(firstContainer.dispose);

    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      name: 'Campus Renovation',
      client: 'Education Office',
      owner: 'Dewi Lestari',
      sponsor: 'Academic Operations',
      businessDomain: 'Construction',
      summary:
          'Coordinates classroom renovation, inspection proof, and opening readiness.',
    );

    await firstContainer
        .read(createdProjectPortfolioProvider.notifier)
        .hydrate();
    firstContainer
        .read(createdProjectPortfolioProvider.notifier)
        .createFromDraft(
          draft: draft,
          existingProjects: firstContainer.read(projectPortfolioProvider),
        );
    await firstContainer
        .read(createdProjectPortfolioProvider.notifier)
        .flushPersistence();

    final secondContainer = _containerWithMemoryViewStore(null, store);
    addTearDown(secondContainer.dispose);

    await secondContainer
        .read(createdProjectPortfolioProvider.notifier)
        .hydrate();

    expect(secondContainer.read(createdProjectPortfolioProvider), hasLength(1));
    expect(
      secondContainer.read(projectByIdProvider('campus-renovation'))?.owner,
      'Dewi Lestari',
    );
    expect(secondContainer.read(projectPortfolioProvider), hasLength(5));
  });

  test('created project provider removes local project records', () async {
    final store = MemoryProjectCreatedPortfolioSnapshotStore();
    final firstContainer = _containerWithMemoryViewStore(null, store);
    addTearDown(firstContainer.dispose);

    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      name: 'Campus Renovation',
      client: 'Education Office',
      owner: 'Dewi Lestari',
      sponsor: 'Academic Operations',
      businessDomain: 'Construction',
      summary:
          'Coordinates classroom renovation, inspection proof, and opening readiness.',
    );

    final created = firstContainer
        .read(createdProjectPortfolioProvider.notifier)
        .createFromDraft(
          draft: draft,
          existingProjects: firstContainer.read(projectPortfolioProvider),
        );

    expect(firstContainer.read(createdProjectPortfolioIdsProvider), {
      created.id,
    });
    expect(
      firstContainer
          .read(createdProjectPortfolioProvider.notifier)
          .removeById(created.id),
      true,
    );
    expect(firstContainer.read(createdProjectPortfolioProvider), isEmpty);
    expect(firstContainer.read(projectByIdProvider(created.id)), isNull);
    await firstContainer
        .read(createdProjectPortfolioProvider.notifier)
        .flushPersistence();

    final secondContainer = _containerWithMemoryViewStore(null, store);
    addTearDown(secondContainer.dispose);
    await secondContainer
        .read(createdProjectPortfolioProvider.notifier)
        .hydrate();

    expect(secondContainer.read(createdProjectPortfolioProvider), isEmpty);
    expect(secondContainer.read(projectPortfolioProvider), hasLength(4));
  });

  test('created project provider updates local project records', () async {
    final store = MemoryProjectCreatedPortfolioSnapshotStore();
    final firstContainer = _containerWithMemoryViewStore(null, store);
    addTearDown(firstContainer.dispose);

    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      name: 'Campus Renovation',
      client: 'Education Office',
      owner: 'Dewi Lestari',
      sponsor: 'Academic Operations',
      businessDomain: 'Construction',
      summary:
          'Coordinates classroom renovation, inspection proof, and opening readiness.',
    );
    final created = firstContainer
        .read(createdProjectPortfolioProvider.notifier)
        .createFromDraft(
          draft: draft,
          existingProjects: firstContainer.read(projectPortfolioProvider),
        );

    final updated = firstContainer
        .read(createdProjectPortfolioProvider.notifier)
        .updateFromDraft(
          projectId: created.id,
          draft: draft.copyWith(
            name: 'Campus Renovation Phase 2',
            businessDomain: 'Education Program',
            progress: 0.45,
          ),
        );

    expect(updated?.id, created.id);
    expect(updated?.name, 'Campus Renovation Phase 2');
    expect(updated?.businessDomain, 'Education Program');
    expect(
      firstContainer.read(projectByIdProvider(created.id))?.progress,
      0.45,
    );

    await firstContainer
        .read(createdProjectPortfolioProvider.notifier)
        .flushPersistence();
    final secondContainer = _containerWithMemoryViewStore(null, store);
    addTearDown(secondContainer.dispose);
    await secondContainer
        .read(createdProjectPortfolioProvider.notifier)
        .hydrate();

    expect(
      secondContainer.read(projectByIdProvider(created.id))?.name,
      'Campus Renovation Phase 2',
    );
  });

  test('project portfolio view provider persists board preferences', () async {
    final store = MemoryProjectPortfolioViewSnapshotStore();
    final firstContainer = _containerWithMemoryViewStore(store);
    addTearDown(firstContainer.dispose);

    await firstContainer
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .hydrate();
    firstContainer
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setSearchQuery('warehouse');
    firstContainer
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setHealthFilter(ProjectHealth.atRisk);
    firstContainer
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setDomainReadinessFilter(ProjectDomainReadinessFilter.needsContext);
    firstContainer
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setSortOption(ProjectPortfolioSortOption.budget);
    firstContainer
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setViewPreset(ProjectPortfolioViewPreset.budgetPressure);
    firstContainer
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .setTableColumnProfile(ProjectTableColumnProfile.domainContext);
    await firstContainer
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .flushPersistence();

    final secondContainer = _containerWithMemoryViewStore(store);
    addTearDown(secondContainer.dispose);

    await secondContainer
        .read(projectPortfolioViewPreferencesProvider.notifier)
        .hydrate();

    expect(secondContainer.read(projectSearchQueryProvider), 'warehouse');
    expect(
      secondContainer.read(projectHealthFilterProvider),
      ProjectHealth.atRisk,
    );
    expect(
      secondContainer.read(projectDomainReadinessFilterProvider),
      ProjectDomainReadinessFilter.needsContext,
    );
    expect(
      secondContainer.read(projectSortProvider),
      ProjectPortfolioSortOption.budget,
    );
    expect(
      secondContainer.read(projectPortfolioViewProvider),
      ProjectPortfolioViewPreset.budgetPressure,
    );
    expect(
      secondContainer.read(projectTableColumnProfileProvider),
      ProjectTableColumnProfile.domainContext,
    );
  });
}

ProviderContainer _containerWithMemoryViewStore([
  MemoryProjectPortfolioViewSnapshotStore? store,
  MemoryProjectCreatedPortfolioSnapshotStore? createdStore,
]) {
  return ProviderContainer(
    overrides: [
      projectPortfolioViewRepositoryProvider.overrideWithValue(
        ProjectPortfolioViewRepository(
          store: store ?? MemoryProjectPortfolioViewSnapshotStore(),
        ),
      ),
      projectCreatedPortfolioRepositoryProvider.overrideWithValue(
        ProjectCreatedPortfolioRepository(
          store: createdStore ?? MemoryProjectCreatedPortfolioSnapshotStore(),
        ),
      ),
    ],
  );
}
