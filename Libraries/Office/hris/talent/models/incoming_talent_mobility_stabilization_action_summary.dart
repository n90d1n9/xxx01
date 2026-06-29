import 'incoming_talent_mobility_stabilization_action.dart';

class IncomingTalentMobilityStabilizationActionSummary {
  final int totalCount;
  final int plannedCount;
  final int inProgressCount;
  final int blockedCount;
  final int completedCount;
  final int dueSoonCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentMobilityStabilizationActionSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.inProgressCount,
    required this.blockedCount,
    required this.completedCount,
    required this.dueSoonCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentMobilityStabilizationActionSummary.fromActions({
    required List<IncomingTalentMobilityStabilizationAction> actions,
    required DateTime asOfDate,
  }) {
    final plannedCount = _countByStatus(
      actions,
      IncomingTalentMobilityStabilizationStatus.planned,
    );
    final inProgressCount = _countByStatus(
      actions,
      IncomingTalentMobilityStabilizationStatus.inProgress,
    );
    final blockedCount = _countByStatus(
      actions,
      IncomingTalentMobilityStabilizationStatus.blocked,
    );
    final completedCount = _countByStatus(
      actions,
      IncomingTalentMobilityStabilizationStatus.completed,
    );
    final dueSoonCount =
        actions.where((action) => action.isDueSoon(asOfDate)).length;
    final attentionCount =
        actions.where((action) => action.needsAttention).length;

    return IncomingTalentMobilityStabilizationActionSummary(
      totalCount: actions.length,
      plannedCount: plannedCount,
      inProgressCount: inProgressCount,
      blockedCount: blockedCount,
      completedCount: completedCount,
      dueSoonCount: dueSoonCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalCount: actions.length,
        plannedCount: plannedCount,
        inProgressCount: inProgressCount,
        blockedCount: blockedCount,
        dueSoonCount: dueSoonCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentMobilityStabilizationAction> actions,
  IncomingTalentMobilityStabilizationStatus status,
) {
  return actions.where((action) => action.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int plannedCount,
  required int inProgressCount,
  required int blockedCount,
  required int dueSoonCount,
  required int attentionCount,
}) {
  if (totalCount == 0) return 'Create actions for risky mobility reviews.';
  if (blockedCount > 0) return 'Unblock $blockedCount mobility actions.';
  if (dueSoonCount > 0) return 'Close $dueSoonCount mobility actions due soon.';
  if (attentionCount > 0) return 'Follow up $attentionCount mobility risks.';
  if (plannedCount > 0) return 'Start $plannedCount planned mobility actions.';
  if (inProgressCount > 0) {
    return 'Track $inProgressCount active mobility actions.';
  }
  return 'Mobility stabilization actions are current.';
}
