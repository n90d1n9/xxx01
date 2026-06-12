import '../models/engagement_models.dart';

List<EngagementSurvey> buildEngagementSurveys(DateTime asOfDate) {
  return [
    EngagementSurvey(
      id: 'survey-001',
      title: 'Q2 engagement pulse',
      department: 'All',
      responseRate: 72,
      eNps: 34,
      closesAt: asOfDate.add(const Duration(days: 5)),
      status: SurveyStatus.live,
    ),
    EngagementSurvey(
      id: 'survey-002',
      title: 'Operations scheduling check',
      department: 'Operations',
      responseRate: 61,
      eNps: 18,
      closesAt: asOfDate.add(const Duration(days: 2)),
      status: SurveyStatus.actionRequired,
    ),
    EngagementSurvey(
      id: 'survey-003',
      title: 'Engineering release retro',
      department: 'Engineering',
      responseRate: 88,
      eNps: 46,
      closesAt: asOfDate.subtract(const Duration(days: 1)),
      status: SurveyStatus.closed,
    ),
  ];
}

const engagementPulseTopics = [
  PulseTopic(
    id: 'pulse-001',
    topic: 'Manager clarity',
    department: 'Engineering',
    score: 82,
    trend: 6,
    insight: 'Sprint planning rituals are improving role clarity.',
    priority: EngagementPriority.low,
  ),
  PulseTopic(
    id: 'pulse-002',
    topic: 'Workload balance',
    department: 'Operations',
    score: 63,
    trend: -9,
    insight: 'Rest-day swaps and coverage volatility are affecting morale.',
    priority: EngagementPriority.high,
  ),
  PulseTopic(
    id: 'pulse-003',
    topic: 'Career growth',
    department: 'Finance',
    score: 70,
    trend: -3,
    insight: 'Employees want clearer certification and promotion criteria.',
    priority: EngagementPriority.medium,
  ),
  PulseTopic(
    id: 'pulse-004',
    topic: 'Recognition',
    department: 'Design',
    score: 86,
    trend: 8,
    insight: 'Peer critique and showcase sessions are landing well.',
    priority: EngagementPriority.low,
  ),
];

List<RecognitionMoment> buildRecognitionMoments(DateTime asOfDate) {
  return [
    RecognitionMoment(
      id: 'rec-001',
      employeeName: 'Anisa Putri',
      fromName: 'Emma Rodriguez',
      department: 'Finance',
      reason: 'Closed payroll variance early and documented the checklist.',
      recognizedAt: asOfDate.subtract(const Duration(days: 1)),
      type: RecognitionType.manager,
    ),
    RecognitionMoment(
      id: 'rec-002',
      employeeName: 'Nadia Rahman',
      fromName: 'Sarah Johnson',
      department: 'Design',
      reason: 'Published a reusable POS component library.',
      recognizedAt: asOfDate.subtract(const Duration(days: 2)),
      type: RecognitionType.peer,
    ),
    RecognitionMoment(
      id: 'rec-003',
      employeeName: 'Michael Chen',
      fromName: 'Alya Saputra',
      department: 'Engineering',
      reason: 'Five-year contribution milestone.',
      recognizedAt: asOfDate.subtract(const Duration(days: 4)),
      type: RecognitionType.milestone,
    ),
  ];
}

List<WellbeingRisk> buildWellbeingRisks(DateTime asOfDate) {
  return [
    WellbeingRisk(
      id: 'well-001',
      employeeName: 'Casey Johnson',
      department: 'Operations',
      signal: 'High overtime streak and declining pulse response.',
      ownerName: 'David Kim',
      reviewDate: asOfDate.add(const Duration(days: 2)),
      level: WellbeingRiskLevel.high,
    ),
    WellbeingRisk(
      id: 'well-002',
      employeeName: 'Michael Chen',
      department: 'Engineering',
      signal: 'Release load remains elevated across two sprints.',
      ownerName: 'Alya Saputra',
      reviewDate: asOfDate.add(const Duration(days: 6)),
      level: WellbeingRiskLevel.medium,
    ),
    WellbeingRisk(
      id: 'well-003',
      employeeName: 'Nadia Rahman',
      department: 'Design',
      signal: 'Healthy work pattern and steady engagement.',
      ownerName: 'Sarah Johnson',
      reviewDate: asOfDate.add(const Duration(days: 14)),
      level: WellbeingRiskLevel.low,
    ),
  ];
}

List<EngagementActionPlan> buildEngagementActionPlans(DateTime asOfDate) {
  return [
    EngagementActionPlan(
      id: 'act-001',
      department: 'Operations',
      theme: 'Improve shift swap transparency',
      ownerName: 'David Kim',
      progress: 42,
      dueDate: asOfDate.add(const Duration(days: 14)),
      status: ActionPlanStatus.inProgress,
    ),
    EngagementActionPlan(
      id: 'act-002',
      department: 'Finance',
      theme: 'Publish promotion criteria',
      ownerName: 'Emma Rodriguez',
      progress: 18,
      dueDate: asOfDate.add(const Duration(days: 21)),
      status: ActionPlanStatus.planned,
    ),
    EngagementActionPlan(
      id: 'act-003',
      department: 'Engineering',
      theme: 'Reduce release overtime',
      ownerName: 'Alya Saputra',
      progress: 58,
      dueDate: asOfDate.add(const Duration(days: 10)),
      status: ActionPlanStatus.inProgress,
    ),
    EngagementActionPlan(
      id: 'act-004',
      department: 'Design',
      theme: 'Expand peer recognition ritual',
      ownerName: 'Sarah Johnson',
      progress: 100,
      dueDate: asOfDate.subtract(const Duration(days: 3)),
      status: ActionPlanStatus.done,
    ),
  ];
}
