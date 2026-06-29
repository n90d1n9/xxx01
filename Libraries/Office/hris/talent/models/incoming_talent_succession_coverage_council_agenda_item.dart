import 'incoming_talent_succession_coverage_governance_record.dart';

enum IncomingTalentSuccessionCoverageCouncilAgendaLane {
  executiveDecision('Executive decision'),
  coverageRecovery('Coverage recovery'),
  actionFollowUp('Action follow-up'),
  outcomeValidation('Outcome validation'),
  monitoring('Monitoring');

  final String label;

  const IncomingTalentSuccessionCoverageCouncilAgendaLane(this.label);
}

enum IncomingTalentSuccessionCoverageCouncilAgendaPriority {
  urgent('Urgent'),
  high('High'),
  normal('Normal'),
  watch('Watch');

  final String label;

  const IncomingTalentSuccessionCoverageCouncilAgendaPriority(this.label);
}

class IncomingTalentSuccessionCoverageCouncilAgendaItem {
  final String id;
  final String governanceRecordId;
  final String scopeLabel;
  final String departmentScope;
  final String ownerName;
  final IncomingTalentSuccessionCoverageCouncilAgendaLane lane;
  final IncomingTalentSuccessionCoverageCouncilAgendaPriority priority;
  final IncomingTalentSuccessionCoverageGovernanceStage stage;
  final IncomingTalentSuccessionCoverageGovernanceRiskLevel riskLevel;
  final int coverageScore;
  final DateTime dueDate;
  final DateTime councilDate;
  final String decisionQuestion;
  final String discussionPrompt;
  final String preReadSummary;

  const IncomingTalentSuccessionCoverageCouncilAgendaItem({
    required this.id,
    required this.governanceRecordId,
    required this.scopeLabel,
    required this.departmentScope,
    required this.ownerName,
    required this.lane,
    required this.priority,
    required this.stage,
    required this.riskLevel,
    required this.coverageScore,
    required this.dueDate,
    required this.councilDate,
    required this.decisionQuestion,
    required this.discussionPrompt,
    required this.preReadSummary,
  });

  factory IncomingTalentSuccessionCoverageCouncilAgendaItem.fromRecord({
    required IncomingTalentSuccessionCoverageGovernanceRecord record,
    required DateTime asOfDate,
  }) {
    final lane = _laneFor(record);

    return IncomingTalentSuccessionCoverageCouncilAgendaItem(
      id: 'coverage-council:${record.reviewId}',
      governanceRecordId: record.id,
      scopeLabel: record.scopeLabel,
      departmentScope: record.departmentScope,
      ownerName: record.ownerName,
      lane: lane,
      priority: _priorityFor(record, asOfDate),
      stage: record.stage,
      riskLevel: record.riskLevel,
      coverageScore: record.coverageScore,
      dueDate: record.dueDate,
      councilDate: _councilDateFor(record, asOfDate),
      decisionQuestion: _decisionQuestionFor(lane, record),
      discussionPrompt: _discussionPromptFor(record),
      preReadSummary: _preReadFor(record),
    );
  }

  bool get needsExecutiveDecision {
    return lane ==
        IncomingTalentSuccessionCoverageCouncilAgendaLane.executiveDecision;
  }

  double get coverageRatio => coverageScore / 100;

  int daysUntilDue(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(start).inDays;
  }

  bool isOverdue(DateTime asOfDate) => daysUntilDue(asOfDate) < 0;
}

bool shouldIncludeCoverageCouncilAgendaRecord(
  IncomingTalentSuccessionCoverageGovernanceRecord record,
) {
  return !record.isClosed;
}

IncomingTalentSuccessionCoverageCouncilAgendaPriority _priorityFor(
  IncomingTalentSuccessionCoverageGovernanceRecord record,
  DateTime asOfDate,
) {
  if (record.isOverdue(asOfDate) ||
      record.riskLevel ==
          IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical) {
    return IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent;
  }
  if (record.isDueSoon(asOfDate) ||
      record.riskLevel ==
          IncomingTalentSuccessionCoverageGovernanceRiskLevel.high) {
    return IncomingTalentSuccessionCoverageCouncilAgendaPriority.high;
  }
  if (record.riskLevel ==
      IncomingTalentSuccessionCoverageGovernanceRiskLevel.medium) {
    return IncomingTalentSuccessionCoverageCouncilAgendaPriority.normal;
  }
  return IncomingTalentSuccessionCoverageCouncilAgendaPriority.watch;
}

IncomingTalentSuccessionCoverageCouncilAgendaLane _laneFor(
  IncomingTalentSuccessionCoverageGovernanceRecord record,
) {
  if (record.riskLevel ==
      IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical) {
    return IncomingTalentSuccessionCoverageCouncilAgendaLane.executiveDecision;
  }

  return switch (record.stage) {
    IncomingTalentSuccessionCoverageGovernanceStage.actionRequired =>
      IncomingTalentSuccessionCoverageCouncilAgendaLane.coverageRecovery,
    IncomingTalentSuccessionCoverageGovernanceStage.actionOpen =>
      IncomingTalentSuccessionCoverageCouncilAgendaLane.actionFollowUp,
    IncomingTalentSuccessionCoverageGovernanceStage.outcomeReview =>
      IncomingTalentSuccessionCoverageCouncilAgendaLane.outcomeValidation,
    IncomingTalentSuccessionCoverageGovernanceStage.outcomeWatch =>
      IncomingTalentSuccessionCoverageCouncilAgendaLane.monitoring,
    IncomingTalentSuccessionCoverageGovernanceStage.closed =>
      IncomingTalentSuccessionCoverageCouncilAgendaLane.monitoring,
  };
}

DateTime _councilDateFor(
  IncomingTalentSuccessionCoverageGovernanceRecord record,
  DateTime asOfDate,
) {
  if (record.isOverdue(asOfDate) || record.isDueSoon(asOfDate)) {
    return DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  }
  return record.dueDate;
}

String _decisionQuestionFor(
  IncomingTalentSuccessionCoverageCouncilAgendaLane lane,
  IncomingTalentSuccessionCoverageGovernanceRecord record,
) {
  return switch (lane) {
    IncomingTalentSuccessionCoverageCouncilAgendaLane.executiveDecision =>
      'What executive decision removes the ${record.scopeLabel} coverage risk?',
    IncomingTalentSuccessionCoverageCouncilAgendaLane.coverageRecovery =>
      'Which owner will create and commit the ${record.scopeLabel} coverage action?',
    IncomingTalentSuccessionCoverageCouncilAgendaLane.actionFollowUp =>
      'Is the current coverage action still enough to close the risk?',
    IncomingTalentSuccessionCoverageCouncilAgendaLane.outcomeValidation =>
      'Can the council validate the resolved action evidence?',
    IncomingTalentSuccessionCoverageCouncilAgendaLane.monitoring =>
      'What signal would let the council close this watch item?',
  };
}

String _discussionPromptFor(
  IncomingTalentSuccessionCoverageGovernanceRecord record,
) {
  return '${record.nextAction} Confirm owner, due date, and evidence required before the next council.';
}

String _preReadFor(IncomingTalentSuccessionCoverageGovernanceRecord record) {
  return '${record.stage.label}: ${record.evidenceSummary}';
}
