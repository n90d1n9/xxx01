import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_directory_insight_models.dart';
import 'employee_directory_provider.dart';
import 'employee_directory_table_provider.dart';

final employeeDirectoryInsightsProvider = Provider<EmployeeDirectoryInsights>((
  ref,
) {
  return EmployeeDirectoryInsights.fromMembers(
    members: ref.watch(employeeDirectoryTableViewProvider).rows,
    asOfDate: ref.watch(employeeDirectoryAsOfDateProvider),
  );
});
