import '../models/compensation_models.dart';

List<CompensationReview> buildCompensationReviews(DateTime asOfDate) {
  return [
    CompensationReview(
      id: 'comp-001',
      employeeName: 'Michael Chen',
      department: 'Engineering',
      role: 'Senior Developer',
      managerName: 'Alya Saputra',
      currentSalary: 8200,
      proposedSalary: 8900,
      marketPercentile: 72,
      effectiveDate: asOfDate.add(const Duration(days: 32)),
      status: CompensationStatus.inReview,
    ),
    CompensationReview(
      id: 'comp-002',
      employeeName: 'Rizky Pratama',
      department: 'Operations',
      role: 'Store Operations Lead',
      managerName: 'David Kim',
      currentSalary: 4600,
      proposedSalary: 5150,
      marketPercentile: 58,
      effectiveDate: asOfDate.add(const Duration(days: 18)),
      status: CompensationStatus.blocked,
    ),
    CompensationReview(
      id: 'comp-003',
      employeeName: 'Anisa Putri',
      department: 'Finance',
      role: 'Payroll Specialist',
      managerName: 'Emma Rodriguez',
      currentSalary: 5400,
      proposedSalary: 5850,
      marketPercentile: 64,
      effectiveDate: asOfDate.add(const Duration(days: 28)),
      status: CompensationStatus.approved,
    ),
    CompensationReview(
      id: 'comp-004',
      employeeName: 'Nadia Rahman',
      department: 'Design',
      role: 'Product Designer',
      managerName: 'Sarah Johnson',
      currentSalary: 6100,
      proposedSalary: 6500,
      marketPercentile: 69,
      effectiveDate: asOfDate.add(const Duration(days: 41)),
      status: CompensationStatus.draft,
    ),
  ];
}

List<BenefitEnrollment> buildBenefitEnrollments(DateTime asOfDate) {
  return [
    BenefitEnrollment(
      id: 'ben-001',
      employeeName: 'Casey Johnson',
      department: 'Operations',
      planName: 'Family medical plan',
      coverage: 'Employee + family',
      deadline: asOfDate.add(const Duration(days: 4)),
      status: BenefitEnrollmentStatus.issue,
    ),
    BenefitEnrollment(
      id: 'ben-002',
      employeeName: 'Nadia Rahman',
      department: 'Design',
      planName: 'Wellbeing allowance',
      coverage: 'Employee',
      deadline: asOfDate.add(const Duration(days: 11)),
      status: BenefitEnrollmentStatus.pending,
    ),
    BenefitEnrollment(
      id: 'ben-003',
      employeeName: 'Michael Chen',
      department: 'Engineering',
      planName: 'Premium medical plan',
      coverage: 'Employee + spouse',
      deadline: asOfDate.add(const Duration(days: 16)),
      status: BenefitEnrollmentStatus.enrolled,
    ),
    BenefitEnrollment(
      id: 'ben-004',
      employeeName: 'Rizky Pratama',
      department: 'Operations',
      planName: 'Transport benefit',
      coverage: 'Employee',
      deadline: asOfDate.add(const Duration(days: 2)),
      status: BenefitEnrollmentStatus.open,
    ),
  ];
}

const compensationAllowanceBudgets = [
  AllowanceBudget(
    id: 'allow-001',
    department: 'Operations',
    allowanceType: 'Overtime allowance',
    budget: 28000,
    spent: 24100,
    forecast: 31500,
    status: AllowanceBudgetStatus.overBudget,
  ),
  AllowanceBudget(
    id: 'allow-002',
    department: 'Engineering',
    allowanceType: 'Device stipend',
    budget: 18000,
    spent: 11200,
    forecast: 16500,
    status: AllowanceBudgetStatus.healthy,
  ),
  AllowanceBudget(
    id: 'allow-003',
    department: 'Finance',
    allowanceType: 'Certification support',
    budget: 9000,
    spent: 7100,
    forecast: 9200,
    status: AllowanceBudgetStatus.watch,
  ),
  AllowanceBudget(
    id: 'allow-004',
    department: 'Design',
    allowanceType: 'Learning allowance',
    budget: 12000,
    spent: 6800,
    forecast: 9800,
    status: AllowanceBudgetStatus.healthy,
  ),
];

List<IncentivePayout> buildIncentivePayouts(DateTime asOfDate) {
  return [
    IncentivePayout(
      id: 'inc-001',
      employeeName: 'Michael Chen',
      department: 'Engineering',
      programName: 'Release quality bonus',
      targetAmount: 1800,
      approvedAmount: 1700,
      payoutDate: asOfDate.add(const Duration(days: 12)),
      status: IncentiveStatus.pendingApproval,
    ),
    IncentivePayout(
      id: 'inc-002',
      employeeName: 'Casey Johnson',
      department: 'Operations',
      programName: 'Shift coverage bonus',
      targetAmount: 950,
      approvedAmount: 760,
      payoutDate: asOfDate.add(const Duration(days: 7)),
      status: IncentiveStatus.draft,
    ),
    IncentivePayout(
      id: 'inc-003',
      employeeName: 'Anisa Putri',
      department: 'Finance',
      programName: 'Payroll close bonus',
      targetAmount: 1200,
      approvedAmount: 1200,
      payoutDate: asOfDate.add(const Duration(days: 5)),
      status: IncentiveStatus.approved,
    ),
  ];
}
