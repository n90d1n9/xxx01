import 'incoming_talent_succession_coverage_council_follow_up.dart';

class IncomingTalentSuccessionCoverageCouncilFollowUpSummary {
  final int totalCount;
  final int plannedCount;
  final int inProgressCount;
  final int blockedCount;
  final int escalatedCount;
  final int completedCount;
  final int dueSoonCount;
  final int overdueCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentSuccessionCoverageCouncilFollowUpSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.inProgressCount,
    required this.blockedCount,
    required this.escalatedCount,
    required this.completedCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionCoverageCouncilFollowUpSummary.fromFollowUps({
    required List<IncomingTalentSuccessionCoverageCouncilFollowUp> followUps,
    required DateTime asOfDate,
  }) {
    final plannedCount = _countByStatus(
      followUps,
      IncomingTalentSuccessionCoverageCouncilFollowUpStatus.planned,
    );
    final inProgressCount = _countByStatus(
      followUps,
      IncomingTalentSuccessionCoverageCouncilFollowUpStatus.inProgress,
    );
    final blockedCount = _countByStatus(
      followUps,
      IncomingTalentSuccessionCoverageCouncilFollowUpStatus.blocked,
    );
    final escalatedCount = _countByStatus(
      followUps,
      IncomingTalentSuccessionCoverageCouncilFollowUpStatus.escalated,
    );
    final completedCount = _countByStatus(
      followUps,
      IncomingTalentSuccessionCoverageCouncilFollowUpStatus.completed,
    );
    final dueSoonCount =
        followUps.where((followUp) => followUp.isDueSoon(asOfDate)).length;
    final overdueCount =
        followUps.where((followUp) => followUp.isOverdue(asOfDate)).length;
    final attentionCount =
        followUps.where((followUp) => followUp.needsAttention).length;

    return IncomingTalentSuccessionCoverageCouncilFollowUpSummary(
      totalCount: followUps.length,
      plannedCount: plannedCount,
      inProgressCount: inProgressCount,
      blockedCount: blockedCount,
      escalatedCount: escalatedCount,
      completedCount: completedCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalCount: followUps.length,
        plannedCount: plannedCount,
        inProgressCount: inProgressCount,
        blockedCount: blockedCount,
        escalatedCount: escalatedCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentSuccessionCoverageCouncilFollowUp> followUps,
  IncomingTalentSuccessionCoverageCouncilFollowUpStatus status,
) {
  return followUps.where((followUp) => followUp.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int plannedCount,
  required int inProgressCount,
  required int blockedCount,
  required int escalatedCount,
  required int dueSoonCount,
  required int overdueCount,
}) {
  if (totalCount == 0) return 'Create follow-ups from council decisions.';
  if (blockedCount > 0) return 'Unblock $blockedCount council follow-ups.';
  if (escalatedCount > 0) {
    return 'Track $escalatedCount escalated follow-ups with people leadership.';
  }
  if (overdueCount > 0) return 'Close $overdueCount overdue follow-ups.';
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount council follow-ups due soon.';
  }
  if (plannedCount > 0) return 'Start $plannedCount planned follow-ups.';
  if (inProgressCount > 0) {
    return 'Track $inProgressCount council follow-ups in progress.';
  }
  return 'Council decision follow-ups are complete.';
}
