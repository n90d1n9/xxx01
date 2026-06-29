import 'incoming_talent_succession_coverage_council_agenda_item.dart';

class IncomingTalentSuccessionCoverageCouncilAgendaSummary {
  final int totalItems;
  final int urgentCount;
  final int highCount;
  final int executiveDecisionCount;
  final int recoveryCount;
  final int actionFollowUpCount;
  final int validationCount;
  final int monitoringCount;
  final int overdueCount;
  final double averageCoverageScore;
  final String nextAction;

  const IncomingTalentSuccessionCoverageCouncilAgendaSummary({
    required this.totalItems,
    required this.urgentCount,
    required this.highCount,
    required this.executiveDecisionCount,
    required this.recoveryCount,
    required this.actionFollowUpCount,
    required this.validationCount,
    required this.monitoringCount,
    required this.overdueCount,
    required this.averageCoverageScore,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionCoverageCouncilAgendaSummary.fromItems({
    required List<IncomingTalentSuccessionCoverageCouncilAgendaItem> items,
    required DateTime asOfDate,
  }) {
    final urgentCount = _countPriority(
      items,
      IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent,
    );
    final highCount = _countPriority(
      items,
      IncomingTalentSuccessionCoverageCouncilAgendaPriority.high,
    );
    final executiveDecisionCount = _countLane(
      items,
      IncomingTalentSuccessionCoverageCouncilAgendaLane.executiveDecision,
    );
    final recoveryCount = _countLane(
      items,
      IncomingTalentSuccessionCoverageCouncilAgendaLane.coverageRecovery,
    );
    final actionFollowUpCount = _countLane(
      items,
      IncomingTalentSuccessionCoverageCouncilAgendaLane.actionFollowUp,
    );
    final validationCount = _countLane(
      items,
      IncomingTalentSuccessionCoverageCouncilAgendaLane.outcomeValidation,
    );
    final monitoringCount = _countLane(
      items,
      IncomingTalentSuccessionCoverageCouncilAgendaLane.monitoring,
    );
    final overdueCount = items.where((item) => item.isOverdue(asOfDate)).length;
    final coverageScoreTotal = items.fold<int>(
      0,
      (total, item) => total + item.coverageScore,
    );

    return IncomingTalentSuccessionCoverageCouncilAgendaSummary(
      totalItems: items.length,
      urgentCount: urgentCount,
      highCount: highCount,
      executiveDecisionCount: executiveDecisionCount,
      recoveryCount: recoveryCount,
      actionFollowUpCount: actionFollowUpCount,
      validationCount: validationCount,
      monitoringCount: monitoringCount,
      overdueCount: overdueCount,
      averageCoverageScore:
          items.isEmpty ? 0 : coverageScoreTotal / items.length,
      nextAction: _nextAction(
        totalItems: items.length,
        urgentCount: urgentCount,
        highCount: highCount,
        executiveDecisionCount: executiveDecisionCount,
        recoveryCount: recoveryCount,
        validationCount: validationCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

int _countPriority(
  List<IncomingTalentSuccessionCoverageCouncilAgendaItem> items,
  IncomingTalentSuccessionCoverageCouncilAgendaPriority priority,
) {
  return items.where((item) => item.priority == priority).length;
}

int _countLane(
  List<IncomingTalentSuccessionCoverageCouncilAgendaItem> items,
  IncomingTalentSuccessionCoverageCouncilAgendaLane lane,
) {
  return items.where((item) => item.lane == lane).length;
}

String _nextAction({
  required int totalItems,
  required int urgentCount,
  required int highCount,
  required int executiveDecisionCount,
  required int recoveryCount,
  required int validationCount,
  required int overdueCount,
}) {
  if (totalItems == 0) {
    return 'No coverage council items are ready for discussion.';
  }
  if (urgentCount > 0) {
    return 'Open $urgentCount urgent coverage council decisions.';
  }
  if (overdueCount > 0) {
    return 'Escalate $overdueCount overdue agenda items.';
  }
  if (executiveDecisionCount > 0) {
    return 'Prepare $executiveDecisionCount executive decisions.';
  }
  if (recoveryCount > 0) {
    return 'Assign owners for $recoveryCount coverage recovery items.';
  }
  if (highCount > 0) {
    return 'Review $highCount high-priority coverage items.';
  }
  if (validationCount > 0) {
    return 'Validate $validationCount resolved coverage actions.';
  }
  return 'Review $totalItems coverage council agenda items.';
}
