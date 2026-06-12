import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_payroll_run_launch_context_models.dart';
import 'employee_directory_roster_payroll_run_kickoff_provider.dart';

/// Exposes the active directory payroll launch context to employee run flows.
final employeePayrollRunLaunchContextProvider =
    Provider<EmployeePayrollRunLaunchContext?>((ref) {
      final records = ref.watch(
        employeeDirectoryRosterPayrollRunKickoffRecordsProvider,
      );
      if (records.isEmpty) return null;
      return EmployeePayrollRunLaunchContext.fromKickoffRecord(records.first);
    });
