import 'payroll_payslip_models.dart';

enum PayrollPayslipTemplateStatus {
  needsSetup('Needs setup'),
  blocked('Blocked'),
  ready('Ready'),
  published('Published');

  final String label;

  const PayrollPayslipTemplateStatus(this.label);
}

enum PayrollPayslipTemplateSectionType {
  earnings('Earnings'),
  deductions('Deductions'),
  benefits('Benefits'),
  employerContributions('Employer contributions'),
  payment('Payment reference'),
  leave('Leave balance'),
  note('Employee note');

  final String label;

  const PayrollPayslipTemplateSectionType(this.label);
}

class PayrollPayslipTemplateProfile {
  final String templateId;
  final String brandName;
  final String logoLabel;
  final String primaryColorHex;
  final bool includeEarnings;
  final bool includeDeductions;
  final bool includeBenefits;
  final bool includeEmployerContributions;
  final bool includePaymentReference;
  final bool includeLeaveBalance;
  final String employeeMessage;
  final String preparedBy;

  const PayrollPayslipTemplateProfile({
    required this.templateId,
    required this.brandName,
    required this.logoLabel,
    required this.primaryColorHex,
    required this.includeEarnings,
    required this.includeDeductions,
    required this.includeBenefits,
    required this.includeEmployerContributions,
    required this.includePaymentReference,
    required this.includeLeaveBalance,
    required this.employeeMessage,
    required this.preparedBy,
  });

  bool get hasBranding =>
      brandName.trim().isNotEmpty &&
      logoLabel.trim().isNotEmpty &&
      primaryColorHex.trim().isNotEmpty;

  bool get hasEmployeeMessage => employeeMessage.trim().isNotEmpty;
}

class PayrollPayslipTemplateSection {
  final PayrollPayslipTemplateSectionType type;
  final String detail;
  final bool isEnabled;
  final bool isRequired;

  const PayrollPayslipTemplateSection({
    required this.type,
    required this.detail,
    required this.isEnabled,
    required this.isRequired,
  });

  String get title => type.label;

  String get statusLabel {
    if (isEnabled) return 'Visible';
    return isRequired ? 'Required' : 'Hidden';
  }
}

class PayrollPayslipTemplateSummary {
  final PayrollPayslipTemplateProfile profile;
  final PayrollPayslipPackageSummary package;
  final PayrollPayslipLine? previewLine;
  final List<PayrollPayslipTemplateSection> sections;
  final List<String> blockers;
  final String nextAction;

  const PayrollPayslipTemplateSummary({
    required this.profile,
    required this.package,
    required this.previewLine,
    required this.sections,
    required this.blockers,
    required this.nextAction,
  });

  factory PayrollPayslipTemplateSummary.fromPackage({
    required PayrollPayslipTemplateProfile profile,
    required PayrollPayslipPackageSummary package,
    required PayrollPayslipDetail detail,
  }) {
    final sections = [
      PayrollPayslipTemplateSection(
        type: PayrollPayslipTemplateSectionType.earnings,
        detail: 'Base salary, approved adjustments, and gross pay lines',
        isEnabled: profile.includeEarnings,
        isRequired: true,
      ),
      PayrollPayslipTemplateSection(
        type: PayrollPayslipTemplateSectionType.deductions,
        detail: 'Tax, benefit deductions, and other payroll withholdings',
        isEnabled: profile.includeDeductions,
        isRequired: true,
      ),
      PayrollPayslipTemplateSection(
        type: PayrollPayslipTemplateSectionType.benefits,
        detail: 'Employee benefit election visibility',
        isEnabled: profile.includeBenefits,
        isRequired: false,
      ),
      PayrollPayslipTemplateSection(
        type: PayrollPayslipTemplateSectionType.employerContributions,
        detail: 'Employer side benefit and statutory contributions',
        isEnabled: profile.includeEmployerContributions,
        isRequired: false,
      ),
      PayrollPayslipTemplateSection(
        type: PayrollPayslipTemplateSectionType.payment,
        detail: 'Payment destination, method, and payroll reference code',
        isEnabled: profile.includePaymentReference,
        isRequired: true,
      ),
      PayrollPayslipTemplateSection(
        type: PayrollPayslipTemplateSectionType.leave,
        detail: 'Leave balance snapshot for the payroll period',
        isEnabled: profile.includeLeaveBalance,
        isRequired: false,
      ),
      PayrollPayslipTemplateSection(
        type: PayrollPayslipTemplateSectionType.note,
        detail: 'Payroll message shown above the statement footer',
        isEnabled: profile.hasEmployeeMessage,
        isRequired: true,
      ),
    ];

    final blockers = <String>[
      if (!profile.hasBranding) 'Complete payslip branding',
      if (!profile.hasEmployeeMessage) 'Add employee delivery message',
      if (sections.any((section) => section.isRequired && !section.isEnabled))
        'Enable all required payslip sections',
      if (package.blockedCount > 0)
        'Resolve ${package.blockedCount} package blockers',
      if (package.lines.isEmpty) 'No payslip lines are available',
    ];

    return PayrollPayslipTemplateSummary(
      profile: profile,
      package: package,
      previewLine: detail.line,
      sections: sections,
      blockers: blockers,
      nextAction: _buildNextAction(blockers, package),
    );
  }

  PayrollPayslipTemplateStatus get status {
    if (blockers.any(
      (blocker) =>
          blocker.contains('branding') ||
          blocker.contains('message') ||
          blocker.contains('required'),
    )) {
      return PayrollPayslipTemplateStatus.needsSetup;
    }
    if (blockers.isNotEmpty) return PayrollPayslipTemplateStatus.blocked;
    if (package.status == PayrollPayslipPackageStatus.published) {
      return PayrollPayslipTemplateStatus.published;
    }
    return PayrollPayslipTemplateStatus.ready;
  }

  int get enabledSectionCount =>
      sections.where((section) => section.isEnabled).length;

  double get sectionReadiness {
    if (sections.isEmpty) return 0;
    return enabledSectionCount / sections.length;
  }

  double get packageReadiness {
    if (package.lines.isEmpty) return 0;
    return (package.publishedCount + package.readyCount) / package.lines.length;
  }

  double get readinessScore =>
      (sectionReadiness * 0.45) + (packageReadiness * 0.55);

  String get previewEmployeeName =>
      previewLine?.employeeName ?? 'No employee selected';

  String get previewStatementId =>
      previewLine?.statementId ?? package.packageId;

  String get deliveryNote {
    final line = previewLine;
    if (line == null) return 'Preview is unavailable until a payslip exists.';
    return '${line.channel.label} - ${line.destinationLabel}';
  }

  static String _buildNextAction(
    List<String> blockers,
    PayrollPayslipPackageSummary package,
  ) {
    if (blockers.isNotEmpty) return blockers.first;
    if (package.status == PayrollPayslipPackageStatus.published) {
      return 'Template and payslip delivery package are fully published.';
    }
    return 'Review the statement preview before publishing payslips.';
  }
}
