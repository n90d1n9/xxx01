import '../models/performance_models.dart';

List<GoalProgress> buildGoalProgress(DateTime asOfDate) {
  return [
    GoalProgress(
      id: 'goal-001',
      employeeName: 'Michael Chen',
      department: 'Engineering',
      goal: 'Reduce mobile checkout latency by 20%',
      progress: 72,
      dueDate: asOfDate.add(const Duration(days: 18)),
      status: GoalStatus.onTrack,
    ),
    GoalProgress(
      id: 'goal-002',
      employeeName: 'Rizky Pratama',
      department: 'Operations',
      goal: 'Improve shift coverage adherence',
      progress: 48,
      dueDate: asOfDate.add(const Duration(days: 11)),
      status: GoalStatus.atRisk,
    ),
    GoalProgress(
      id: 'goal-003',
      employeeName: 'Anisa Putri',
      department: 'Finance',
      goal: 'Close payroll variance under 0.5%',
      progress: 83,
      dueDate: asOfDate.add(const Duration(days: 9)),
      status: GoalStatus.onTrack,
    ),
    GoalProgress(
      id: 'goal-004',
      employeeName: 'Nadia Rahman',
      department: 'Design',
      goal: 'Publish POS design system guidelines',
      progress: 100,
      dueDate: asOfDate.subtract(const Duration(days: 2)),
      status: GoalStatus.completed,
    ),
  ];
}

List<ReviewCycle> buildReviewCycles(DateTime asOfDate) {
  return [
    ReviewCycle(
      id: 'review-001',
      title: 'Q2 manager review',
      department: 'Operations',
      participantCount: 18,
      submittedCount: 11,
      dueDate: asOfDate.add(const Duration(days: 5)),
      status: ReviewStatus.inProgress,
    ),
    ReviewCycle(
      id: 'review-002',
      title: 'Engineering growth check-in',
      department: 'Engineering',
      participantCount: 22,
      submittedCount: 20,
      dueDate: asOfDate.add(const Duration(days: 2)),
      status: ReviewStatus.inProgress,
    ),
    ReviewCycle(
      id: 'review-003',
      title: 'Finance probation review',
      department: 'Finance',
      participantCount: 6,
      submittedCount: 4,
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      status: ReviewStatus.overdue,
    ),
  ];
}

const performanceCalibrationItems = [
  CalibrationItem(
    id: 'cal-001',
    employeeName: 'Rizky Pratama',
    department: 'Operations',
    managerName: 'David Kim',
    proposedRating: 'Exceeds',
    calibratedRating: 'Meets+',
    status: CalibrationStatus.needsReview,
  ),
  CalibrationItem(
    id: 'cal-002',
    employeeName: 'Michael Chen',
    department: 'Engineering',
    managerName: 'Alya Saputra',
    proposedRating: 'Exceeds',
    calibratedRating: 'Exceeds',
    status: CalibrationStatus.aligned,
  ),
  CalibrationItem(
    id: 'cal-003',
    employeeName: 'Anisa Putri',
    department: 'Finance',
    managerName: 'Emma Rodriguez',
    proposedRating: 'Meets',
    calibratedRating: 'Meets',
    status: CalibrationStatus.aligned,
  ),
  CalibrationItem(
    id: 'cal-004',
    employeeName: 'Casey Johnson',
    department: 'Operations',
    managerName: 'David Kim',
    proposedRating: 'Meets',
    calibratedRating: 'Needs discussion',
    status: CalibrationStatus.disputed,
  ),
];

const performanceSuccessionCandidates = [
  SuccessionCandidate(
    id: 'succ-001',
    role: 'Engineering Lead',
    department: 'Engineering',
    candidateName: 'Michael Chen',
    sponsorName: 'Alya Saputra',
    readiness: SuccessionReadiness.readySoon,
    readinessScore: 84,
  ),
  SuccessionCandidate(
    id: 'succ-002',
    role: 'Store Operations Manager',
    department: 'Operations',
    candidateName: 'Rizky Pratama',
    sponsorName: 'David Kim',
    readiness: SuccessionReadiness.developing,
    readinessScore: 68,
  ),
  SuccessionCandidate(
    id: 'succ-003',
    role: 'Payroll Operations Lead',
    department: 'Finance',
    candidateName: 'Anisa Putri',
    sponsorName: 'Emma Rodriguez',
    readiness: SuccessionReadiness.readyNow,
    readinessScore: 91,
  ),
];

List<RetentionRisk> buildRetentionRisks(DateTime asOfDate) {
  return [
    RetentionRisk(
      id: 'risk-001',
      employeeName: 'Casey Johnson',
      department: 'Operations',
      signal: 'High overtime and low pulse trend',
      actionOwner: 'David Kim',
      level: RetentionRiskLevel.high,
      reviewDate: asOfDate.add(const Duration(days: 2)),
    ),
    RetentionRisk(
      id: 'risk-002',
      employeeName: 'Michael Chen',
      department: 'Engineering',
      signal: 'External offer likelihood',
      actionOwner: 'Alya Saputra',
      level: RetentionRiskLevel.medium,
      reviewDate: asOfDate.add(const Duration(days: 7)),
    ),
    RetentionRisk(
      id: 'risk-003',
      employeeName: 'Nadia Rahman',
      department: 'Design',
      signal: 'Stable engagement and growth path',
      actionOwner: 'Sarah Johnson',
      level: RetentionRiskLevel.low,
      reviewDate: asOfDate.add(const Duration(days: 20)),
    ),
  ];
}
