import 'package:flutter/material.dart';

import '../../models/employee_payslip_delivery_models.dart';

Color employeePayslipDeliveryStatusColor(EmployeePayslipDeliveryStatus status) {
  return switch (status) {
    EmployeePayslipDeliveryStatus.blocked => const Color(0xFFB91C1C),
    EmployeePayslipDeliveryStatus.ready => const Color(0xFF2563EB),
    EmployeePayslipDeliveryStatus.published => const Color(0xFF15803D),
    EmployeePayslipDeliveryStatus.suppressed => const Color(0xFFB45309),
  };
}

Color employeePayslipChannelStatusColor(
  EmployeePayslipDeliveryChannelStatus status,
) {
  return switch (status) {
    EmployeePayslipDeliveryChannelStatus.blocked => const Color(0xFFB91C1C),
    EmployeePayslipDeliveryChannelStatus.queued => const Color(0xFF2563EB),
    EmployeePayslipDeliveryChannelStatus.delivered => const Color(0xFF15803D),
    EmployeePayslipDeliveryChannelStatus.suppressed => const Color(0xFFB45309),
  };
}

IconData employeePayslipChannelIcon(EmployeePayslipDeliveryChannel channel) {
  return switch (channel) {
    EmployeePayslipDeliveryChannel.selfService => Icons.badge_outlined,
    EmployeePayslipDeliveryChannel.email => Icons.mark_email_unread_outlined,
    EmployeePayslipDeliveryChannel.archive => Icons.inventory_2_outlined,
  };
}
