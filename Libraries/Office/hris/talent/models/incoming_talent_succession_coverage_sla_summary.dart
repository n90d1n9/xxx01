import 'incoming_talent_succession_coverage_sla_item.dart';

class IncomingTalentSuccessionCoverageSlaSummary {
  final int totalCount;
  final int blockedCount;
  final int escalatedCount;
  final int overdueCount;
  final int dueSoonCount;
  final int waitingCouncilCount;
  final int waitingFollowUpCount;
  final String nextAction;

  const IncomingTalentSuccessionCoverageSlaSummary({
    required this.totalCount,
    required this.blockedCount,
    required this.escalatedCount,
    required this.overdueCount,
    required this.dueSoonCount,
    required this.waitingCouncilCount,
    required this.waitingFollowUpCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionCoverageSlaSummary.fromItems(
    List<IncomingTalentSuccessionCoverageSlaItem> items,
  ) {
    final blockedCount = _countByStatus(
      items,
      IncomingTalentSuccessionCoverageSlaStatus.blocked,
    );
    final escalatedCount = _countByStatus(
      items,
      IncomingTalentSuccessionCoverageSlaStatus.escalated,
    );
    final overdueCount = _countByStatus(
      items,
      IncomingTalentSuccessionCoverageSlaStatus.overdue,
    );
    final dueSoonCount = _countByStatus(
      items,
      IncomingTalentSuccessionCoverageSlaStatus.dueSoon,
    );
    final waitingCouncilCount =
        items
            .where(
              (item) =>
                  item.source ==
                  IncomingTalentSuccessionCoverageSlaSource.councilDecision,
            )
            .length;
    final waitingFollowUpCount =
        items
            .where(
              (item) =>
                  item.source ==
                  IncomingTalentSuccessionCoverageSlaSource.councilFollowUp,
            )
            .length;

    return IncomingTalentSuccessionCoverageSlaSummary(
      totalCount: items.length,
      blockedCount: blockedCount,
      escalatedCount: escalatedCount,
      overdueCount: overdueCount,
      dueSoonCount: dueSoonCount,
      waitingCouncilCount: waitingCouncilCount,
      waitingFollowUpCount: waitingFollowUpCount,
      nextAction: _nextAction(
        totalCount: items.length,
        blockedCount: blockedCount,
        escalatedCount: escalatedCount,
        overdueCount: overdueCount,
        dueSoonCount: dueSoonCount,
        waitingCouncilCount: waitingCouncilCount,
        waitingFollowUpCount: waitingFollowUpCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentSuccessionCoverageSlaItem> items,
  IncomingTalentSuccessionCoverageSlaStatus status,
) {
  return items.where((item) => item.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int blockedCount,
  required int escalatedCount,
  required int overdueCount,
  required int dueSoonCount,
  required int waitingCouncilCount,
  required int waitingFollowUpCount,
}) {
  if (totalCount == 0) return 'Succession coverage SLAs are clear.';
  if (blockedCount > 0) return 'Unblock $blockedCount coverage SLA items.';
  if (escalatedCount > 0) {
    return 'Track $escalatedCount escalated coverage SLA items.';
  }
  if (overdueCount > 0) return 'Recover $overdueCount overdue SLA items.';
  if (dueSoonCount > 0) return 'Close $dueSoonCount SLA items due soon.';
  if (waitingCouncilCount > 0) {
    return 'Prepare $waitingCouncilCount council decisions.';
  }
  if (waitingFollowUpCount > 0) {
    return 'Create $waitingFollowUpCount council follow-ups.';
  }
  return 'Monitor $totalCount active coverage SLA items.';
}
