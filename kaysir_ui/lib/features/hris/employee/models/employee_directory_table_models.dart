import 'employee_directory_models.dart';

enum EmployeeDirectoryTableStatusFilter { all, active, onboarding, watchlist }

extension EmployeeDirectoryTableStatusFilterLabel
    on EmployeeDirectoryTableStatusFilter {
  String get label {
    switch (this) {
      case EmployeeDirectoryTableStatusFilter.all:
        return 'All statuses';
      case EmployeeDirectoryTableStatusFilter.active:
        return EmployeeDirectoryStatus.active.label;
      case EmployeeDirectoryTableStatusFilter.onboarding:
        return EmployeeDirectoryStatus.onboarding.label;
      case EmployeeDirectoryTableStatusFilter.watchlist:
        return EmployeeDirectoryStatus.watchlist.label;
    }
  }

  bool matches(EmployeeDirectoryMember member) {
    switch (this) {
      case EmployeeDirectoryTableStatusFilter.all:
        return true;
      case EmployeeDirectoryTableStatusFilter.active:
        return member.status == EmployeeDirectoryStatus.active;
      case EmployeeDirectoryTableStatusFilter.onboarding:
        return member.status == EmployeeDirectoryStatus.onboarding;
      case EmployeeDirectoryTableStatusFilter.watchlist:
        return member.status == EmployeeDirectoryStatus.watchlist;
    }
  }
}

enum EmployeeDirectoryTableSortField {
  name,
  department,
  performance,
  tenure,
  status,
  joiningDate,
}

extension EmployeeDirectoryTableSortFieldLabel
    on EmployeeDirectoryTableSortField {
  String get label {
    switch (this) {
      case EmployeeDirectoryTableSortField.name:
        return 'Employee';
      case EmployeeDirectoryTableSortField.department:
        return 'Department';
      case EmployeeDirectoryTableSortField.performance:
        return 'Performance';
      case EmployeeDirectoryTableSortField.tenure:
        return 'Tenure';
      case EmployeeDirectoryTableSortField.status:
        return 'Status';
      case EmployeeDirectoryTableSortField.joiningDate:
        return 'Join date';
    }
  }

  bool get defaultAscending {
    switch (this) {
      case EmployeeDirectoryTableSortField.performance:
      case EmployeeDirectoryTableSortField.tenure:
      case EmployeeDirectoryTableSortField.joiningDate:
        return false;
      case EmployeeDirectoryTableSortField.name:
      case EmployeeDirectoryTableSortField.department:
      case EmployeeDirectoryTableSortField.status:
        return true;
    }
  }
}

class EmployeeDirectoryTableSort {
  final EmployeeDirectoryTableSortField field;
  final bool ascending;

  const EmployeeDirectoryTableSort({
    required this.field,
    required this.ascending,
  });

  static const initial = EmployeeDirectoryTableSort(
    field: EmployeeDirectoryTableSortField.name,
    ascending: true,
  );

  EmployeeDirectoryTableSort toggled(
    EmployeeDirectoryTableSortField nextField,
  ) {
    if (field == nextField) {
      return EmployeeDirectoryTableSort(
        field: nextField,
        ascending: !ascending,
      );
    }

    return EmployeeDirectoryTableSort(
      field: nextField,
      ascending: nextField.defaultAscending,
    );
  }
}

enum EmployeeDirectoryTablePresetId {
  allEmployees,
  activeStaff,
  onboardingQueue,
  watchlistReview,
  highPerformers,
  jakartaHub,
}

class EmployeeDirectoryTablePreset {
  final EmployeeDirectoryTablePresetId id;
  final String label;
  final String description;
  final String searchQuery;
  final String? selectedDepartment;
  final bool highPerformerOnly;
  final EmployeeDirectoryTableStatusFilter statusFilter;
  final EmployeeDirectoryTableSort sort;

  const EmployeeDirectoryTablePreset({
    required this.id,
    required this.label,
    required this.description,
    this.searchQuery = '',
    this.selectedDepartment,
    this.highPerformerOnly = false,
    this.statusFilter = EmployeeDirectoryTableStatusFilter.all,
    this.sort = EmployeeDirectoryTableSort.initial,
  });
}

class EmployeeDirectoryTableView {
  final List<EmployeeDirectoryMember> rows;
  final int candidateCount;
  final int totalCount;
  final int highPerformerCount;
  final int attentionCount;
  final EmployeeDirectoryTableStatusFilter statusFilter;
  final EmployeeDirectoryTableSort sort;

  const EmployeeDirectoryTableView({
    required this.rows,
    required this.candidateCount,
    required this.totalCount,
    required this.highPerformerCount,
    required this.attentionCount,
    required this.statusFilter,
    required this.sort,
  });

  int get visibleCount => rows.length;
}

class EmployeeDirectoryTableCsvExport {
  final int rowCount;
  final String content;

  const EmployeeDirectoryTableCsvExport({
    required this.rowCount,
    required this.content,
  });

  factory EmployeeDirectoryTableCsvExport.fromMembers({
    required List<EmployeeDirectoryMember> members,
    required DateTime asOfDate,
  }) {
    final lines = [
      [
        'id',
        'name',
        'position',
        'department',
        'status',
        'performance',
        'tenure_months',
        'manager',
        'location',
        'email',
        'phone',
      ].join(','),
      ...members.map(
        (member) => [
          member.id,
          member.name,
          member.position,
          member.department,
          member.status.label,
          member.performance.toStringAsFixed(1),
          member.tenureMonths(asOfDate).toString(),
          member.manager,
          member.location,
          member.email,
          member.phone,
        ].map(_escapeCsv).join(','),
      ),
    ];

    return EmployeeDirectoryTableCsvExport(
      rowCount: members.length,
      content: lines.join('\n'),
    );
  }
}

String _escapeCsv(String value) {
  final needsEscaping =
      value.contains(',') || value.contains('"') || value.contains('\n');
  if (!needsEscaping) return value;
  return '"${value.replaceAll('"', '""')}"';
}
