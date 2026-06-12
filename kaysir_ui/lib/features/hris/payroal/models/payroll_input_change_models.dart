import '../../employee/models/employee.dart';

enum PayrollInputChangeType {
  salaryChange('Salary change'),
  bonus('Bonus'),
  unpaidLeave('Unpaid leave'),
  retroAdjustment('Retro adjustment'),
  overtimePremium('Overtime premium');

  final String label;

  const PayrollInputChangeType(this.label);
}

enum PayrollInputChangeStatus {
  blocked('Blocked'),
  pending('Pending'),
  approved('Approved'),
  applied('Applied');

  final String label;

  const PayrollInputChangeStatus(this.label);
}

class PayrollInputChangeRequest {
  final String id;
  final int employeeId;
  final PayrollInputChangeType type;
  final double currentAmount;
  final double proposedAmount;
  final DateTime effectiveDate;
  final String sourceLabel;
  final String reason;
  final bool hasApprovalOwner;
  final bool hasSupportingDocument;

  const PayrollInputChangeRequest({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.currentAmount,
    required this.proposedAmount,
    required this.effectiveDate,
    required this.sourceLabel,
    required this.reason,
    required this.hasApprovalOwner,
    required this.hasSupportingDocument,
  });
}

class PayrollInputChangeLine {
  final PayrollInputChangeRequest request;
  final Employee? employee;
  final bool isApproved;
  final bool isApplied;
  final DateTime asOfDate;

  const PayrollInputChangeLine({
    required this.request,
    required this.employee,
    required this.isApproved,
    required this.isApplied,
    required this.asOfDate,
  });

  String get id => request.id;

  String get employeeName => employee?.name ?? 'Unknown employee';

  String get position => employee?.position ?? 'Employee';

  double get payrollImpact {
    return switch (request.type) {
      PayrollInputChangeType.salaryChange =>
        request.proposedAmount - request.currentAmount,
      PayrollInputChangeType.unpaidLeave => -request.proposedAmount,
      PayrollInputChangeType.bonus ||
      PayrollInputChangeType.retroAdjustment ||
      PayrollInputChangeType.overtimePremium => request.proposedAmount,
    };
  }

  List<String> get blockers {
    return [
      if (employee == null) 'Employee is unavailable',
      if (request.proposedAmount <= 0) 'Missing proposed amount',
      if (!request.hasApprovalOwner) 'Missing approval owner',
      if (!request.hasSupportingDocument) 'Missing supporting document',
      if (_isBeforeAsOfDate(request.effectiveDate, asOfDate))
        'Effective date is before payroll period',
    ];
  }

  bool get hasBlockers => blockers.isNotEmpty;

  PayrollInputChangeStatus get status {
    if (hasBlockers) return PayrollInputChangeStatus.blocked;
    if (isApplied) return PayrollInputChangeStatus.applied;
    if (isApproved) return PayrollInputChangeStatus.approved;
    return PayrollInputChangeStatus.pending;
  }

  bool get canApprove => status == PayrollInputChangeStatus.pending;

  bool get canApply => status == PayrollInputChangeStatus.approved;

  String get nextAction {
    if (hasBlockers) return blockers.first;
    if (isApplied) return 'Input change has been applied to payroll.';
    if (isApproved) return 'Apply approved input change to this payroll run.';
    return 'Review and approve input change.';
  }

  bool _isBeforeAsOfDate(DateTime value, DateTime comparison) {
    final effective = DateTime(value.year, value.month, value.day);
    final asOf = DateTime(comparison.year, comparison.month, comparison.day);
    return effective.isBefore(asOf);
  }
}

class PayrollInputChangeSummary {
  final List<PayrollInputChangeLine> lines;
  final int? selectedEmployeeId;

  const PayrollInputChangeSummary({
    required this.lines,
    required this.selectedEmployeeId,
  });

  factory PayrollInputChangeSummary.fromRequests({
    required List<PayrollInputChangeRequest> requests,
    required List<Employee> employees,
    required Set<String> approvedChangeIds,
    required Set<String> appliedChangeIds,
    required DateTime asOfDate,
    required int? selectedEmployeeId,
  }) {
    return PayrollInputChangeSummary(
      selectedEmployeeId: selectedEmployeeId,
      lines:
          requests
              .map(
                (request) => PayrollInputChangeLine(
                  request: request,
                  employee: _findEmployee(employees, request.employeeId),
                  isApproved: approvedChangeIds.contains(request.id),
                  isApplied: appliedChangeIds.contains(request.id),
                  asOfDate: asOfDate,
                ),
              )
              .toList(),
    );
  }

  List<PayrollInputChangeLine> get visibleLines {
    if (selectedEmployeeId == null) return lines;
    return lines
        .where((line) => line.request.employeeId == selectedEmployeeId)
        .toList();
  }

  int get blockedCount => _count(PayrollInputChangeStatus.blocked);

  int get pendingCount => _count(PayrollInputChangeStatus.pending);

  int get approvedCount => _count(PayrollInputChangeStatus.approved);

  int get appliedCount => _count(PayrollInputChangeStatus.applied);

  double get grossImpact {
    return lines.fold(0, (total, line) => total + line.payrollImpact);
  }

  double get appliedImpact {
    return lines
        .where((line) => line.status == PayrollInputChangeStatus.applied)
        .fold(0, (total, line) => total + line.payrollImpact);
  }

  double get readinessRate {
    if (lines.isEmpty) return 0;
    return (approvedCount + appliedCount) / lines.length;
  }

  bool get canApprove => lines.any((line) => line.canApprove);

  bool get canApply => lines.any((line) => line.canApply);

  PayrollInputChangeStatus get status {
    if (blockedCount > 0) return PayrollInputChangeStatus.blocked;
    if (pendingCount > 0) return PayrollInputChangeStatus.pending;
    if (approvedCount > 0) return PayrollInputChangeStatus.approved;
    return PayrollInputChangeStatus.applied;
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount payroll input blockers.';
    }
    if (pendingCount > 0) {
      return 'Approve $pendingCount payroll input changes.';
    }
    if (approvedCount > 0) {
      return 'Apply $approvedCount approved input changes to payroll.';
    }
    return 'All payroll input changes are applied.';
  }

  int _count(PayrollInputChangeStatus target) {
    return lines.where((line) => line.status == target).length;
  }

  static Employee? _findEmployee(List<Employee> employees, int employeeId) {
    for (final employee in employees) {
      if (employee.id == employeeId) return employee;
    }
    return null;
  }
}
