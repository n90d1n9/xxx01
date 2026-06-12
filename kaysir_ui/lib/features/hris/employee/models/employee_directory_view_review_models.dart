import 'employee_directory_quality_models.dart';
import 'employee_directory_table_models.dart';

enum EmployeeDirectoryViewReviewSignalPriority { critical, elevated, steady }

extension EmployeeDirectoryViewReviewSignalPriorityLabel
    on EmployeeDirectoryViewReviewSignalPriority {
  String get label {
    switch (this) {
      case EmployeeDirectoryViewReviewSignalPriority.critical:
        return 'Critical';
      case EmployeeDirectoryViewReviewSignalPriority.elevated:
        return 'Review';
      case EmployeeDirectoryViewReviewSignalPriority.steady:
        return 'Ready';
    }
  }
}

class EmployeeDirectoryViewReviewSignal {
  final String title;
  final String detail;
  final EmployeeDirectoryViewReviewSignalPriority priority;

  const EmployeeDirectoryViewReviewSignal({
    required this.title,
    required this.detail,
    required this.priority,
  });
}

class EmployeeDirectoryViewReview {
  final EmployeeDirectoryTablePreset? activePreset;
  final String? activeSavedViewName;
  final EmployeeDirectoryTableView tableView;
  final EmployeeDirectoryQualityReport qualityReport;
  final EmployeeDirectoryQualityFilter qualityFilter;
  final String searchQuery;
  final String selectedDepartment;
  final String allDepartmentsLabel;
  final bool highPerformerOnly;
  final List<EmployeeDirectoryViewReviewSignal> signals;

  const EmployeeDirectoryViewReview({
    required this.activePreset,
    required this.activeSavedViewName,
    required this.tableView,
    required this.qualityReport,
    required this.qualityFilter,
    required this.searchQuery,
    required this.selectedDepartment,
    required this.allDepartmentsLabel,
    required this.highPerformerOnly,
    required this.signals,
  });

  factory EmployeeDirectoryViewReview.fromState({
    required List<EmployeeDirectoryTablePreset> presets,
    required EmployeeDirectoryTablePresetId? activePresetId,
    required String? activeSavedViewName,
    required EmployeeDirectoryTableView tableView,
    required EmployeeDirectoryQualityReport qualityReport,
    required EmployeeDirectoryQualityFilter qualityFilter,
    required String searchQuery,
    required String selectedDepartment,
    required String allDepartmentsLabel,
    required bool highPerformerOnly,
  }) {
    final activePreset =
        presets.where((preset) {
          return preset.id == activePresetId;
        }).firstOrNull;

    final review = EmployeeDirectoryViewReview(
      activePreset: activePreset,
      activeSavedViewName: activeSavedViewName,
      tableView: tableView,
      qualityReport: qualityReport,
      qualityFilter: qualityFilter,
      searchQuery: searchQuery,
      selectedDepartment: selectedDepartment,
      allDepartmentsLabel: allDepartmentsLabel,
      highPerformerOnly: highPerformerOnly,
      signals: const [],
    );

    return EmployeeDirectoryViewReview(
      activePreset: activePreset,
      activeSavedViewName: activeSavedViewName,
      tableView: tableView,
      qualityReport: qualityReport,
      qualityFilter: qualityFilter,
      searchQuery: searchQuery,
      selectedDepartment: selectedDepartment,
      allDepartmentsLabel: allDepartmentsLabel,
      highPerformerOnly: highPerformerOnly,
      signals: _buildSignals(review),
    );
  }

  bool get isSavedView => activePreset != null || activeSavedViewName != null;

  String get viewName =>
      activePreset?.label ?? activeSavedViewName ?? 'Custom view';

  int get visibleCount => tableView.visibleCount;

  int get totalCount => tableView.totalCount;

  int get coveragePercent {
    if (totalCount == 0) return 0;
    return ((visibleCount / totalCount) * 100).round();
  }

  int get affectedVisibleCount {
    return tableView.rows.where((member) {
      return qualityReport.hasAnyIssue(member.id);
    }).length;
  }

  int get criticalVisibleCount {
    final visibleIds = tableView.rows.map((member) => member.id).toSet();
    return qualityReport.issues.where((issue) {
      return visibleIds.contains(issue.employeeId) &&
          issue.severity == EmployeeDirectoryQualitySeverity.critical;
    }).length;
  }

  int get readinessScore {
    if (visibleCount == 0) return 0;
    return (((visibleCount - affectedVisibleCount) / visibleCount) * 100)
        .round();
  }

  String get readinessLabel {
    if (visibleCount == 0) return 'No rows';
    if (criticalVisibleCount > 0) return 'Needs cleanup';
    if (affectedVisibleCount > 0) return 'Review';
    return 'Ready';
  }

  String get focusLabel {
    if (visibleCount == 0) return 'No matches';
    if (coveragePercent == 100) return 'Full roster';
    if (coveragePercent <= 30) return 'Focused cohort';
    if (coveragePercent <= 70) return 'Segmented view';
    return 'Broad view';
  }

  int get activeFilterCount {
    var count = 0;
    if (tableView.statusFilter != EmployeeDirectoryTableStatusFilter.all) {
      count += 1;
    }
    if (qualityFilter != EmployeeDirectoryQualityFilter.all) count += 1;
    if (selectedDepartment != allDepartmentsLabel) count += 1;
    if (highPerformerOnly) count += 1;
    if (searchQuery.trim().isNotEmpty) count += 1;
    return count;
  }

  String get filterStackLabel {
    if (activeFilterCount == 0) return 'No filters';
    if (activeFilterCount == 1) return '1 active filter';
    return '$activeFilterCount active filters';
  }

  String get filterStackDetail {
    final filters = <String>[];
    if (tableView.statusFilter != EmployeeDirectoryTableStatusFilter.all) {
      filters.add(tableView.statusFilter.label);
    }
    if (qualityFilter != EmployeeDirectoryQualityFilter.all) {
      filters.add(qualityFilter.label);
    }
    if (selectedDepartment != allDepartmentsLabel) {
      filters.add(selectedDepartment);
    }
    if (highPerformerOnly) filters.add('High performers');
    final normalizedQuery = searchQuery.trim();
    if (normalizedQuery.isNotEmpty) filters.add('Search "$normalizedQuery"');
    if (filters.isEmpty) return 'All directory profiles are in scope.';
    return filters.join(' / ');
  }

  String get sortLabel {
    final direction = tableView.sort.ascending ? 'ascending' : 'descending';
    return '${tableView.sort.field.label}, $direction';
  }

  String get qualityGateLabel {
    if (visibleCount == 0) return 'No rows';
    if (affectedVisibleCount == 0) return 'Clear';
    return '$affectedVisibleCount affected';
  }

  String get qualityGateDetail {
    if (visibleCount == 0) return 'Adjust filters to recover matching rows.';
    if (affectedVisibleCount == 0) {
      return 'Visible profiles have no roster quality issues.';
    }
    return '$criticalVisibleCount critical issues need cleanup before export.';
  }

  String get bulkScopeLabel {
    if (visibleCount == 0) return 'Blocked';
    if (affectedVisibleCount > 0) return 'Review first';
    if (coveragePercent == 100) return 'Roster-wide';
    return 'Scoped';
  }

  String get bulkScopeDetail {
    if (visibleCount == 0) return 'No rows available for bulk operations.';
    if (affectedVisibleCount > 0) {
      return 'Resolve data quality issues before broad updates.';
    }
    if (coveragePercent == 100) {
      return 'Bulk changes would affect the full visible roster.';
    }
    return 'Bulk changes are constrained to the active view.';
  }
}

List<EmployeeDirectoryViewReviewSignal> _buildSignals(
  EmployeeDirectoryViewReview review,
) {
  if (review.visibleCount == 0) {
    return const [
      EmployeeDirectoryViewReviewSignal(
        title: 'No matching rows',
        detail: 'Adjust filters or switch views before exporting or updating.',
        priority: EmployeeDirectoryViewReviewSignalPriority.critical,
      ),
    ];
  }

  final signals = <EmployeeDirectoryViewReviewSignal>[];

  if (!review.isSavedView) {
    signals.add(
      const EmployeeDirectoryViewReviewSignal(
        title: 'Manual view active',
        detail: 'Current filters differ from the saved table views.',
        priority: EmployeeDirectoryViewReviewSignalPriority.elevated,
      ),
    );
  }

  if (review.criticalVisibleCount > 0) {
    signals.add(
      EmployeeDirectoryViewReviewSignal(
        title: 'Critical data issues',
        detail:
            '${review.criticalVisibleCount} critical issues are visible in this view.',
        priority: EmployeeDirectoryViewReviewSignalPriority.critical,
      ),
    );
  } else if (review.affectedVisibleCount > 0) {
    signals.add(
      EmployeeDirectoryViewReviewSignal(
        title: 'Profile cleanup needed',
        detail:
            '${review.affectedVisibleCount} visible profiles have quality issues.',
        priority: EmployeeDirectoryViewReviewSignalPriority.elevated,
      ),
    );
  }

  if (review.tableView.statusFilter ==
      EmployeeDirectoryTableStatusFilter.watchlist) {
    signals.add(
      const EmployeeDirectoryViewReviewSignal(
        title: 'Watchlist review',
        detail: 'Use this view for HR follow-up and manager alignment.',
        priority: EmployeeDirectoryViewReviewSignalPriority.elevated,
      ),
    );
  }

  if (review.highPerformerOnly) {
    signals.add(
      const EmployeeDirectoryViewReviewSignal(
        title: 'Talent cohort',
        detail: 'This view is scoped to high performer records.',
        priority: EmployeeDirectoryViewReviewSignalPriority.steady,
      ),
    );
  }

  if (review.coveragePercent == 100 &&
      review.activeFilterCount == 0 &&
      review.isSavedView) {
    signals.add(
      const EmployeeDirectoryViewReviewSignal(
        title: 'Roster-wide view',
        detail: 'All employee profiles are visible in this saved view.',
        priority: EmployeeDirectoryViewReviewSignalPriority.steady,
      ),
    );
  }

  if (signals.isEmpty) {
    signals.add(
      const EmployeeDirectoryViewReviewSignal(
        title: 'View ready',
        detail: 'The active view is scoped and ready for HR operations.',
        priority: EmployeeDirectoryViewReviewSignalPriority.steady,
      ),
    );
  }

  return signals;
}
