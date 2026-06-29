import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_models.dart';
import '../models/employee_directory_quality_models.dart';
import '../models/employee_directory_table_models.dart';
import 'employee_directory_provider.dart';
import 'employee_directory_quality_provider.dart';

final employeeDirectoryTableStatusFilterProvider =
    StateProvider<EmployeeDirectoryTableStatusFilter>(
      (ref) => EmployeeDirectoryTableStatusFilter.all,
    );

final employeeDirectoryTableSortProvider =
    StateProvider<EmployeeDirectoryTableSort>(
      (ref) => EmployeeDirectoryTableSort.initial,
    );

final employeeDirectoryTablePresetsProvider =
    Provider<List<EmployeeDirectoryTablePreset>>((ref) {
      return const [
        EmployeeDirectoryTablePreset(
          id: EmployeeDirectoryTablePresetId.allEmployees,
          label: 'All employees',
          description: 'Full directory, sorted by employee name.',
        ),
        EmployeeDirectoryTablePreset(
          id: EmployeeDirectoryTablePresetId.activeStaff,
          label: 'Active staff',
          description: 'Current staff grouped for departmental review.',
          statusFilter: EmployeeDirectoryTableStatusFilter.active,
          sort: EmployeeDirectoryTableSort(
            field: EmployeeDirectoryTableSortField.department,
            ascending: true,
          ),
        ),
        EmployeeDirectoryTablePreset(
          id: EmployeeDirectoryTablePresetId.onboardingQueue,
          label: 'Onboarding queue',
          description: 'New hires ordered by latest join date.',
          statusFilter: EmployeeDirectoryTableStatusFilter.onboarding,
          sort: EmployeeDirectoryTableSort(
            field: EmployeeDirectoryTableSortField.joiningDate,
            ascending: false,
          ),
        ),
        EmployeeDirectoryTablePreset(
          id: EmployeeDirectoryTablePresetId.watchlistReview,
          label: 'Watchlist review',
          description: 'At-risk profiles with lowest rating first.',
          statusFilter: EmployeeDirectoryTableStatusFilter.watchlist,
          sort: EmployeeDirectoryTableSort(
            field: EmployeeDirectoryTableSortField.performance,
            ascending: true,
          ),
        ),
        EmployeeDirectoryTablePreset(
          id: EmployeeDirectoryTablePresetId.highPerformers,
          label: 'High performers',
          description: 'Top talent ranked by performance.',
          highPerformerOnly: true,
          sort: EmployeeDirectoryTableSort(
            field: EmployeeDirectoryTableSortField.performance,
            ascending: false,
          ),
        ),
        EmployeeDirectoryTablePreset(
          id: EmployeeDirectoryTablePresetId.jakartaHub,
          label: 'Jakarta hub',
          description: 'Profiles based in Jakarta across teams.',
          searchQuery: 'Jakarta',
          sort: EmployeeDirectoryTableSort(
            field: EmployeeDirectoryTableSortField.department,
            ascending: true,
          ),
        ),
      ];
    });

final employeeDirectoryTableActivePresetProvider =
    StateProvider<EmployeeDirectoryTablePresetId?>(
      (ref) => EmployeeDirectoryTablePresetId.allEmployees,
    );

final employeeDirectoryTablePresetControllerProvider =
    Provider<EmployeeDirectoryTablePresetController>(
      EmployeeDirectoryTablePresetController.new,
    );

final employeeDirectoryTableSelectedIdsProvider =
    StateNotifierProvider<EmployeeDirectoryTableSelectionNotifier, Set<String>>(
      (ref) => EmployeeDirectoryTableSelectionNotifier(),
    );

final employeeDirectoryTableSelectedRowsProvider =
    Provider<List<EmployeeDirectoryMember>>((ref) {
      final selectedIds = ref.watch(employeeDirectoryTableSelectedIdsProvider);
      if (selectedIds.isEmpty) return const [];

      return ref
          .watch(employeeDirectoryMembersProvider)
          .where((member) => selectedIds.contains(member.id))
          .toList();
    });

final employeeDirectoryTableLastCsvExportProvider =
    StateProvider<EmployeeDirectoryTableCsvExport?>((ref) => null);

final employeeDirectoryTableRowsProvider =
    Provider<List<EmployeeDirectoryMember>>((ref) {
      final statusFilter = ref.watch(
        employeeDirectoryTableStatusFilterProvider,
      );
      final qualityFilter = ref.watch(employeeDirectoryQualityFilterProvider);
      final qualityReport = ref.watch(employeeDirectoryQualityReportProvider);
      final sort = ref.watch(employeeDirectoryTableSortProvider);
      final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
      final rows =
          ref
              .watch(filteredEmployeeDirectoryMembersProvider)
              .where(statusFilter.matches)
              .where((member) => qualityFilter.matches(member, qualityReport))
              .toList();

      rows.sort((first, second) {
        final comparison = _compareMembers(first, second, sort.field, asOfDate);
        final sorted = sort.ascending ? comparison : -comparison;
        return sorted == 0 ? _compareText(first.name, second.name) : sorted;
      });

      return rows;
    });

final employeeDirectoryTableViewProvider = Provider<EmployeeDirectoryTableView>(
  (ref) {
    final allMembers = ref.watch(employeeDirectoryMembersProvider);
    final candidates = ref.watch(filteredEmployeeDirectoryMembersProvider);
    final rows = ref.watch(employeeDirectoryTableRowsProvider);

    return EmployeeDirectoryTableView(
      rows: rows,
      candidateCount: candidates.length,
      totalCount: allMembers.length,
      highPerformerCount:
          candidates.where((member) => member.isHighPerformer).length,
      attentionCount:
          candidates
              .where(
                (member) => member.status == EmployeeDirectoryStatus.watchlist,
              )
              .length,
      statusFilter: ref.watch(employeeDirectoryTableStatusFilterProvider),
      sort: ref.watch(employeeDirectoryTableSortProvider),
    );
  },
);

int _compareMembers(
  EmployeeDirectoryMember first,
  EmployeeDirectoryMember second,
  EmployeeDirectoryTableSortField field,
  DateTime asOfDate,
) {
  switch (field) {
    case EmployeeDirectoryTableSortField.name:
      return _compareText(first.name, second.name);
    case EmployeeDirectoryTableSortField.department:
      return _compareText(first.department, second.department);
    case EmployeeDirectoryTableSortField.performance:
      return first.performance.compareTo(second.performance);
    case EmployeeDirectoryTableSortField.tenure:
      return first
          .tenureMonths(asOfDate)
          .compareTo(second.tenureMonths(asOfDate));
    case EmployeeDirectoryTableSortField.status:
      return _statusSortIndex(
        first.status,
      ).compareTo(_statusSortIndex(second.status));
    case EmployeeDirectoryTableSortField.joiningDate:
      return first.joiningDate.compareTo(second.joiningDate);
  }
}

int _compareText(String first, String second) {
  return first.toLowerCase().compareTo(second.toLowerCase());
}

int _statusSortIndex(EmployeeDirectoryStatus status) {
  switch (status) {
    case EmployeeDirectoryStatus.active:
      return 0;
    case EmployeeDirectoryStatus.onboarding:
      return 1;
    case EmployeeDirectoryStatus.watchlist:
      return 2;
  }
}

class EmployeeDirectoryTableSelectionNotifier
    extends StateNotifier<Set<String>> {
  EmployeeDirectoryTableSelectionNotifier() : super(<String>{});

  void setSelected(String employeeId, bool selected) {
    final next = {...state};
    if (selected) {
      next.add(employeeId);
    } else {
      next.remove(employeeId);
    }
    state = next;
  }

  void selectMany(Iterable<String> employeeIds) {
    state = {...state, ...employeeIds};
  }

  void removeMany(Iterable<String> employeeIds) {
    final removals = employeeIds.toSet();
    state = state.where((employeeId) => !removals.contains(employeeId)).toSet();
  }

  void clear() {
    state = <String>{};
  }
}

class EmployeeDirectoryTablePresetController {
  final Ref _ref;

  const EmployeeDirectoryTablePresetController(this._ref);

  void apply(EmployeeDirectoryTablePreset preset) {
    _ref.read(employeeDirectorySearchQueryProvider.notifier).state =
        preset.searchQuery;
    _ref.read(employeeDirectorySelectedDepartmentProvider.notifier).state =
        preset.selectedDepartment ?? employeeDirectoryAllDepartments;
    _ref.read(employeeDirectoryHighPerformerOnlyProvider.notifier).state =
        preset.highPerformerOnly;
    _ref.read(employeeDirectoryTableStatusFilterProvider.notifier).state =
        preset.statusFilter;
    _ref.read(employeeDirectoryQualityFilterProvider.notifier).state =
        EmployeeDirectoryQualityFilter.all;
    _ref.read(employeeDirectoryTableSortProvider.notifier).state = preset.sort;
    _ref.read(employeeDirectoryTableSelectedIdsProvider.notifier).clear();
    _ref.read(employeeDirectoryTableActivePresetProvider.notifier).state =
        preset.id;
  }

  void markManualChange() {
    _ref.read(employeeDirectoryTableActivePresetProvider.notifier).state = null;
  }
}
