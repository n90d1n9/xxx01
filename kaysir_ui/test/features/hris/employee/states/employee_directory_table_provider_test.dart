import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_table_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_quality_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_table_provider.dart';

void main() {
  test('employee directory table filters rows by status', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(employeeDirectoryTableStatusFilterProvider.notifier).state =
        EmployeeDirectoryTableStatusFilter.watchlist;

    final table = container.read(employeeDirectoryTableViewProvider);

    expect(table.visibleCount, 1);
    expect(table.rows.single.name, 'David Kim');
    expect(table.candidateCount, 5);
    expect(table.attentionCount, 1);
  });

  test(
    'employee directory table sorts performance descending by default toggle',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(employeeDirectoryTableSortProvider.notifier)
          .state = container
          .read(employeeDirectoryTableSortProvider)
          .toggled(EmployeeDirectoryTableSortField.performance);

      final rows = container.read(employeeDirectoryTableRowsProvider);

      expect(rows.first.name, 'Michael Chen');
      expect(rows.last.name, 'David Kim');
    },
  );

  test('employee directory table composes with directory search filters', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(employeeDirectorySelectedDepartmentProvider.notifier).state =
        'Engineering';
    container.read(employeeDirectorySearchQueryProvider.notifier).state =
        'developer';

    final table = container.read(employeeDirectoryTableViewProvider);

    expect(table.visibleCount, 1);
    expect(table.totalCount, 5);
    expect(table.rows.single.name, 'Michael Chen');
  });

  test('employee directory table filters rows by quality issue', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
        employeeDirectoryMembersProvider.overrideWith(
          (ref) => EmployeeDirectoryNotifier([
            _member(
              id: '1',
              name: 'Sarah Johnson',
              email: 'shared@example.com',
            ),
            _member(
              id: '2',
              name: 'Maya Santoso',
              email: 'shared@example.com',
              manager: '',
            ),
            _member(id: '3', name: 'Rafi Pratama'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(employeeDirectoryQualityFilterProvider.notifier).state =
        EmployeeDirectoryQualityFilter.duplicateEmail;

    var table = container.read(employeeDirectoryTableViewProvider);

    expect(table.visibleCount, 2);
    expect(table.rows.map((employee) => employee.name), [
      'Maya Santoso',
      'Sarah Johnson',
    ]);

    container.read(employeeDirectoryQualityFilterProvider.notifier).state =
        EmployeeDirectoryQualityFilter.missingManager;
    table = container.read(employeeDirectoryTableViewProvider);

    expect(table.visibleCount, 1);
    expect(table.rows.single.name, 'Maya Santoso');
  });

  test('employee directory table selection and csv export are reusable', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(employeeDirectoryTableSelectedIdsProvider.notifier)
        .selectMany(['1', '4']);

    final selectedRows = container.read(
      employeeDirectoryTableSelectedRowsProvider,
    );
    final export = EmployeeDirectoryTableCsvExport.fromMembers(
      members: selectedRows,
      asOfDate: container.read(employeeDirectoryAsOfDateProvider),
    );

    expect(selectedRows.map((employee) => employee.name), [
      'Sarah Johnson',
      'David Kim',
    ]);
    expect(export.rowCount, 2);
    expect(export.content, contains('id,name,position,department,status'));
    expect(export.content, contains('Sarah Johnson'));
    expect(export.content, contains('David Kim'));
  });

  test('employee directory table presets apply reusable table state', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(employeeDirectoryTableSelectedIdsProvider.notifier)
        .selectMany(['1', '4']);

    final highPerformerPreset = container
        .read(employeeDirectoryTablePresetsProvider)
        .singleWhere(
          (preset) =>
              preset.id == EmployeeDirectoryTablePresetId.highPerformers,
        );
    container
        .read(employeeDirectoryTablePresetControllerProvider)
        .apply(highPerformerPreset);

    final table = container.read(employeeDirectoryTableViewProvider);

    expect(
      container.read(employeeDirectoryTableActivePresetProvider),
      EmployeeDirectoryTablePresetId.highPerformers,
    );
    expect(container.read(employeeDirectoryHighPerformerOnlyProvider), isTrue);
    expect(table.visibleCount, 3);
    expect(
      container.read(employeeDirectoryQualityFilterProvider),
      EmployeeDirectoryQualityFilter.all,
    );
    expect(table.rows.map((employee) => employee.name), [
      'Michael Chen',
      'Sarah Johnson',
      'Olivia Wilson',
    ]);
    expect(container.read(employeeDirectoryTableSelectedIdsProvider), isEmpty);
  });

  test(
    'employee directory table preset manual marker clears active preset',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(employeeDirectoryTableActivePresetProvider),
        EmployeeDirectoryTablePresetId.allEmployees,
      );

      container
          .read(employeeDirectoryTablePresetControllerProvider)
          .markManualChange();

      expect(
        container.read(employeeDirectoryTableActivePresetProvider),
        isNull,
      );
    },
  );
}

EmployeeDirectoryMember _member({
  required String id,
  required String name,
  String email = 'person@example.com',
  String manager = 'Emma Rodriguez',
}) {
  return EmployeeDirectoryMember(
    id: id,
    name: name,
    position: 'HR Analyst',
    department: 'People Operations',
    avatarUrl: 'https://example.com/avatar.png',
    email: email,
    phone: '+62 812 0000 0000',
    joiningDate: DateTime(2024, 1, 1),
    performance: 4.4,
    location: 'Jakarta',
    manager: manager,
    status: EmployeeDirectoryStatus.active,
  );
}
