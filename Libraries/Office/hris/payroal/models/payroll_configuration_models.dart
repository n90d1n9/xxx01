import 'payroll_employee_profile_models.dart';
import 'payroll_period_models.dart';

enum PayrollConfigurationStatus {
  blocked('Blocked'),
  watch('Watch'),
  ready('Ready');

  final String label;

  const PayrollConfigurationStatus(this.label);
}

enum PayrollPayFrequency {
  monthly('Monthly'),
  biweekly('Biweekly'),
  weekly('Weekly');

  final String label;

  const PayrollPayFrequency(this.label);
}

class PayrollSchedulePolicy {
  final PayrollPayFrequency frequency;
  final int cutoffDay;
  final int payDay;
  final int approvalLeadDays;
  final String timezoneLabel;

  const PayrollSchedulePolicy({
    required this.frequency,
    required this.cutoffDay,
    required this.payDay,
    required this.approvalLeadDays,
    required this.timezoneLabel,
  });

  List<String> get blockers {
    return [
      if (cutoffDay <= 0 || cutoffDay > 31) 'Cut-off day is invalid',
      if (payDay <= 0 || payDay > 31) 'Pay day is invalid',
      if (cutoffDay >= payDay) 'Pay day must be after cut-off day',
      if (approvalLeadDays < 2) 'Approval lead time is below two days',
      if (timezoneLabel.trim().isEmpty) 'Payroll timezone is missing',
    ];
  }
}

class PayrollTaxPolicy {
  final String authorityLabel;
  final String employerTaxId;
  final int filingLeadDays;
  final bool hasElectronicFilingConsent;

  const PayrollTaxPolicy({
    required this.authorityLabel,
    required this.employerTaxId,
    required this.filingLeadDays,
    required this.hasElectronicFilingConsent,
  });

  List<String> get blockers {
    return [
      if (authorityLabel.trim().isEmpty) 'Tax authority is missing',
      if (employerTaxId.trim().isEmpty) 'Employer tax ID is missing',
      if (filingLeadDays < 3) 'Tax filing lead time is below three days',
      if (!hasElectronicFilingConsent) 'Electronic filing consent is missing',
    ];
  }
}

class PayrollBenefitPolicy {
  final String providerLabel;
  final int enrollmentCutoffDays;
  final bool requiresBenefitReconciliation;

  const PayrollBenefitPolicy({
    required this.providerLabel,
    required this.enrollmentCutoffDays,
    required this.requiresBenefitReconciliation,
  });

  List<String> get blockers {
    return [
      if (providerLabel.trim().isEmpty) 'Benefit provider is missing',
      if (enrollmentCutoffDays < 1) 'Benefit enrollment cut-off is invalid',
      if (!requiresBenefitReconciliation)
        'Benefit reconciliation control is disabled',
    ];
  }
}

class PayrollFundingPolicy {
  final String defaultFundingAccount;
  final double reserveRatio;
  final double authorizationLimit;

  const PayrollFundingPolicy({
    required this.defaultFundingAccount,
    required this.reserveRatio,
    required this.authorizationLimit,
  });

  List<String> get blockers {
    return [
      if (defaultFundingAccount.trim().isEmpty)
        'Default funding account is missing',
      if (reserveRatio < 0.05) 'Funding reserve is below 5%',
      if (authorizationLimit <= 0) 'Authorization limit is invalid',
    ];
  }
}

class PayrollConfigurationSummary {
  final PayrollRunPeriod period;
  final PayrollSchedulePolicy schedulePolicy;
  final PayrollTaxPolicy taxPolicy;
  final PayrollBenefitPolicy benefitPolicy;
  final PayrollFundingPolicy fundingPolicy;
  final PayrollEmployeeProfileSummary employeeProfiles;

  const PayrollConfigurationSummary({
    required this.period,
    required this.schedulePolicy,
    required this.taxPolicy,
    required this.benefitPolicy,
    required this.fundingPolicy,
    required this.employeeProfiles,
  });

  List<String> get blockers {
    return [
      ...schedulePolicy.blockers,
      ...taxPolicy.blockers,
      ...benefitPolicy.blockers,
      ...fundingPolicy.blockers,
      if (employeeProfiles.incompleteCount > 0)
        '${employeeProfiles.incompleteCount} employee payroll profiles are incomplete',
      if (employeeProfiles.suspendedCount > 0)
        '${employeeProfiles.suspendedCount} employee payroll profiles are suspended',
    ];
  }

  List<String> get warnings {
    return [
      if (schedulePolicy.approvalLeadDays < 4)
        'Approval lead time is tight for exception handling',
      if (fundingPolicy.reserveRatio < 0.1)
        'Funding reserve is below the preferred 10%',
    ];
  }

  PayrollConfigurationStatus get status {
    if (blockers.isNotEmpty) return PayrollConfigurationStatus.blocked;
    if (warnings.isNotEmpty) return PayrollConfigurationStatus.watch;
    return PayrollConfigurationStatus.ready;
  }

  int get readyControlCount {
    return 5 - blockedControlCount;
  }

  int get blockedControlCount {
    return [
      schedulePolicy.blockers.isNotEmpty,
      taxPolicy.blockers.isNotEmpty,
      benefitPolicy.blockers.isNotEmpty,
      fundingPolicy.blockers.isNotEmpty,
      employeeProfiles.incompleteCount > 0 ||
          employeeProfiles.suspendedCount > 0,
    ].where((isBlocked) => isBlocked).length;
  }

  double get readinessRate => readyControlCount / 5;

  String get nextAction {
    if (blockers.isNotEmpty) return blockers.first;
    if (warnings.isNotEmpty) return warnings.first;
    return 'Payroll configuration is ready for ${period.label}.';
  }
}
