import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_directory_quality_plan_models.dart';
import 'employee_directory_quality_provider.dart';

/// Derives the roster cleanup plan from the live directory quality report.
final employeeDirectoryQualityFixPlanProvider =
    Provider<EmployeeDirectoryQualityFixPlan>((ref) {
      return EmployeeDirectoryQualityFixPlan.fromReport(
        ref.watch(employeeDirectoryQualityReportProvider),
      );
    });
