import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_quality_models.dart';
import 'employee_directory_provider.dart';

final employeeDirectoryQualityFilterProvider =
    StateProvider<EmployeeDirectoryQualityFilter>(
      (ref) => EmployeeDirectoryQualityFilter.all,
    );

final employeeDirectoryQualityReportProvider =
    Provider<EmployeeDirectoryQualityReport>((ref) {
      return EmployeeDirectoryQualityReport.fromMembers(
        members: ref.watch(employeeDirectoryMembersProvider),
        asOfDate: ref.watch(employeeDirectoryAsOfDateProvider),
      );
    });
