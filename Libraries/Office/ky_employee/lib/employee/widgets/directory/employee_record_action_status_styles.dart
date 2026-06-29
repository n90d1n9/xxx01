import 'package:flutter/material.dart';

import '../../models/employee_record_action_models.dart';

Color employeeRecordActionStatusColor(EmployeeRecordActionStatus status) {
  return switch (status) {
    EmployeeRecordActionStatus.submitted => const Color(0xFF2563EB),
    EmployeeRecordActionStatus.approved => const Color(0xFFB45309),
    EmployeeRecordActionStatus.applied => const Color(0xFF15803D),
  };
}

IconData employeeRecordActionTypeIcon(EmployeeRecordActionType type) {
  return switch (type) {
    EmployeeRecordActionType.promotion => Icons.trending_up_outlined,
    EmployeeRecordActionType.transfer => Icons.swap_horiz_outlined,
    EmployeeRecordActionType.managerChange => Icons.supervisor_account_outlined,
  };
}
