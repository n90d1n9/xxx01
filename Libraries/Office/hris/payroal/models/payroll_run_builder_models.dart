import '../../employee/models/employee.dart';
import 'payroll_detail.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_period_models.dart';

enum PayrollRunScope {
  allEmployees('All employees'),
  salariedOnly('Salaried only'),
  reviewOnly('Review only');

  final String label;

  const PayrollRunScope(this.label);
}

class PayrollRunBuilderDraft {
  final String periodId;
  final String label;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime payDate;
  final PayrollRunScope scope;
  final String notes;

  const PayrollRunBuilderDraft({
    required this.periodId,
    required this.label,
    required this.periodStart,
    required this.periodEnd,
    required this.payDate,
    required this.scope,
    required this.notes,
  });

  factory PayrollRunBuilderDraft.fromPeriod(PayrollRunPeriod period) {
    final start = DateTime(period.asOfDate.year, period.asOfDate.month);
    final end = period.payDate.subtract(const Duration(days: 1));
    return PayrollRunBuilderDraft(
      periodId: period.id,
      label: period.label,
      periodStart: start,
      periodEnd: end,
      payDate: period.payDate,
      scope: PayrollRunScope.allEmployees,
      notes: 'Prepare payroll run from active HRIS employee population.',
    );
  }

  PayrollRunBuilderDraft copyWith({
    String? periodId,
    String? label,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? payDate,
    PayrollRunScope? scope,
    String? notes,
  }) {
    return PayrollRunBuilderDraft(
      periodId: periodId ?? this.periodId,
      label: label ?? this.label,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      payDate: payDate ?? this.payDate,
      scope: scope ?? this.scope,
      notes: notes ?? this.notes,
    );
  }

  List<String> get validationErrors {
    return [
      if (validateLabel(label) != null) validateLabel(label)!,
      if (validatePeriodEnd(periodStart, periodEnd) != null)
        validatePeriodEnd(periodStart, periodEnd)!,
      if (validatePayDate(periodEnd, payDate) != null)
        validatePayDate(periodEnd, payDate)!,
      if (validateNotes(notes) != null) validateNotes(notes)!,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final complete =
        [
          validateLabel(label) == null,
          validatePeriodEnd(periodStart, periodEnd) == null,
          validatePayDate(periodEnd, payDate) == null,
          validateNotes(notes) == null,
        ].where((isComplete) => isComplete).length;
    return complete / 4;
  }

  PayrollRunBuildRequest toRequest({
    required String id,
    required DateTime createdAt,
    required List<PayrollRunBuildArtifact> artifacts,
  }) {
    return PayrollRunBuildRequest(
      id: id,
      periodId: periodId,
      label: label.trim(),
      periodStart: periodStart,
      periodEnd: periodEnd,
      payDate: payDate,
      scope: scope,
      notes: notes.trim(),
      createdAt: createdAt,
      artifacts: artifacts,
    );
  }

  static String? validateLabel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a payroll run label';
    }
    return null;
  }

  static String? validatePeriodEnd(DateTime periodStart, DateTime periodEnd) {
    if (!periodEnd.isAfter(periodStart)) {
      return 'Period end must be after period start';
    }
    return null;
  }

  static String? validatePayDate(DateTime periodEnd, DateTime payDate) {
    if (payDate.isBefore(periodEnd)) {
      return 'Pay date must be on or after the period end';
    }
    return null;
  }

  static String? validateNotes(String? value) {
    if (value == null || value.trim().length < 12) {
      return 'Please enter preparation notes';
    }
    return null;
  }
}

class PayrollRunBuildRequest {
  final String id;
  final String periodId;
  final String label;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime payDate;
  final PayrollRunScope scope;
  final String notes;
  final DateTime createdAt;
  final List<PayrollRunBuildArtifact> artifacts;
  final PayrollRunBuildStatus status;

  const PayrollRunBuildRequest({
    required this.id,
    required this.periodId,
    required this.label,
    required this.periodStart,
    required this.periodEnd,
    required this.payDate,
    required this.scope,
    required this.notes,
    required this.createdAt,
    required this.artifacts,
    this.status = PayrollRunBuildStatus.draft,
  });

  bool get isReadyForApproval {
    return status == PayrollRunBuildStatus.draft &&
        artifacts.every((artifact) => artifact.isReady);
  }

  bool get canActivate => status == PayrollRunBuildStatus.approved;

  PayrollRunBuildRequest copyWith({PayrollRunBuildStatus? status}) {
    return PayrollRunBuildRequest(
      id: id,
      periodId: periodId,
      label: label,
      periodStart: periodStart,
      periodEnd: periodEnd,
      payDate: payDate,
      scope: scope,
      notes: notes,
      createdAt: createdAt,
      artifacts: artifacts,
      status: status ?? this.status,
    );
  }
}

enum PayrollRunBuildStatus {
  draft('Draft'),
  approved('Approved'),
  activated('Activated');

  final String label;

  const PayrollRunBuildStatus(this.label);
}

enum PayrollRunBuildArtifactStatus {
  ready('Ready'),
  blocked('Blocked');

  final String label;

  const PayrollRunBuildArtifactStatus(this.label);
}

class PayrollRunBuildArtifact {
  final String id;
  final String title;
  final String owner;
  final String detail;
  final PayrollRunBuildArtifactStatus status;

  const PayrollRunBuildArtifact({
    required this.id,
    required this.title,
    required this.owner,
    required this.detail,
    required this.status,
  });

  bool get isReady => status == PayrollRunBuildArtifactStatus.ready;
}

class PayrollActiveRunPlanSummary {
  final PayrollRunBuildRequest? request;
  final String periodLabel;
  final String nextAction;

  const PayrollActiveRunPlanSummary({
    required this.request,
    required this.periodLabel,
    required this.nextAction,
  });

  factory PayrollActiveRunPlanSummary.fromPeriod({
    required PayrollRunPeriod period,
    required List<PayrollRunBuildRequest> requests,
  }) {
    PayrollRunBuildRequest? active;
    for (final request in requests) {
      if (request.status == PayrollRunBuildStatus.activated &&
          request.periodId == period.id) {
        active = request;
        break;
      }
    }
    return PayrollActiveRunPlanSummary(
      request: active,
      periodLabel: period.label,
      nextAction:
          active == null
              ? 'Activate a payroll run plan for ${period.label} before final payroll preparation.'
              : '${active.label} is active for payroll preparation.',
    );
  }

  bool get hasActivePlan => request != null;

  int get readyArtifactCount {
    return request?.artifacts.where((artifact) => artifact.isReady).length ?? 0;
  }

  int get artifactCount => request?.artifacts.length ?? 0;
}

class PayrollRunBuilderPreview {
  final PayrollRunBuilderDraft draft;
  final List<Employee> includedEmployees;
  final List<PayrollRunReadinessItem> readinessItems;
  final int excludedEmployeeCount;
  final double estimatedGross;
  final double estimatedNet;
  final double estimatedDeductions;
  final String nextAction;

  const PayrollRunBuilderPreview({
    required this.draft,
    required this.includedEmployees,
    required this.readinessItems,
    required this.excludedEmployeeCount,
    required this.estimatedGross,
    required this.estimatedNet,
    required this.estimatedDeductions,
    required this.nextAction,
  });

  factory PayrollRunBuilderPreview.fromDraft({
    required PayrollRunBuilderDraft draft,
    required List<Employee> employees,
    required List<PayrollPaymentProfile> paymentProfiles,
  }) {
    final included =
        employees.where((employee) {
          final salary = employee.salary ?? 0;
          return switch (draft.scope) {
            PayrollRunScope.allEmployees => true,
            PayrollRunScope.salariedOnly => salary > 0,
            PayrollRunScope.reviewOnly =>
              salary <= 0 || employee.department == null,
          };
        }).toList();

    var gross = 0.0;
    var net = 0.0;
    var deductions = 0.0;
    for (final employee in included) {
      final details = PayrollDetails.fromSalary(employee.salary ?? 0);
      gross += details.grossSalary;
      net += details.netSalary;
      deductions += details.totalDeductions;
    }

    final excludedCount = employees.length - included.length;
    final paymentProfileByEmployeeId = {
      for (final profile in paymentProfiles) profile.employeeId: profile,
    };
    final missingSalaryCount =
        included.where((employee) => (employee.salary ?? 0) <= 0).length;
    final missingDepartmentCount =
        included
            .where((employee) => (employee.department ?? '').trim().isEmpty)
            .length;
    final missingPaymentProfileCount =
        included
            .where(
              (employee) =>
                  paymentProfileByEmployeeId[employee.id]?.hasDestination !=
                  true,
            )
            .length;
    final inactiveCount =
        included.where((employee) => !employee.isActive).length;
    final readinessItems = [
      PayrollRunReadinessItem(
        id: 'salary',
        label: 'Salary setup',
        readyCount: included.length - missingSalaryCount,
        requiredCount: included.length,
        blockerLabel: '$missingSalaryCount employees missing salary setup',
      ),
      PayrollRunReadinessItem(
        id: 'cost-center',
        label: 'Cost center coverage',
        readyCount: included.length - missingDepartmentCount,
        requiredCount: included.length,
        blockerLabel: '$missingDepartmentCount employees missing department',
      ),
      PayrollRunReadinessItem(
        id: 'payment-profile',
        label: 'Payment profile',
        readyCount: included.length - missingPaymentProfileCount,
        requiredCount: included.length,
        blockerLabel:
            '$missingPaymentProfileCount employees missing payment destination',
      ),
      PayrollRunReadinessItem(
        id: 'active-employee',
        label: 'Active employee status',
        readyCount: included.length - inactiveCount,
        requiredCount: included.length,
        blockerLabel: '$inactiveCount inactive employees in scope',
      ),
    ];
    PayrollRunReadinessItem? blocker;
    for (final item in readinessItems) {
      if (!item.isReady) {
        blocker = item;
        break;
      }
    }
    final nextAction =
        included.isEmpty
            ? 'No employees match this payroll run scope.'
            : blocker != null
            ? blocker.blockerLabel
            : draft.isReadyToSubmit
            ? 'Create run plan for ${included.length} employees.'
            : draft.validationErrors.first;

    return PayrollRunBuilderPreview(
      draft: draft,
      includedEmployees: included,
      readinessItems: readinessItems,
      excludedEmployeeCount: excludedCount,
      estimatedGross: gross,
      estimatedNet: net,
      estimatedDeductions: deductions,
      nextAction: nextAction,
    );
  }

  int get includedEmployeeCount => includedEmployees.length;

  int get readyChecklistCount {
    return readinessItems.where((item) => item.isReady).length;
  }

  int get blockerCount => readinessItems.length - readyChecklistCount;

  double get readinessRatio {
    if (readinessItems.isEmpty) return 1;
    return readyChecklistCount / readinessItems.length;
  }

  bool get canCreateRun =>
      draft.isReadyToSubmit &&
      includedEmployees.isNotEmpty &&
      blockerCount == 0;

  List<PayrollRunBuildArtifact> buildArtifacts() {
    return [
      PayrollRunBuildArtifact(
        id: 'employee-register',
        title: 'Employee register',
        owner: 'Payroll Ops',
        detail:
            '$includedEmployeeCount employees included in ${draft.scope.label}.',
        status:
            includedEmployeeCount > 0
                ? PayrollRunBuildArtifactStatus.ready
                : PayrollRunBuildArtifactStatus.blocked,
      ),
      PayrollRunBuildArtifact(
        id: 'payment-profile-review',
        title: 'Payment profile review',
        owner: 'Finance Ops',
        detail:
            '${_readinessById('payment-profile').readyCount}/${_readinessById('payment-profile').requiredCount} payment destinations ready.',
        status:
            _readinessById('payment-profile').isReady
                ? PayrollRunBuildArtifactStatus.ready
                : PayrollRunBuildArtifactStatus.blocked,
      ),
      PayrollRunBuildArtifact(
        id: 'cost-center-allocation',
        title: 'Cost center allocation',
        owner: 'Finance Partner',
        detail:
            '${_readinessById('cost-center').readyCount}/${_readinessById('cost-center').requiredCount} employees mapped to cost centers.',
        status:
            _readinessById('cost-center').isReady
                ? PayrollRunBuildArtifactStatus.ready
                : PayrollRunBuildArtifactStatus.blocked,
      ),
      PayrollRunBuildArtifact(
        id: 'approval-checklist',
        title: 'Run approval checklist',
        owner: 'Payroll Manager',
        detail:
            '$readyChecklistCount/${readinessItems.length} setup checks ready.',
        status:
            blockerCount == 0
                ? PayrollRunBuildArtifactStatus.ready
                : PayrollRunBuildArtifactStatus.blocked,
      ),
    ];
  }

  PayrollRunReadinessItem _readinessById(String id) {
    return readinessItems.firstWhere((item) => item.id == id);
  }
}

class PayrollRunReadinessItem {
  final String id;
  final String label;
  final int readyCount;
  final int requiredCount;
  final String blockerLabel;

  const PayrollRunReadinessItem({
    required this.id,
    required this.label,
    required this.readyCount,
    required this.requiredCount,
    required this.blockerLabel,
  });

  bool get isReady => readyCount >= requiredCount;

  double get completionRatio {
    if (requiredCount == 0) return 1;
    return readyCount / requiredCount;
  }

  String get statusLabel {
    if (isReady) return '$readyCount/$requiredCount ready';
    return blockerLabel;
  }
}
