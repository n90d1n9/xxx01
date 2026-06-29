import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_directory_view_review_models.dart';
import 'employee_directory_provider.dart';
import 'employee_directory_quality_provider.dart';
import 'employee_directory_saved_view_provider.dart';
import 'employee_directory_table_provider.dart';

final employeeDirectoryViewReviewProvider = Provider<
  EmployeeDirectoryViewReview
>((ref) {
  return EmployeeDirectoryViewReview.fromState(
    presets: ref.watch(employeeDirectoryTablePresetsProvider),
    activePresetId: ref.watch(employeeDirectoryTableActivePresetProvider),
    activeSavedViewName:
        ref.watch(employeeDirectoryActiveSavedViewProvider)?.name,
    tableView: ref.watch(employeeDirectoryTableViewProvider),
    qualityReport: ref.watch(employeeDirectoryQualityReportProvider),
    qualityFilter: ref.watch(employeeDirectoryQualityFilterProvider),
    searchQuery: ref.watch(employeeDirectorySearchQueryProvider),
    selectedDepartment: ref.watch(employeeDirectorySelectedDepartmentProvider),
    allDepartmentsLabel: employeeDirectoryAllDepartments,
    highPerformerOnly: ref.watch(employeeDirectoryHighPerformerOnlyProvider),
  );
});
