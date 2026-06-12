import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_table_layout_models.dart';

final employeeDirectoryTableLayoutProvider = StateNotifierProvider<
  EmployeeDirectoryTableLayoutNotifier,
  EmployeeDirectoryTableLayout
>((ref) => EmployeeDirectoryTableLayoutNotifier());

class EmployeeDirectoryTableLayoutNotifier
    extends StateNotifier<EmployeeDirectoryTableLayout> {
  EmployeeDirectoryTableLayoutNotifier()
    : super(EmployeeDirectoryTableLayout.defaults());

  void toggleColumn(EmployeeDirectoryTableColumn column) {
    state = state.toggleColumn(column);
  }

  void setDensity(EmployeeDirectoryTableDensity density) {
    state = state.copyWith(density: density);
  }

  void setLayout(EmployeeDirectoryTableLayout layout) {
    state = layout;
  }

  void reset() {
    state = EmployeeDirectoryTableLayout.defaults();
  }
}
