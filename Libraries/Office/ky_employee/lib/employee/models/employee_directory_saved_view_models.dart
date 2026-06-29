import 'employee_directory_quality_models.dart';
import 'employee_directory_table_layout_models.dart';
import 'employee_directory_table_models.dart';

class EmployeeDirectorySavedView {
  final String id;
  final String name;
  final String description;
  final String searchQuery;
  final String selectedDepartment;
  final bool highPerformerOnly;
  final EmployeeDirectoryTableStatusFilter statusFilter;
  final EmployeeDirectoryQualityFilter qualityFilter;
  final EmployeeDirectoryTableSort sort;
  final EmployeeDirectoryTableLayout layout;
  final bool pinned;
  final DateTime capturedAt;

  const EmployeeDirectorySavedView({
    required this.id,
    required this.name,
    required this.description,
    required this.searchQuery,
    required this.selectedDepartment,
    required this.highPerformerOnly,
    required this.statusFilter,
    required this.qualityFilter,
    required this.sort,
    required this.layout,
    required this.pinned,
    required this.capturedAt,
  });

  int filterCount(String allDepartmentsLabel) {
    var count = 0;
    if (searchQuery.trim().isNotEmpty) count += 1;
    if (selectedDepartment != allDepartmentsLabel) count += 1;
    if (highPerformerOnly) count += 1;
    if (statusFilter != EmployeeDirectoryTableStatusFilter.all) count += 1;
    if (qualityFilter != EmployeeDirectoryQualityFilter.all) count += 1;
    return count;
  }

  String filterSummary(String allDepartmentsLabel) {
    final filters = <String>[];
    if (statusFilter != EmployeeDirectoryTableStatusFilter.all) {
      filters.add(statusFilter.label);
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
    if (filters.isEmpty) return 'All directory profiles';
    return filters.join(' / ');
  }

  String get columnSummary {
    return '${layout.visibleColumnCount} columns, ${layout.density.label.toLowerCase()}';
  }

  String get sortSummary {
    final direction = sort.ascending ? 'ascending' : 'descending';
    return '${sort.field.label}, $direction';
  }
}

class EmployeeDirectorySavedViewDraft {
  final String name;
  final String description;
  final bool pinned;

  const EmployeeDirectorySavedViewDraft({
    this.name = '',
    this.description = '',
    this.pinned = false,
  });

  String get trimmedName => name.trim();

  String get trimmedDescription => description.trim();

  bool get hasInput {
    return trimmedName.isNotEmpty || trimmedDescription.isNotEmpty || pinned;
  }

  List<String> validationErrors(List<EmployeeDirectorySavedView> savedViews) {
    final errors = <String>[];
    final normalizedName = trimmedName.toLowerCase();

    if (trimmedName.isEmpty) {
      errors.add('Add a saved view name.');
    } else if (trimmedName.length < 3) {
      errors.add('Use at least 3 characters for the saved view name.');
    }

    final duplicateName = savedViews.any((view) {
      return view.name.trim().toLowerCase() == normalizedName;
    });
    if (duplicateName) {
      errors.add('Saved view name already exists.');
    }

    return errors;
  }

  EmployeeDirectorySavedViewDraft copyWith({
    String? name,
    String? description,
    bool? pinned,
  }) {
    return EmployeeDirectorySavedViewDraft(
      name: name ?? this.name,
      description: description ?? this.description,
      pinned: pinned ?? this.pinned,
    );
  }
}

class EmployeeDirectorySavedViewSaveResult {
  final EmployeeDirectorySavedView? view;
  final List<String> errors;

  const EmployeeDirectorySavedViewSaveResult({
    required this.view,
    required this.errors,
  });

  const EmployeeDirectorySavedViewSaveResult.success(
    EmployeeDirectorySavedView savedView,
  ) : view = savedView,
      errors = const [];

  const EmployeeDirectorySavedViewSaveResult.failure(List<String> failures)
    : view = null,
      errors = failures;

  bool get isSuccess => view != null;
}
