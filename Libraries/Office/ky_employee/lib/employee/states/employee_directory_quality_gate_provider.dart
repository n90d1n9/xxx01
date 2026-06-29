import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_directory_quality_gate_models.dart';
import 'employee_directory_quality_provider.dart';

/// Builds the roster readiness gate from the current quality report.
final employeeDirectoryQualityGateProvider =
    Provider<EmployeeDirectoryQualityGate>((ref) {
      return EmployeeDirectoryQualityGate.fromReport(
        ref.watch(employeeDirectoryQualityReportProvider),
      );
    });
