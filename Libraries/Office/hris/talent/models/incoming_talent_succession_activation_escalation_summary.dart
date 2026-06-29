import 'incoming_talent_succession_activation_escalation.dart';

class IncomingTalentSuccessionActivationEscalationSummary {
  final int totalEscalations;
  final int openedCount;
  final int inProgressCount;
  final int resolvedCount;
  final int blockedCount;
  final int urgentCount;
  final int executiveCount;
  final int dueSoonCount;
  final int overdueCount;
  final String nextAction;

  const IncomingTalentSuccessionActivationEscalationSummary({
    required this.totalEscalations,
    required this.openedCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.blockedCount,
    required this.urgentCount,
    required this.executiveCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionActivationEscalationSummary.fromEscalations({
    required List<IncomingTalentSuccessionActivationEscalation> escalations,
    required DateTime asOfDate,
  }) {
    final openedCount =
        escalations
            .where(
              (escalation) =>
                  escalation.status ==
                  IncomingTalentSuccessionActivationEscalationStatus.opened,
            )
            .length;
    final inProgressCount =
        escalations
            .where(
              (escalation) =>
                  escalation.status ==
                  IncomingTalentSuccessionActivationEscalationStatus.inProgress,
            )
            .length;
    final resolvedCount =
        escalations
            .where(
              (escalation) =>
                  escalation.status ==
                  IncomingTalentSuccessionActivationEscalationStatus.resolved,
            )
            .length;
    final blockedCount =
        escalations
            .where(
              (escalation) =>
                  escalation.status ==
                  IncomingTalentSuccessionActivationEscalationStatus.blocked,
            )
            .length;
    final urgentCount =
        escalations
            .where(
              (escalation) =>
                  escalation.isOpen &&
                  escalation.priority ==
                      IncomingTalentSuccessionActivationEscalationPriority
                          .urgent,
            )
            .length;
    final executiveCount =
        escalations
            .where(
              (escalation) =>
                  escalation.isOpen &&
                  escalation.priority ==
                      IncomingTalentSuccessionActivationEscalationPriority
                          .executive,
            )
            .length;
    final dueSoonCount =
        escalations
            .where((escalation) => escalation.isDueSoon(asOfDate))
            .length;
    final overdueCount =
        escalations
            .where((escalation) => escalation.isOverdue(asOfDate))
            .length;

    return IncomingTalentSuccessionActivationEscalationSummary(
      totalEscalations: escalations.length,
      openedCount: openedCount,
      inProgressCount: inProgressCount,
      resolvedCount: resolvedCount,
      blockedCount: blockedCount,
      urgentCount: urgentCount,
      executiveCount: executiveCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      nextAction: _nextAction(
        totalEscalations: escalations.length,
        openedCount: openedCount,
        inProgressCount: inProgressCount,
        blockedCount: blockedCount,
        urgentCount: urgentCount,
        executiveCount: executiveCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

String _nextAction({
  required int totalEscalations,
  required int openedCount,
  required int inProgressCount,
  required int blockedCount,
  required int urgentCount,
  required int executiveCount,
  required int dueSoonCount,
  required int overdueCount,
}) {
  if (totalEscalations == 0) {
    return 'Create escalations from watched activation check-ins.';
  }
  if (blockedCount > 0) return 'Unblock $blockedCount succession escalations.';
  if (overdueCount > 0) return 'Resolve $overdueCount overdue escalations.';
  if (executiveCount > 0) {
    return 'Secure executive decisions for $executiveCount escalations.';
  }
  if (urgentCount > 0) return 'Close $urgentCount urgent escalation actions.';
  if (dueSoonCount > 0) return 'Review $dueSoonCount escalations due soon.';
  if (openedCount > 0) return 'Start $openedCount opened escalations.';
  if (inProgressCount > 0) {
    return 'Track $inProgressCount escalations in progress.';
  }
  return 'Succession activation escalations are resolved.';
}
