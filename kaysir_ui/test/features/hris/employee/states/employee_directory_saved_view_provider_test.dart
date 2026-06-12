import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_table_layout_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_table_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_quality_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_saved_view_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_table_layout_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_table_provider.dart';

void main() {
  test('employee directory saved views capture current table state', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(employeeDirectorySearchQueryProvider.notifier).state =
        'Jakarta';
    container.read(employeeDirectoryTableStatusFilterProvider.notifier).state =
        EmployeeDirectoryTableStatusFilter.watchlist;
    container
        .read(employeeDirectoryTableLayoutProvider.notifier)
        .toggleColumn(EmployeeDirectoryTableColumn.manager);
    container
        .read(employeeDirectoryTableLayoutProvider.notifier)
        .setDensity(EmployeeDirectoryTableDensity.compact);
    container
        .read(employeeDirectorySavedViewDraftProvider.notifier)
        .setName('Jakarta watchlist');
    container
        .read(employeeDirectorySavedViewDraftProvider.notifier)
        .setDescription('Daily People Ops review');
    container
        .read(employeeDirectorySavedViewDraftProvider.notifier)
        .setPinned(true);

    final result =
        container
            .read(employeeDirectorySavedViewControllerProvider)
            .saveCurrentView();

    expect(result.isSuccess, isTrue);
    expect(result.view!.name, 'Jakarta watchlist');
    expect(result.view!.description, 'Daily People Ops review');
    expect(result.view!.searchQuery, 'Jakarta');
    expect(
      result.view!.statusFilter,
      EmployeeDirectoryTableStatusFilter.watchlist,
    );
    expect(result.view!.pinned, isTrue);
    expect(result.view!.layout.density, EmployeeDirectoryTableDensity.compact);
    expect(
      result.view!.layout.isVisible(EmployeeDirectoryTableColumn.manager),
      isFalse,
    );
    expect(container.read(employeeDirectorySavedViewsProvider), hasLength(1));
    expect(
      container.read(employeeDirectoryActiveSavedViewIdProvider),
      result.view!.id,
    );
    expect(container.read(employeeDirectoryTableActivePresetProvider), isNull);
    expect(
      container.read(employeeDirectorySavedViewDraftProvider).hasInput,
      isFalse,
    );
  });

  test('employee directory saved views apply captured state', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(employeeDirectorySelectedDepartmentProvider.notifier).state =
        'Design';
    container.read(employeeDirectoryQualityFilterProvider.notifier).state =
        EmployeeDirectoryQualityFilter.incompleteProfile;
    container
        .read(employeeDirectoryTableSelectedIdsProvider.notifier)
        .selectMany(['1', '4']);
    container
        .read(employeeDirectorySavedViewDraftProvider.notifier)
        .setName('Design cleanup');

    final view =
        container
            .read(employeeDirectorySavedViewControllerProvider)
            .saveCurrentView()
            .view!;

    container.read(employeeDirectorySelectedDepartmentProvider.notifier).state =
        employeeDirectoryAllDepartments;
    container.read(employeeDirectoryQualityFilterProvider.notifier).state =
        EmployeeDirectoryQualityFilter.all;
    container
        .read(employeeDirectoryTableSelectedIdsProvider.notifier)
        .selectMany(['2']);

    container.read(employeeDirectorySavedViewControllerProvider).apply(view);

    expect(
      container.read(employeeDirectorySelectedDepartmentProvider),
      'Design',
    );
    expect(
      container.read(employeeDirectoryQualityFilterProvider),
      EmployeeDirectoryQualityFilter.incompleteProfile,
    );
    expect(container.read(employeeDirectoryTableActivePresetProvider), isNull);
    expect(container.read(employeeDirectoryActiveSavedViewIdProvider), view.id);
    expect(container.read(employeeDirectoryTableSelectedIdsProvider), isEmpty);
  });

  test('employee directory saved views validate duplicate names', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final draft = container.read(
      employeeDirectorySavedViewDraftProvider.notifier,
    );
    draft.setName('Payroll review');
    expect(
      container
          .read(employeeDirectorySavedViewControllerProvider)
          .saveCurrentView()
          .isSuccess,
      isTrue,
    );

    draft.setName('Payroll review');
    final result =
        container
            .read(employeeDirectorySavedViewControllerProvider)
            .saveCurrentView();

    expect(result.isSuccess, isFalse);
    expect(result.errors, contains('Saved view name already exists.'));
  });
}
