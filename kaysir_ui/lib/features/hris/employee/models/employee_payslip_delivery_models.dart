import 'employee_payroll_run_models.dart';

enum EmployeePayslipDeliveryStatus {
  blocked('Blocked'),
  ready('Ready'),
  published('Published'),
  suppressed('Suppressed');

  final String label;

  const EmployeePayslipDeliveryStatus(this.label);
}

enum EmployeePayslipDeliveryChannel {
  selfService('Employee self-service'),
  email('Employee notification'),
  archive('Payroll archive');

  final String label;

  const EmployeePayslipDeliveryChannel(this.label);
}

enum EmployeePayslipDeliveryChannelStatus {
  blocked('Blocked'),
  queued('Queued'),
  delivered('Delivered'),
  suppressed('Suppressed');

  final String label;

  const EmployeePayslipDeliveryChannelStatus(this.label);
}

class EmployeePayslipDeliveryChannelItem {
  final String id;
  final EmployeePayslipDeliveryChannel channel;
  final EmployeePayslipDeliveryChannelStatus status;
  final String title;
  final String detail;
  final bool required;
  final int sortOrder;

  const EmployeePayslipDeliveryChannelItem({
    required this.id,
    required this.channel,
    required this.status,
    required this.title,
    required this.detail,
    required this.required,
    required this.sortOrder,
  });

  bool get isDelivered {
    return status == EmployeePayslipDeliveryChannelStatus.delivered;
  }

  bool get needsAttention {
    return status == EmployeePayslipDeliveryChannelStatus.blocked ||
        status == EmployeePayslipDeliveryChannelStatus.suppressed;
  }
}

class EmployeePayslipDeliveryProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime payDate;
  final String currencyCode;
  final EmployeePayslipDeliveryStatus status;
  final EmployeePayrollRunStatus runStatus;
  final bool payslipVisible;
  final String exportBatchId;
  final double grossEarnings;
  final double reimbursements;
  final double deductions;
  final double taxableGross;
  final double employerCost;
  final double netPay;
  final List<EmployeePayslipDeliveryChannelItem> channels;
  final String releaseOwner;
  final String releaseNote;
  final bool notifyEmployee;
  final bool archiveCopy;
  final DateTime? releasedAt;

  const EmployeePayslipDeliveryProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.periodStart,
    required this.periodEnd,
    required this.payDate,
    required this.currencyCode,
    required this.status,
    required this.runStatus,
    required this.payslipVisible,
    required this.exportBatchId,
    required this.grossEarnings,
    required this.reimbursements,
    required this.deductions,
    required this.taxableGross,
    required this.employerCost,
    required this.netPay,
    required this.channels,
    required this.releaseOwner,
    required this.releaseNote,
    required this.notifyEmployee,
    required this.archiveCopy,
    required this.releasedAt,
  });

  EmployeePayslipDeliveryProfile copyWith({
    EmployeePayslipDeliveryStatus? status,
    List<EmployeePayslipDeliveryChannelItem>? channels,
    String? releaseOwner,
    String? releaseNote,
    bool? notifyEmployee,
    bool? archiveCopy,
    DateTime? releasedAt,
  }) {
    return EmployeePayslipDeliveryProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      periodStart: periodStart,
      periodEnd: periodEnd,
      payDate: payDate,
      currencyCode: currencyCode,
      status: status ?? this.status,
      runStatus: runStatus,
      payslipVisible: payslipVisible,
      exportBatchId: exportBatchId,
      grossEarnings: grossEarnings,
      reimbursements: reimbursements,
      deductions: deductions,
      taxableGross: taxableGross,
      employerCost: employerCost,
      netPay: netPay,
      channels: channels ?? this.channels,
      releaseOwner: releaseOwner ?? this.releaseOwner,
      releaseNote: releaseNote ?? this.releaseNote,
      notifyEmployee: notifyEmployee ?? this.notifyEmployee,
      archiveCopy: archiveCopy ?? this.archiveCopy,
      releasedAt: releasedAt ?? this.releasedAt,
    );
  }

  List<EmployeePayslipDeliveryChannelItem> get sortedChannels {
    final sorted = [...channels];
    sorted.sort((a, b) {
      final sortCompare = a.sortOrder.compareTo(b.sortOrder);
      if (sortCompare != 0) return sortCompare;
      return a.title.compareTo(b.title);
    });
    return sorted;
  }

  int get blockingCount {
    if (status != EmployeePayslipDeliveryStatus.blocked) return 0;

    var count = 0;
    if (runStatus != EmployeePayrollRunStatus.exported) count++;
    if (runStatus == EmployeePayrollRunStatus.exported && !payslipVisible) {
      count++;
    }
    if (netPay <= 0) count++;
    return count == 0 ? 1 : count;
  }

  int get queuedChannelCount {
    return channels
        .where(
          (item) => item.status == EmployeePayslipDeliveryChannelStatus.queued,
        )
        .length;
  }

  int get deliveredChannelCount {
    return channels.where((item) => item.isDelivered).length;
  }

  bool get canRelease => status == EmployeePayslipDeliveryStatus.ready;

  int get attentionCount {
    if (status == EmployeePayslipDeliveryStatus.published) return 0;
    if (status == EmployeePayslipDeliveryStatus.blocked) return blockingCount;
    return 1;
  }

  String get nextAction {
    if (status == EmployeePayslipDeliveryStatus.published) {
      return 'Payslip published through $deliveredChannelCount channel${deliveredChannelCount == 1 ? '' : 's'}.';
    }
    if (runStatus != EmployeePayrollRunStatus.exported) {
      return 'Export payroll run before payslip delivery.';
    }
    if (!payslipVisible || status == EmployeePayslipDeliveryStatus.suppressed) {
      return 'Restore payslip visibility before release.';
    }
    return 'Release payslip to employee self-service.';
  }
}

class EmployeePayslipReleaseDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String owner;
  final String note;
  final bool notifyEmployee;
  final bool archiveCopy;

  const EmployeePayslipReleaseDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.owner,
    required this.note,
    required this.notifyEmployee,
    required this.archiveCopy,
  });

  EmployeePayslipReleaseDraft copyWith({
    String? owner,
    String? note,
    bool? notifyEmployee,
    bool? archiveCopy,
  }) {
    return EmployeePayslipReleaseDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      owner: owner ?? this.owner,
      note: note ?? this.note,
      notifyEmployee: notifyEmployee ?? this.notifyEmployee,
      archiveCopy: archiveCopy ?? this.archiveCopy,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (owner.trim().length < 3) {
      errors.add('Release owner is required');
    }
    if (note.trim().length < 12) {
      errors.add('Release note must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToRelease => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          owner.trim().length >= 3,
          note.trim().length >= 12,
          notifyEmployee || archiveCopy,
        ].where((item) => item).length;
    return completed / 3;
  }
}
