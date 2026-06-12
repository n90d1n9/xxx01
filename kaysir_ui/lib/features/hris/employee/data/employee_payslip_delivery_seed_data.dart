import '../models/employee_payslip_delivery_models.dart';
import '../models/employee_payroll_run_models.dart';

EmployeePayslipDeliveryProfile buildEmployeePayslipDeliveryProfile({
  required EmployeePayrollRunProfile payrollRun,
}) {
  final status = _statusFor(payrollRun);

  return EmployeePayslipDeliveryProfile(
    employeeId: payrollRun.employeeId,
    employeeName: payrollRun.employeeName,
    asOfDate: payrollRun.asOfDate,
    periodStart: payrollRun.periodStart,
    periodEnd: payrollRun.periodEnd,
    payDate: payrollRun.payDate,
    currencyCode: payrollRun.currencyCode,
    status: status,
    runStatus: payrollRun.status,
    payslipVisible: payrollRun.payslipVisible,
    exportBatchId: payrollRun.exportBatchId,
    grossEarnings: payrollRun.grossEarnings,
    reimbursements: payrollRun.reimbursements,
    deductions: payrollRun.deductions,
    taxableGross: payrollRun.taxableGross,
    employerCost: payrollRun.employerCost,
    netPay: payrollRun.netPay,
    channels: buildEmployeePayslipDeliveryChannels(
      status: status,
      notifyEmployee: true,
      archiveCopy: true,
    ),
    releaseOwner: '',
    releaseNote: '',
    notifyEmployee: true,
    archiveCopy: true,
    releasedAt: null,
  );
}

EmployeePayslipReleaseDraft buildEmployeePayslipReleaseDraft({
  required EmployeePayrollRunProfile payrollRun,
}) {
  return EmployeePayslipReleaseDraft(
    employeeId: payrollRun.employeeId,
    employeeName: payrollRun.employeeName,
    asOfDate: payrollRun.asOfDate,
    owner:
        payrollRun.reviewer.trim().isEmpty
            ? 'Payroll Operations'
            : payrollRun.reviewer,
    note: '',
    notifyEmployee: true,
    archiveCopy: true,
  );
}

List<EmployeePayslipDeliveryChannelItem> buildEmployeePayslipDeliveryChannels({
  required EmployeePayslipDeliveryStatus status,
  required bool notifyEmployee,
  required bool archiveCopy,
}) {
  final channelStatus = _channelStatusFor(status);
  final items = <EmployeePayslipDeliveryChannelItem>[
    EmployeePayslipDeliveryChannelItem(
      id: 'payslip-self-service',
      channel: EmployeePayslipDeliveryChannel.selfService,
      status: channelStatus,
      title: 'Employee self-service',
      detail: _detailFor(
        status,
        queued: 'Payslip is staged for the employee portal.',
        delivered: 'Payslip is visible in employee self-service.',
      ),
      required: true,
      sortOrder: 10,
    ),
  ];

  if (notifyEmployee) {
    items.add(
      EmployeePayslipDeliveryChannelItem(
        id: 'payslip-email',
        channel: EmployeePayslipDeliveryChannel.email,
        status: channelStatus,
        title: 'Employee notification',
        detail: _detailFor(
          status,
          queued: 'Employee will receive a release notification.',
          delivered: 'Release notification has been queued for delivery.',
        ),
        required: false,
        sortOrder: 20,
      ),
    );
  }

  if (archiveCopy) {
    items.add(
      EmployeePayslipDeliveryChannelItem(
        id: 'payslip-archive',
        channel: EmployeePayslipDeliveryChannel.archive,
        status: channelStatus,
        title: 'Payroll archive',
        detail: _detailFor(
          status,
          queued: 'Payroll copy is staged for archive retention.',
          delivered: 'Payroll copy has been retained in the archive.',
        ),
        required: false,
        sortOrder: 30,
      ),
    );
  }

  return items;
}

EmployeePayslipDeliveryStatus _statusFor(EmployeePayrollRunProfile payrollRun) {
  if (payrollRun.status != EmployeePayrollRunStatus.exported) {
    return EmployeePayslipDeliveryStatus.blocked;
  }
  if (!payrollRun.payslipVisible) {
    return EmployeePayslipDeliveryStatus.suppressed;
  }
  return EmployeePayslipDeliveryStatus.ready;
}

EmployeePayslipDeliveryChannelStatus _channelStatusFor(
  EmployeePayslipDeliveryStatus status,
) {
  return switch (status) {
    EmployeePayslipDeliveryStatus.blocked =>
      EmployeePayslipDeliveryChannelStatus.blocked,
    EmployeePayslipDeliveryStatus.ready =>
      EmployeePayslipDeliveryChannelStatus.queued,
    EmployeePayslipDeliveryStatus.published =>
      EmployeePayslipDeliveryChannelStatus.delivered,
    EmployeePayslipDeliveryStatus.suppressed =>
      EmployeePayslipDeliveryChannelStatus.suppressed,
  };
}

String _detailFor(
  EmployeePayslipDeliveryStatus status, {
  required String queued,
  required String delivered,
}) {
  return switch (status) {
    EmployeePayslipDeliveryStatus.blocked =>
      'Payroll run must be exported before this channel can be prepared.',
    EmployeePayslipDeliveryStatus.ready => queued,
    EmployeePayslipDeliveryStatus.published => delivered,
    EmployeePayslipDeliveryStatus.suppressed =>
      'Payslip visibility is suppressed for this employee.',
  };
}
