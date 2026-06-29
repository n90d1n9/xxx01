import '../models/talent_models.dart';

const talentSkillGaps = [
  SkillGap(
    id: 'sg-001',
    employeeName: 'Michael Chen',
    role: 'Senior Developer',
    department: 'Engineering',
    skill: 'Flutter architecture',
    currentLevel: 4,
    targetLevel: 5,
    mentorName: 'Alya Saputra',
    status: SkillGapStatus.growing,
  ),
  SkillGap(
    id: 'sg-002',
    employeeName: 'Rizky Pratama',
    role: 'Store Operations Lead',
    department: 'Operations',
    skill: 'Labor scheduling',
    currentLevel: 2,
    targetLevel: 4,
    mentorName: 'David Kim',
    status: SkillGapStatus.gap,
  ),
  SkillGap(
    id: 'sg-003',
    employeeName: 'Nadia Rahman',
    role: 'Product Designer',
    department: 'Design',
    skill: 'Design systems',
    currentLevel: 5,
    targetLevel: 5,
    mentorName: 'Sarah Johnson',
    status: SkillGapStatus.strength,
  ),
  SkillGap(
    id: 'sg-004',
    employeeName: 'Anisa Putri',
    role: 'Payroll Specialist',
    department: 'Finance',
    skill: 'Payroll reconciliation',
    currentLevel: 3,
    targetLevel: 5,
    mentorName: 'Emma Rodriguez',
    status: SkillGapStatus.gap,
  ),
];

List<LearningPlan> buildLearningPlans(DateTime asOfDate) {
  return [
    LearningPlan(
      id: 'lp-001',
      title: 'Manager coaching fundamentals',
      audience: 'New people managers',
      department: 'Operations',
      dueDate: asOfDate.add(const Duration(days: 8)),
      enrolledCount: 18,
      completedCount: 9,
      status: LearningPlanStatus.inProgress,
    ),
    LearningPlan(
      id: 'lp-002',
      title: 'Payroll close checklist',
      audience: 'Finance and HR operations',
      department: 'Finance',
      dueDate: asOfDate.add(const Duration(days: 3)),
      enrolledCount: 12,
      completedCount: 6,
      status: LearningPlanStatus.inProgress,
    ),
    LearningPlan(
      id: 'lp-003',
      title: 'Secure employee data handling',
      audience: 'All HRIS users',
      department: 'Human Resources',
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      enrolledCount: 32,
      completedCount: 24,
      status: LearningPlanStatus.overdue,
    ),
    LearningPlan(
      id: 'lp-004',
      title: 'Mobile POS release readiness',
      audience: 'Engineering and support',
      department: 'Engineering',
      dueDate: asOfDate.add(const Duration(days: 18)),
      enrolledCount: 20,
      completedCount: 20,
      status: LearningPlanStatus.completed,
    ),
  ];
}

List<CertificationRecord> buildCertifications(DateTime asOfDate) {
  return [
    CertificationRecord(
      id: 'cr-001',
      employeeName: 'Casey Johnson',
      certification: 'Workplace Safety Lead',
      department: 'Operations',
      expiryDate: asOfDate.add(const Duration(days: 19)),
      status: CertificationStatus.expiring,
    ),
    CertificationRecord(
      id: 'cr-002',
      employeeName: 'Emma Rodriguez',
      certification: 'HR Data Privacy',
      department: 'Human Resources',
      expiryDate: asOfDate.add(const Duration(days: 72)),
      status: CertificationStatus.active,
    ),
    CertificationRecord(
      id: 'cr-003',
      employeeName: 'Anisa Putri',
      certification: 'Payroll Tax Specialist',
      department: 'Finance',
      expiryDate: asOfDate.subtract(const Duration(days: 4)),
      status: CertificationStatus.expired,
    ),
    CertificationRecord(
      id: 'cr-004',
      employeeName: 'Michael Chen',
      certification: 'Cloud Security Foundation',
      department: 'Engineering',
      expiryDate: asOfDate.add(const Duration(days: 28)),
      status: CertificationStatus.expiring,
    ),
  ];
}

List<MentorshipPair> buildMentorshipPairs(DateTime asOfDate) {
  return [
    MentorshipPair(
      id: 'mp-001',
      mentorName: 'Sarah Johnson',
      menteeName: 'Nadia Rahman',
      department: 'Design',
      focusArea: 'Design systems craft',
      sessionsCompleted: 5,
      sessionsPlanned: 6,
      nextSession: asOfDate.add(const Duration(days: 4)),
      health: MentorshipHealth.healthy,
    ),
    MentorshipPair(
      id: 'mp-002',
      mentorName: 'David Kim',
      menteeName: 'Rizky Pratama',
      department: 'Operations',
      focusArea: 'Shift planning and escalation',
      sessionsCompleted: 1,
      sessionsPlanned: 4,
      nextSession: asOfDate.add(const Duration(days: 2)),
      health: MentorshipHealth.watch,
    ),
    MentorshipPair(
      id: 'mp-003',
      mentorName: 'Alya Saputra',
      menteeName: 'Michael Chen',
      department: 'Engineering',
      focusArea: 'Architecture review leadership',
      sessionsCompleted: 3,
      sessionsPlanned: 5,
      nextSession: asOfDate.add(const Duration(days: 6)),
      health: MentorshipHealth.healthy,
    ),
    MentorshipPair(
      id: 'mp-004',
      mentorName: 'Emma Rodriguez',
      menteeName: 'Anisa Putri',
      department: 'Finance',
      focusArea: 'Payroll close ownership',
      sessionsCompleted: 0,
      sessionsPlanned: 3,
      nextSession: asOfDate.add(const Duration(days: 1)),
      health: MentorshipHealth.blocked,
    ),
  ];
}
