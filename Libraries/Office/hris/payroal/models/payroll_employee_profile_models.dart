import '../../employee/models/employee.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';

enum PayrollEmployeeProfileStatus {
  incomplete('Incomplete'),
  ready('Ready'),
  suspended('Suspended');

  final String label;

  const PayrollEmployeeProfileStatus(this.label);
}

enum PayrollTaxFilingStatus {
  single('Single'),
  married('Married'),
  headOfHousehold('Head of household');

  final String label;

  const PayrollTaxFilingStatus(this.label);
}

enum PayrollRecurringRuleType {
  earning('Earning'),
  deduction('Deduction'),
  benefit('Benefit');

  final String label;

  const PayrollRecurringRuleType(this.label);
}

class PayrollTaxProfile {
  final int employeeId;
  final String taxIdLast4;
  final PayrollTaxFilingStatus filingStatus;
  final int allowanceCount;
  final bool hasWithholdingCertificate;

  const PayrollTaxProfile({
    required this.employeeId,
    required this.taxIdLast4,
    required this.filingStatus,
    required this.allowanceCount,
    required this.hasWithholdingCertificate,
  });

  bool get isComplete {
    return taxIdLast4.trim().length == 4 && hasWithholdingCertificate;
  }
}

class PayrollBenefitElection {
  final int employeeId;
  final String planName;
  final double employeeContribution;
  final double employerContribution;
  final bool isActive;

  const PayrollBenefitElection({
    required this.employeeId,
    required this.planName,
    required this.employeeContribution,
    required this.employerContribution,
    required this.isActive,
  });
}

class PayrollRecurringRule {
  final int employeeId;
  final String id;
  final String label;
  final PayrollRecurringRuleType type;
  final double amount;
  final bool isActive;

  const PayrollRecurringRule({
    required this.employeeId,
    required this.id,
    required this.label,
    required this.type,
    required this.amount,
    required this.isActive,
  });
}

class PayrollEmployeeProfile {
  final Employee employee;
  final PayrollPaymentProfile? paymentProfile;
  final PayrollPayslipDeliveryProfile? payslipDeliveryProfile;
  final PayrollTaxProfile? taxProfile;
  final List<PayrollBenefitElection> benefitElections;
  final List<PayrollRecurringRule> recurringRules;
  final bool isEligible;

  const PayrollEmployeeProfile({
    required this.employee,
    required this.paymentProfile,
    required this.payslipDeliveryProfile,
    required this.taxProfile,
    required this.benefitElections,
    required this.recurringRules,
    required this.isEligible,
  });

  factory PayrollEmployeeProfile.fromEmployee({
    required Employee employee,
    required List<PayrollPaymentProfile> paymentProfiles,
    required List<PayrollPayslipDeliveryProfile> payslipDeliveryProfiles,
    required List<PayrollTaxProfile> taxProfiles,
    required List<PayrollBenefitElection> benefitElections,
    required List<PayrollRecurringRule> recurringRules,
    Set<int> suspendedEmployeeIds = const {},
  }) {
    return PayrollEmployeeProfile(
      employee: employee,
      paymentProfile: _firstPaymentProfile(paymentProfiles, employee.id),
      payslipDeliveryProfile: _firstPayslipDeliveryProfile(
        payslipDeliveryProfiles,
        employee.id,
      ),
      taxProfile: _firstTaxProfile(taxProfiles, employee.id),
      benefitElections:
          benefitElections
              .where((election) => election.employeeId == employee.id)
              .toList(),
      recurringRules:
          recurringRules
              .where((rule) => rule.employeeId == employee.id)
              .toList(),
      isEligible: !suspendedEmployeeIds.contains(employee.id),
    );
  }

  String get employeeName => employee.name;

  String get position => employee.position ?? 'Employee';

  double get salary => employee.salary ?? 0;

  List<PayrollBenefitElection> get activeBenefits {
    return benefitElections.where((election) => election.isActive).toList();
  }

  List<PayrollRecurringRule> get activeRecurringRules {
    return recurringRules.where((rule) => rule.isActive).toList();
  }

  double get recurringEarningTotal {
    return activeRecurringRules
        .where((rule) => rule.type == PayrollRecurringRuleType.earning)
        .fold(0, (total, rule) => total + rule.amount);
  }

  double get recurringDeductionTotal {
    return activeRecurringRules
        .where((rule) => rule.type != PayrollRecurringRuleType.earning)
        .fold(0, (total, rule) => total + rule.amount);
  }

  double get employeeBenefitContribution {
    return activeBenefits.fold(
      0,
      (total, election) => total + election.employeeContribution,
    );
  }

  double get employerBenefitContribution {
    return activeBenefits.fold(
      0,
      (total, election) => total + election.employerContribution,
    );
  }

  List<String> get blockers {
    return [
      if (!isEligible) 'Employee is suspended from payroll',
      if (salary <= 0) 'Missing salary setup',
      if (paymentProfile == null || !paymentProfile!.hasDestination)
        'Missing payment destination',
      if (taxProfile == null || !taxProfile!.isComplete)
        'Incomplete tax profile',
      if (payslipDeliveryProfile == null) 'Missing payslip delivery profile',
    ];
  }

  PayrollEmployeeProfileStatus get status {
    if (!isEligible) return PayrollEmployeeProfileStatus.suspended;
    if (blockers.isNotEmpty) return PayrollEmployeeProfileStatus.incomplete;
    return PayrollEmployeeProfileStatus.ready;
  }

  bool get canIncludeInRun => status == PayrollEmployeeProfileStatus.ready;

  String get nextAction {
    if (blockers.isNotEmpty) return blockers.first;
    return 'Payroll profile is ready for the next run.';
  }
}

class PayrollEmployeeProfileSummary {
  final List<PayrollEmployeeProfile> profiles;
  final int? selectedEmployeeId;

  const PayrollEmployeeProfileSummary({
    required this.profiles,
    required this.selectedEmployeeId,
  });

  factory PayrollEmployeeProfileSummary.fromEmployees({
    required List<Employee> employees,
    required List<PayrollPaymentProfile> paymentProfiles,
    required List<PayrollPayslipDeliveryProfile> payslipDeliveryProfiles,
    required List<PayrollTaxProfile> taxProfiles,
    required List<PayrollBenefitElection> benefitElections,
    required List<PayrollRecurringRule> recurringRules,
    required int? selectedEmployeeId,
    Set<int> suspendedEmployeeIds = const {},
  }) {
    return PayrollEmployeeProfileSummary(
      profiles:
          employees.map((employee) {
            return PayrollEmployeeProfile.fromEmployee(
              employee: employee,
              paymentProfiles: paymentProfiles,
              payslipDeliveryProfiles: payslipDeliveryProfiles,
              taxProfiles: taxProfiles,
              benefitElections: benefitElections,
              recurringRules: recurringRules,
              suspendedEmployeeIds: suspendedEmployeeIds,
            );
          }).toList(),
      selectedEmployeeId: selectedEmployeeId,
    );
  }

  PayrollEmployeeProfile? get selectedProfile {
    if (profiles.isEmpty) return null;
    for (final profile in profiles) {
      if (profile.employee.id == selectedEmployeeId) return profile;
    }
    return profiles.first;
  }

  int get readyCount {
    return profiles
        .where(
          (profile) => profile.status == PayrollEmployeeProfileStatus.ready,
        )
        .length;
  }

  int get incompleteCount {
    return profiles
        .where(
          (profile) =>
              profile.status == PayrollEmployeeProfileStatus.incomplete,
        )
        .length;
  }

  int get suspendedCount {
    return profiles
        .where(
          (profile) => profile.status == PayrollEmployeeProfileStatus.suspended,
        )
        .length;
  }

  double get readinessRate {
    if (profiles.isEmpty) return 0;
    return readyCount / profiles.length;
  }

  String get nextAction {
    final profile = selectedProfile;
    if (profile == null) return 'No employee payroll profiles available.';
    if (incompleteCount > 0 || suspendedCount > 0) {
      return profile.nextAction;
    }
    return 'All employee payroll profiles are ready.';
  }
}

PayrollPaymentProfile? _firstPaymentProfile(
  List<PayrollPaymentProfile> profiles,
  int employeeId,
) {
  for (final profile in profiles) {
    if (profile.employeeId == employeeId) return profile;
  }
  return null;
}

PayrollPayslipDeliveryProfile? _firstPayslipDeliveryProfile(
  List<PayrollPayslipDeliveryProfile> profiles,
  int employeeId,
) {
  for (final profile in profiles) {
    if (profile.employeeId == employeeId) return profile;
  }
  return null;
}

PayrollTaxProfile? _firstTaxProfile(
  List<PayrollTaxProfile> profiles,
  int employeeId,
) {
  for (final profile in profiles) {
    if (profile.employeeId == employeeId) return profile;
  }
  return null;
}
