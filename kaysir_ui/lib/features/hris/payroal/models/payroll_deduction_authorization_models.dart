import 'payroll_employee_profile_models.dart';

enum PayrollDeductionAuthorizationStatus {
  blocked('Blocked'),
  pending('Pending'),
  approved('Approved');

  final String label;

  const PayrollDeductionAuthorizationStatus(this.label);
}

enum PayrollDeductionAuthorizationType {
  benefitElection('Benefit election'),
  recurringDeduction('Recurring deduction'),
  taxableBenefit('Taxable benefit'),
  garnishment('Garnishment');

  final String label;

  const PayrollDeductionAuthorizationType(this.label);
}

class PayrollDeductionAuthorizationLine {
  final String id;
  final int employeeId;
  final String employeeName;
  final String position;
  final String label;
  final PayrollDeductionAuthorizationType type;
  final double amount;
  final bool requiresDocument;
  final bool hasDocument;
  final bool isApproved;

  const PayrollDeductionAuthorizationLine({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.position,
    required this.label,
    required this.type,
    required this.amount,
    required this.requiresDocument,
    required this.hasDocument,
    required this.isApproved,
  });

  List<String> get blockers {
    return [
      if (requiresDocument && !hasDocument) 'Missing authorization document',
      if (amount <= 0) 'Missing deduction amount',
    ];
  }

  bool get hasBlockers => blockers.isNotEmpty;

  PayrollDeductionAuthorizationStatus get status {
    if (hasBlockers) return PayrollDeductionAuthorizationStatus.blocked;
    if (isApproved) return PayrollDeductionAuthorizationStatus.approved;
    return PayrollDeductionAuthorizationStatus.pending;
  }

  bool get canApprove => status == PayrollDeductionAuthorizationStatus.pending;

  String get nextAction {
    if (hasBlockers) return blockers.first;
    if (isApproved) return 'Deduction authorization is approved.';
    return 'Review and approve deduction authorization.';
  }
}

class PayrollDeductionAuthorizationSummary {
  final List<PayrollDeductionAuthorizationLine> lines;
  final int? selectedEmployeeId;

  const PayrollDeductionAuthorizationSummary({
    required this.lines,
    required this.selectedEmployeeId,
  });

  factory PayrollDeductionAuthorizationSummary.fromProfiles({
    required PayrollEmployeeProfileSummary employeeProfiles,
    required Set<String> approvedAuthorizationIds,
  }) {
    final lines = <PayrollDeductionAuthorizationLine>[];
    for (final profile in employeeProfiles.profiles) {
      for (final election in profile.activeBenefits) {
        lines.add(
          PayrollDeductionAuthorizationLine(
            id: _benefitId(profile.employee.id, election.planName),
            employeeId: profile.employee.id,
            employeeName: profile.employeeName,
            position: profile.position,
            label: election.planName,
            type: PayrollDeductionAuthorizationType.benefitElection,
            amount: election.employeeContribution,
            requiresDocument: true,
            hasDocument: true,
            isApproved: approvedAuthorizationIds.contains(
              _benefitId(profile.employee.id, election.planName),
            ),
          ),
        );
      }

      for (final rule in profile.activeRecurringRules.where(
        (rule) => rule.type != PayrollRecurringRuleType.earning,
      )) {
        final type = _ruleType(rule);
        lines.add(
          PayrollDeductionAuthorizationLine(
            id: rule.id,
            employeeId: profile.employee.id,
            employeeName: profile.employeeName,
            position: profile.position,
            label: rule.label,
            type: type,
            amount: rule.amount,
            requiresDocument:
                type != PayrollDeductionAuthorizationType.taxableBenefit,
            hasDocument: _hasRuleDocument(rule),
            isApproved: approvedAuthorizationIds.contains(rule.id),
          ),
        );
      }
    }

    return PayrollDeductionAuthorizationSummary(
      lines: lines,
      selectedEmployeeId: employeeProfiles.selectedEmployeeId,
    );
  }

  List<PayrollDeductionAuthorizationLine> get visibleLines {
    if (selectedEmployeeId == null) return lines;
    return lines
        .where((line) => line.employeeId == selectedEmployeeId)
        .toList();
  }

  int get pendingCount =>
      lines
          .where(
            (line) =>
                line.status == PayrollDeductionAuthorizationStatus.pending,
          )
          .length;

  int get approvedCount =>
      lines
          .where(
            (line) =>
                line.status == PayrollDeductionAuthorizationStatus.approved,
          )
          .length;

  int get blockedCount =>
      lines
          .where(
            (line) =>
                line.status == PayrollDeductionAuthorizationStatus.blocked,
          )
          .length;

  double get totalAuthorizedAmount =>
      lines.fold(0, (total, line) => total + line.amount);

  double get approvedAmount => lines
      .where(
        (line) => line.status == PayrollDeductionAuthorizationStatus.approved,
      )
      .fold(0, (total, line) => total + line.amount);

  double get approvalRate {
    if (lines.isEmpty) return 0;
    return approvedCount / lines.length;
  }

  bool get canApprove => lines.any((line) => line.canApprove);

  PayrollDeductionAuthorizationStatus get status {
    if (blockedCount > 0) return PayrollDeductionAuthorizationStatus.blocked;
    if (pendingCount > 0) return PayrollDeductionAuthorizationStatus.pending;
    return PayrollDeductionAuthorizationStatus.approved;
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount deduction authorization blockers.';
    }
    if (pendingCount > 0) {
      return 'Approve $pendingCount deduction authorizations.';
    }
    return 'All deduction authorizations are approved.';
  }

  static String _benefitId(int employeeId, String planName) {
    return 'BEN-$employeeId-${_slug(planName)}';
  }

  static String _slug(String value) {
    return value
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  static PayrollDeductionAuthorizationType _ruleType(
    PayrollRecurringRule rule,
  ) {
    if (rule.label.toLowerCase().contains('garnishment')) {
      return PayrollDeductionAuthorizationType.garnishment;
    }
    if (rule.type == PayrollRecurringRuleType.benefit) {
      return PayrollDeductionAuthorizationType.taxableBenefit;
    }
    return PayrollDeductionAuthorizationType.recurringDeduction;
  }

  static bool _hasRuleDocument(PayrollRecurringRule rule) {
    final label = rule.label.toLowerCase();
    if (label.contains('garnishment')) return false;
    return rule.amount > 0;
  }
}
