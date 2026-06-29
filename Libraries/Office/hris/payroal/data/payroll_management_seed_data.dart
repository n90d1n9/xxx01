import '../models/payroll_management_models.dart';

List<PayrollRunPeriod> buildPayrollRunPeriods() {
  return [
    PayrollRunPeriod(
      id: '202605',
      label: 'May 2026 Payroll',
      asOfDate: DateTime(2026, 5, 2),
      payDate: DateTime(2026, 5, 25),
      statusLabel: 'Archived',
      isCurrent: false,
    ),
    PayrollRunPeriod(
      id: '202606',
      label: 'June 2026 Payroll',
      asOfDate: DateTime(2026, 6, 2),
      payDate: DateTime(2026, 6, 25),
      statusLabel: 'Current close',
      isCurrent: true,
    ),
    PayrollRunPeriod(
      id: '202607',
      label: 'July 2026 Payroll',
      asOfDate: DateTime(2026, 7, 2),
      payDate: DateTime(2026, 7, 25),
      statusLabel: 'Planning',
      isCurrent: false,
    ),
  ];
}

List<PayrollPaymentProfile> buildPayrollPaymentProfiles() {
  return const [
    PayrollPaymentProfile(
      employeeId: 1,
      method: PayrollPaymentMethod.bankTransfer,
      destinationLabel: 'BCA **** 1932',
      fundingSource: 'Main payroll account',
      referenceCode: 'PAY-202606-0001',
    ),
    PayrollPaymentProfile(
      employeeId: 2,
      method: PayrollPaymentMethod.bankTransfer,
      destinationLabel: 'Mandiri **** 2044',
      fundingSource: 'Main payroll account',
      referenceCode: 'PAY-202606-0002',
    ),
    PayrollPaymentProfile(
      employeeId: 3,
      method: PayrollPaymentMethod.instantWallet,
      destinationLabel: 'OVO **** 5590',
      fundingSource: 'Executive payroll account',
      referenceCode: 'PAY-202606-0003',
    ),
  ];
}

PayrollSchedulePolicy buildPayrollSchedulePolicy() {
  return const PayrollSchedulePolicy(
    frequency: PayrollPayFrequency.monthly,
    cutoffDay: 20,
    payDay: 25,
    approvalLeadDays: 3,
    timezoneLabel: 'Asia/Jakarta',
  );
}

PayrollTaxPolicy buildPayrollTaxPolicy() {
  return const PayrollTaxPolicy(
    authorityLabel: 'Indonesian Tax Authority',
    employerTaxId: 'KYS-2026-PPH21',
    filingLeadDays: 5,
    hasElectronicFilingConsent: true,
  );
}

PayrollBenefitPolicy buildPayrollBenefitPolicy() {
  return const PayrollBenefitPolicy(
    providerLabel: 'Kaysir Benefits Trust',
    enrollmentCutoffDays: 7,
    requiresBenefitReconciliation: true,
  );
}

PayrollFundingPolicy buildPayrollFundingPolicy() {
  return const PayrollFundingPolicy(
    defaultFundingAccount: 'Main payroll account',
    reserveRatio: 0.08,
    authorizationLimit: 25000,
  );
}

List<PayrollPayslipDeliveryProfile> buildPayrollPayslipDeliveryProfiles() {
  return const [
    PayrollPayslipDeliveryProfile(
      employeeId: 1,
      channel: PayrollPayslipDeliveryChannel.employeePortal,
      destinationLabel: 'Employee portal',
    ),
    PayrollPayslipDeliveryProfile(
      employeeId: 2,
      channel: PayrollPayslipDeliveryChannel.email,
      destinationLabel: 'sarah.williams@kaysir.test',
    ),
    PayrollPayslipDeliveryProfile(
      employeeId: 3,
      channel: PayrollPayslipDeliveryChannel.sealedPrint,
      destinationLabel: 'HQ payroll counter',
    ),
  ];
}

PayrollPayslipTemplateProfile buildPayrollPayslipTemplateProfile() {
  return const PayrollPayslipTemplateProfile(
    templateId: 'PST-KAYSIR-STD',
    brandName: 'Kaysir People Operations',
    logoLabel: 'Kaysir',
    primaryColorHex: '#2563EB',
    includeEarnings: true,
    includeDeductions: true,
    includeBenefits: true,
    includeEmployerContributions: true,
    includePaymentReference: true,
    includeLeaveBalance: true,
    employeeMessage:
        'Thank you for your contribution this period. Please review your payroll statement before the archive closes.',
    preparedBy: 'Payroll operations',
  );
}

List<PayrollTaxProfile> buildPayrollTaxProfiles() {
  return const [
    PayrollTaxProfile(
      employeeId: 1,
      taxIdLast4: '1932',
      filingStatus: PayrollTaxFilingStatus.single,
      allowanceCount: 1,
      hasWithholdingCertificate: true,
    ),
    PayrollTaxProfile(
      employeeId: 2,
      taxIdLast4: '2044',
      filingStatus: PayrollTaxFilingStatus.married,
      allowanceCount: 2,
      hasWithholdingCertificate: true,
    ),
    PayrollTaxProfile(
      employeeId: 3,
      taxIdLast4: '5590',
      filingStatus: PayrollTaxFilingStatus.headOfHousehold,
      allowanceCount: 1,
      hasWithholdingCertificate: false,
    ),
  ];
}

List<PayrollBenefitElection> buildPayrollBenefitElections() {
  return const [
    PayrollBenefitElection(
      employeeId: 1,
      planName: 'Gold health plan',
      employeeContribution: 185,
      employerContribution: 420,
      isActive: true,
    ),
    PayrollBenefitElection(
      employeeId: 1,
      planName: 'Retirement match',
      employeeContribution: 425,
      employerContribution: 255,
      isActive: true,
    ),
    PayrollBenefitElection(
      employeeId: 2,
      planName: 'Silver health plan',
      employeeContribution: 145,
      employerContribution: 360,
      isActive: true,
    ),
    PayrollBenefitElection(
      employeeId: 3,
      planName: 'Executive health plan',
      employeeContribution: 245,
      employerContribution: 520,
      isActive: true,
    ),
  ];
}

List<PayrollRecurringRule> buildPayrollRecurringRules() {
  return const [
    PayrollRecurringRule(
      employeeId: 1,
      id: 'RR-1001',
      label: 'Transport allowance',
      type: PayrollRecurringRuleType.earning,
      amount: 250,
      isActive: true,
    ),
    PayrollRecurringRule(
      employeeId: 1,
      id: 'RR-1002',
      label: 'Retirement deduction',
      type: PayrollRecurringRuleType.deduction,
      amount: 425,
      isActive: true,
    ),
    PayrollRecurringRule(
      employeeId: 2,
      id: 'RR-1003',
      label: 'Design equipment stipend',
      type: PayrollRecurringRuleType.earning,
      amount: 180,
      isActive: true,
    ),
    PayrollRecurringRule(
      employeeId: 3,
      id: 'RR-1004',
      label: 'Executive parking benefit',
      type: PayrollRecurringRuleType.benefit,
      amount: 120,
      isActive: true,
    ),
  ];
}

List<PayrollInputChangeRequest> buildPayrollInputChangeRequests(
  DateTime asOfDate,
) {
  return [
    PayrollInputChangeRequest(
      id: 'PIC-1001',
      employeeId: 1,
      type: PayrollInputChangeType.salaryChange,
      currentAmount: 8500,
      proposedAmount: 8950,
      effectiveDate: asOfDate.add(const Duration(days: 4)),
      sourceLabel: 'Compensation review',
      reason: 'Mid-year merit salary change',
      hasApprovalOwner: true,
      hasSupportingDocument: true,
    ),
    PayrollInputChangeRequest(
      id: 'PIC-1002',
      employeeId: 2,
      type: PayrollInputChangeType.bonus,
      currentAmount: 0,
      proposedAmount: 1200,
      effectiveDate: asOfDate.add(const Duration(days: 6)),
      sourceLabel: 'Manager reward',
      reason: 'Launch milestone bonus',
      hasApprovalOwner: true,
      hasSupportingDocument: true,
    ),
    PayrollInputChangeRequest(
      id: 'PIC-1003',
      employeeId: 3,
      type: PayrollInputChangeType.unpaidLeave,
      currentAmount: 0,
      proposedAmount: 480,
      effectiveDate: asOfDate.add(const Duration(days: 2)),
      sourceLabel: 'Attendance exception',
      reason: 'Unpaid leave deduction',
      hasApprovalOwner: true,
      hasSupportingDocument: false,
    ),
    PayrollInputChangeRequest(
      id: 'PIC-1004',
      employeeId: 2,
      type: PayrollInputChangeType.retroAdjustment,
      currentAmount: 0,
      proposedAmount: 350,
      effectiveDate: asOfDate.add(const Duration(days: 8)),
      sourceLabel: 'Payroll correction',
      reason: 'Retroactive schedule correction',
      hasApprovalOwner: true,
      hasSupportingDocument: true,
    ),
  ];
}

List<PayrollAttendanceSignal> buildPayrollAttendanceSignals(DateTime asOfDate) {
  return [
    PayrollAttendanceSignal(
      id: 'PAS-1001',
      employeeId: 1,
      type: PayrollAttendanceSignalType.overtime,
      workDate: asOfDate.subtract(const Duration(days: 1)),
      units: 6,
      rate: 38,
      sourceLabel: 'Approved overtime sheet',
      hasManagerApproval: true,
      hasPayrollEvidence: true,
    ),
    PayrollAttendanceSignal(
      id: 'PAS-1002',
      employeeId: 2,
      type: PayrollAttendanceSignalType.shiftPremium,
      workDate: asOfDate.subtract(const Duration(days: 2)),
      units: 4,
      rate: 18,
      sourceLabel: 'Weekend launch coverage',
      hasManagerApproval: true,
      hasPayrollEvidence: true,
    ),
    PayrollAttendanceSignal(
      id: 'PAS-1003',
      employeeId: 3,
      type: PayrollAttendanceSignalType.lateDeduction,
      workDate: asOfDate.subtract(const Duration(days: 3)),
      units: 1.5,
      rate: 42,
      sourceLabel: 'Late arrival exception',
      hasManagerApproval: false,
      hasPayrollEvidence: true,
    ),
    PayrollAttendanceSignal(
      id: 'PAS-1004',
      employeeId: 2,
      type: PayrollAttendanceSignalType.unpaidAbsence,
      workDate: asOfDate.subtract(const Duration(days: 4)),
      units: 8,
      rate: 31,
      sourceLabel: 'Unpaid absence record',
      hasManagerApproval: true,
      hasPayrollEvidence: true,
    ),
  ];
}

List<PayrollLoanAccount> buildPayrollLoanAccounts() {
  return const [
    PayrollLoanAccount(
      id: 'LON-1001',
      employeeId: 1,
      type: PayrollLoanType.salaryAdvance,
      principalAmount: 2400,
      outstandingBalance: 1800,
      scheduledInstallment: 300,
      deductionCapRatio: 0.08,
      remainingInstallments: 6,
      isPaused: false,
      hasSignedAgreement: true,
      hasFinanceApproval: true,
    ),
    PayrollLoanAccount(
      id: 'LON-1002',
      employeeId: 2,
      type: PayrollLoanType.employeeLoan,
      principalAmount: 5000,
      outstandingBalance: 4200,
      scheduledInstallment: 900,
      deductionCapRatio: 0.07,
      remainingInstallments: 5,
      isPaused: false,
      hasSignedAgreement: true,
      hasFinanceApproval: true,
    ),
    PayrollLoanAccount(
      id: 'LON-1003',
      employeeId: 3,
      type: PayrollLoanType.emergencyAdvance,
      principalAmount: 1500,
      outstandingBalance: 900,
      scheduledInstallment: 250,
      deductionCapRatio: 0.06,
      remainingInstallments: 4,
      isPaused: false,
      hasSignedAgreement: false,
      hasFinanceApproval: true,
    ),
    PayrollLoanAccount(
      id: 'LON-1004',
      employeeId: 2,
      type: PayrollLoanType.salaryAdvance,
      principalAmount: 1000,
      outstandingBalance: 600,
      scheduledInstallment: 200,
      deductionCapRatio: 0.05,
      remainingInstallments: 3,
      isPaused: true,
      hasSignedAgreement: true,
      hasFinanceApproval: true,
    ),
  ];
}

List<PayrollGlAccountMapping> buildPayrollGlAccountMappings() {
  return const [
    PayrollGlAccountMapping(
      category: PayrollGlMappingCategory.grossPayroll,
      sourceLabel: '*',
      accountCode: '6100',
      accountName: 'Salaries and wages expense',
      isRequired: true,
    ),
    PayrollGlAccountMapping(
      category: PayrollGlMappingCategory.cashClearing,
      sourceLabel: '*',
      accountCode: '1015',
      accountName: 'Payroll cash clearing',
      isRequired: true,
    ),
    PayrollGlAccountMapping(
      category: PayrollGlMappingCategory.withholdingLiability,
      sourceLabel: '*',
      accountCode: '2205',
      accountName: 'Payroll withholding liabilities',
      isRequired: true,
    ),
    PayrollGlAccountMapping(
      category: PayrollGlMappingCategory.benefitLiability,
      sourceLabel: '*',
      accountCode: '2210',
      accountName: 'Benefit provider liabilities',
      isRequired: true,
    ),
    PayrollGlAccountMapping(
      category: PayrollGlMappingCategory.loanRepayment,
      sourceLabel: '*',
      accountCode: '',
      accountName: '',
      isRequired: true,
    ),
    PayrollGlAccountMapping(
      category: PayrollGlMappingCategory.attendanceImpact,
      sourceLabel: '*',
      accountCode: '6120',
      accountName: 'Attendance payroll adjustments',
      isRequired: true,
    ),
    PayrollGlAccountMapping(
      category: PayrollGlMappingCategory.costCenter,
      sourceLabel: '*',
      accountCode: '6999',
      accountName: 'Payroll cost center allocation',
      isRequired: true,
    ),
  ];
}

List<PayrollLiabilityProfile> buildPayrollLiabilityProfiles() {
  return const [
    PayrollLiabilityProfile(
      type: PayrollLiabilityType.federalIncomeTax,
      recipientName: 'Internal Revenue Service',
      methodLabel: 'EFTPS',
      referenceCode: 'TAX-202606-FED',
      dueInDays: 5,
    ),
    PayrollLiabilityProfile(
      type: PayrollLiabilityType.stateIncomeTax,
      recipientName: 'State Revenue Office',
      methodLabel: 'ACH debit',
      referenceCode: 'TAX-202606-STATE',
      dueInDays: 7,
    ),
    PayrollLiabilityProfile(
      type: PayrollLiabilityType.socialSecurity,
      recipientName: 'Social Security Administration',
      methodLabel: 'EFTPS',
      referenceCode: 'TAX-202606-SS',
      dueInDays: 5,
    ),
    PayrollLiabilityProfile(
      type: PayrollLiabilityType.medicare,
      recipientName: 'Medicare Trust',
      methodLabel: 'EFTPS',
      referenceCode: 'TAX-202606-MED',
      dueInDays: 5,
    ),
    PayrollLiabilityProfile(
      type: PayrollLiabilityType.retirement401k,
      recipientName: 'Kaysir Retirement Trust',
      methodLabel: 'Wire',
      referenceCode: 'BEN-202606-401K',
      dueInDays: 3,
    ),
    PayrollLiabilityProfile(
      type: PayrollLiabilityType.healthInsurance,
      recipientName: 'Health Benefit Carrier',
      methodLabel: 'ACH credit',
      referenceCode: 'BEN-202606-HLTH',
      dueInDays: 4,
    ),
  ];
}

List<PayrollCostCenterBudgetPlan> buildPayrollCostCenterBudgetPlans() {
  return const [
    PayrollCostCenterBudgetPlan(
      costCenterId: 'engineering',
      owner: 'Engineering Finance Partner',
      budget: 9200,
      reserve: 900,
    ),
    PayrollCostCenterBudgetPlan(
      costCenterId: 'design',
      owner: 'Design Operations Lead',
      budget: 7800,
      reserve: 600,
    ),
    PayrollCostCenterBudgetPlan(
      costCenterId: 'operations',
      owner: 'Operations Controller',
      budget: 9600,
      reserve: 800,
    ),
  ];
}

PayrollReconciliationBaseline buildPayrollReconciliationBaseline(
  DateTime asOfDate,
) {
  final previousMonth = DateTime(asOfDate.year, asOfDate.month - 1);

  return PayrollReconciliationBaseline(
    periodLabel:
        '${_monthLabel(previousMonth.month)} ${previousMonth.year} Payroll',
    grossPayroll: 25250,
    netPayroll: 16800,
    deductions: 8870,
    bankFundingBalance: 18500,
    employeeCount: 3,
  );
}

PayrollRunComparisonBaseline buildPayrollRunComparisonBaseline(
  DateTime asOfDate,
) {
  final previousMonth = DateTime(asOfDate.year, asOfDate.month - 1);

  return PayrollRunComparisonBaseline(
    periodLabel:
        '${_monthLabel(previousMonth.month)} ${previousMonth.year} Payroll',
    employeeCount: 3,
    grossPayroll: 25250,
    netPayroll: 16800,
    deductions: 8870,
    approvedAdjustmentTotal: 300,
    costCenters: const [
      PayrollRunComparisonCostCenterBaseline(
        id: 'engineering',
        label: 'Engineering',
        employeeCount: 1,
        grossPayroll: 8300,
      ),
      PayrollRunComparisonCostCenterBaseline(
        id: 'design',
        label: 'Design',
        employeeCount: 1,
        grossPayroll: 7300,
      ),
      PayrollRunComparisonCostCenterBaseline(
        id: 'operations',
        label: 'Operations',
        employeeCount: 1,
        grossPayroll: 9650,
      ),
    ],
  );
}

List<PayrollAdjustmentRequest> buildPayrollAdjustments(DateTime asOfDate) {
  return [
    PayrollAdjustmentRequest(
      id: 'PA-1001',
      employeeId: 1,
      employeeName: 'Alex Johnson',
      department: 'Engineering',
      type: PayrollAdjustmentType.bonus,
      amount: 1200,
      effectiveDate: asOfDate.add(const Duration(days: 7)),
      costCenter: 'ENG-DELIVERY',
      reason: 'Quarterly delivery bonus pending manager sign-off.',
      status: PayrollAdjustmentStatus.submitted,
      submittedAt: asOfDate.subtract(const Duration(days: 1)),
    ),
    PayrollAdjustmentRequest(
      id: 'PA-1002',
      employeeId: 2,
      employeeName: 'Sarah Williams',
      department: 'Design',
      type: PayrollAdjustmentType.reimbursement,
      amount: 450,
      effectiveDate: asOfDate.add(const Duration(days: 4)),
      costCenter: 'DESIGN-OPS',
      reason: 'Approved equipment reimbursement for onboarding setup.',
      status: PayrollAdjustmentStatus.approved,
      submittedAt: asOfDate.subtract(const Duration(days: 2)),
    ),
    PayrollAdjustmentRequest(
      id: 'PA-1003',
      employeeId: 3,
      employeeName: 'Michael Chen',
      department: 'Operations',
      type: PayrollAdjustmentType.deduction,
      amount: 300,
      effectiveDate: asOfDate.add(const Duration(days: 9)),
      costCenter: 'OPS-PROJECTS',
      reason: 'Rejected correction because source documents did not match.',
      status: PayrollAdjustmentStatus.rejected,
      submittedAt: asOfDate.subtract(const Duration(days: 3)),
    ),
  ];
}

String _monthLabel(int month) {
  return const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
}

List<PayrollExceptionItem> buildPayrollExceptions(DateTime asOfDate) {
  return [
    PayrollExceptionItem(
      id: 'PE-1001',
      title: 'Bank validation missing',
      employeeName: 'Sarah Williams',
      owner: 'Payroll Ops',
      dueDate: asOfDate.add(const Duration(days: 2)),
      severity: PayrollExceptionSeverity.critical,
      status: PayrollExceptionStatus.open,
      action: 'Confirm bank account before direct deposit approval.',
    ),
    PayrollExceptionItem(
      id: 'PE-1002',
      title: 'Overtime variance review',
      employeeName: 'Alex Johnson',
      owner: 'Finance Partner',
      dueDate: asOfDate.add(const Duration(days: 4)),
      severity: PayrollExceptionSeverity.warning,
      status: PayrollExceptionStatus.open,
      action: 'Match overtime hours against approved project schedule.',
    ),
    PayrollExceptionItem(
      id: 'PE-1003',
      title: 'Tax profile confirmed',
      employeeName: 'Michael Chen',
      owner: 'Payroll Ops',
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      severity: PayrollExceptionSeverity.info,
      status: PayrollExceptionStatus.resolved,
      action: 'Tax profile has been confirmed for this payroll run.',
    ),
  ];
}
