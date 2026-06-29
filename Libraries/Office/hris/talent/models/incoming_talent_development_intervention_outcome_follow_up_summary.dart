import 'incoming_talent_development_intervention_outcome_follow_up.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpSummary {
  final int totalCount;
  final int openCount;
  final int inProgressCount;
  final int completedCount;
  final int escalatedCount;
  final int dueSoonCount;
  final int overdueCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpSummary({
    required this.totalCount,
    required this.openCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.escalatedCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentDevelopmentInterventionOutcomeFollowUpSummary.fromItems({
    required List<IncomingTalentDevelopmentInterventionOutcomeFollowUp> items,
    required DateTime asOfDate,
  }) {
    final openCount = _countByStatus(
      items,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.open,
    );
    final inProgressCount = _countByStatus(
      items,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.inProgress,
    );
    final completedCount = _countByStatus(
      items,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.completed,
    );
    final escalatedCount = _countByStatus(
      items,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.escalated,
    );
    final dueSoonCount = items.where((item) => item.isDueSoon(asOfDate)).length;
    final overdueCount = items.where((item) => item.isOverdue(asOfDate)).length;
    final attentionCount =
        items.where((item) => item.needsAttention(asOfDate)).length;

    return IncomingTalentDevelopmentInterventionOutcomeFollowUpSummary(
      totalCount: items.length,
      openCount: openCount,
      inProgressCount: inProgressCount,
      completedCount: completedCount,
      escalatedCount: escalatedCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalCount: items.length,
        overdueCount: overdueCount,
        escalatedCount: escalatedCount,
        dueSoonCount: dueSoonCount,
        inProgressCount: inProgressCount,
        openCount: openCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentDevelopmentInterventionOutcomeFollowUp> items,
  IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus status,
) {
  return items.where((item) => item.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int overdueCount,
  required int escalatedCount,
  required int dueSoonCount,
  required int inProgressCount,
  required int openCount,
}) {
  if (totalCount == 0) {
    return 'Create follow-ups for monitored intervention outcomes.';
  }
  if (overdueCount > 0) {
    return 'Clear $overdueCount overdue intervention outcome follow-ups.';
  }
  if (escalatedCount > 0) {
    return 'Review $escalatedCount escalated intervention outcome follow-ups.';
  }
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount intervention outcome follow-ups due soon.';
  }
  if (inProgressCount > 0) {
    return 'Close $inProgressCount in-progress intervention outcome follow-ups.';
  }
  if (openCount > 0) {
    return 'Start $openCount intervention outcome follow-ups.';
  }
  return 'Intervention outcome follow-ups are current.';
}
