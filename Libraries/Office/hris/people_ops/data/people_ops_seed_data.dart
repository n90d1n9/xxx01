import '../models/people_ops_models.dart';

List<WorkforcePlan> buildPeopleOpsWorkforcePlans(DateTime asOfDate) {
  return [
    WorkforcePlan(
      id: 'wf-001',
      role: 'Senior Flutter Engineer',
      department: 'Engineering',
      location: 'Bandung',
      openings: 3,
      filled: 1,
      candidateCount: 18,
      targetDate: asOfDate.add(const Duration(days: 21)),
      priority: PeopleOpsPriority.high,
      status: WorkforcePlanStatus.interviewing,
    ),
    WorkforcePlan(
      id: 'wf-002',
      role: 'Store Operations Lead',
      department: 'Operations',
      location: 'Jakarta',
      openings: 2,
      filled: 0,
      candidateCount: 9,
      targetDate: asOfDate.add(const Duration(days: 12)),
      priority: PeopleOpsPriority.high,
      status: WorkforcePlanStatus.open,
    ),
    WorkforcePlan(
      id: 'wf-003',
      role: 'Payroll Analyst',
      department: 'Finance',
      location: 'Remote',
      openings: 1,
      filled: 1,
      candidateCount: 6,
      targetDate: asOfDate.add(const Duration(days: 28)),
      priority: PeopleOpsPriority.medium,
      status: WorkforcePlanStatus.offer,
    ),
    WorkforcePlan(
      id: 'wf-004',
      role: 'People Partner',
      department: 'Human Resources',
      location: 'Surabaya',
      openings: 1,
      filled: 0,
      candidateCount: 5,
      targetDate: asOfDate.add(const Duration(days: 35)),
      priority: PeopleOpsPriority.medium,
      status: WorkforcePlanStatus.open,
    ),
  ];
}

List<OnboardingMilestone> buildOnboardingMilestones(DateTime asOfDate) {
  return [
    OnboardingMilestone(
      id: 'ob-001',
      employeeName: 'Nadia Rahman',
      role: 'Product Designer',
      department: 'Design',
      buddyName: 'Sarah Johnson',
      startDate: asOfDate.add(const Duration(days: 3)),
      tasksCompleted: 7,
      taskCount: 10,
      status: OnboardingStatus.inProgress,
    ),
    OnboardingMilestone(
      id: 'ob-002',
      employeeName: 'Rizky Pratama',
      role: 'Warehouse Supervisor',
      department: 'Operations',
      buddyName: 'David Kim',
      startDate: asOfDate.add(const Duration(days: 1)),
      tasksCompleted: 4,
      taskCount: 11,
      status: OnboardingStatus.blocked,
    ),
    OnboardingMilestone(
      id: 'ob-003',
      employeeName: 'Anisa Putri',
      role: 'Payroll Specialist',
      department: 'Finance',
      buddyName: 'Emma Rodriguez',
      startDate: asOfDate.subtract(const Duration(days: 4)),
      tasksCompleted: 12,
      taskCount: 12,
      status: OnboardingStatus.done,
    ),
  ];
}

List<ComplianceItem> buildPeopleOpsComplianceItems(DateTime asOfDate) {
  return [
    ComplianceItem(
      id: 'cp-001',
      title: 'Contract renewal packet',
      owner: 'Rizky Pratama',
      department: 'Operations',
      dueDate: asOfDate.add(const Duration(days: 2)),
      status: ComplianceStatus.dueSoon,
      requirement: 'Signed fixed-term agreement and ID verification',
    ),
    ComplianceItem(
      id: 'cp-002',
      title: 'Payroll tax validation',
      owner: 'Finance Ops',
      department: 'Finance',
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      status: ComplianceStatus.overdue,
      requirement: 'NPWP and bank account match',
    ),
    ComplianceItem(
      id: 'cp-003',
      title: 'Safety briefing acknowledgement',
      owner: 'Store Team',
      department: 'Operations',
      dueDate: asOfDate.add(const Duration(days: 9)),
      status: ComplianceStatus.valid,
      requirement: 'Monthly workplace safety acknowledgement',
    ),
    ComplianceItem(
      id: 'cp-004',
      title: 'Data access recertification',
      owner: 'Engineering Leads',
      department: 'Engineering',
      dueDate: asOfDate.add(const Duration(days: 5)),
      status: ComplianceStatus.dueSoon,
      requirement: 'Review admin access for payroll and employee records',
    ),
  ];
}

const peopleOpsEngagementPulses = [
  EngagementPulse(
    id: 'eg-001',
    department: 'Engineering',
    score: 82,
    responseRate: 91,
    insight: 'Delivery confidence is improving after clearer sprint planning.',
    priority: PeopleOpsPriority.low,
  ),
  EngagementPulse(
    id: 'eg-002',
    department: 'Operations',
    score: 68,
    responseRate: 76,
    insight: 'Shift coverage and rest-day swaps need manager follow-up.',
    priority: PeopleOpsPriority.high,
  ),
  EngagementPulse(
    id: 'eg-003',
    department: 'Finance',
    score: 74,
    responseRate: 83,
    insight: 'Payroll close is stable, but month-end overtime remains high.',
    priority: PeopleOpsPriority.medium,
  ),
  EngagementPulse(
    id: 'eg-004',
    department: 'Design',
    score: 88,
    responseRate: 95,
    insight: 'Mentoring and critique rituals are working well.',
    priority: PeopleOpsPriority.low,
  ),
];
