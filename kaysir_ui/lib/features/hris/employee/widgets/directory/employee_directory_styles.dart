import 'package:flutter/material.dart';

import '../../models/employee_directory_models.dart';

Color employeePerformanceColor(double performance) {
  if (performance >= 4.6) return const Color(0xFF15803D);
  if (performance >= 4.3) return const Color(0xFFD97706);
  return const Color(0xFFDC2626);
}

Color employeeDirectoryStatusColor(EmployeeDirectoryStatus status) {
  switch (status) {
    case EmployeeDirectoryStatus.active:
      return const Color(0xFF15803D);
    case EmployeeDirectoryStatus.onboarding:
      return const Color(0xFF2563EB);
    case EmployeeDirectoryStatus.watchlist:
      return const Color(0xFFDC2626);
  }
}
