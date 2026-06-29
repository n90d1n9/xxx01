import 'incoming_talent_operating_escalation.dart';

/// Summary metrics and recommended action for talent operating escalations.
class IncomingTalentOperatingEscalationSummary {
  final int totalCount;
  final int criticalCount;
  final int highCount;
  final int watchCount;
  final int overdueCount;
  final int dueTodayCount;
  final int cadenceCount;
  final int ownerReliefCount;
  final int workstreamPressureCount;
  final int inboxItemCount;
  final String nextAction;

  const IncomingTalentOperatingEscalationSummary({
    required this.totalCount,
    required this.criticalCount,
    required this.highCount,
    required this.watchCount,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.cadenceCount,
    required this.ownerReliefCount,
    required this.workstreamPressureCount,
    required this.inboxItemCount,
    required this.nextAction,
  });

  factory IncomingTalentOperatingEscalationSummary.fromItems(
    List<IncomingTalentOperatingEscalationItem> items,
  ) {
    final criticalCount = _countBySeverity(
      items,
      IncomingTalentOperatingEscalationSeverity.critical,
    );
    final highCount = _countBySeverity(
      items,
      IncomingTalentOperatingEscalationSeverity.high,
    );
    final watchCount = _countBySeverity(
      items,
      IncomingTalentOperatingEscalationSeverity.watch,
    );
    final overdueCount = items.where((item) => item.overdue).length;
    final dueTodayCount = items.where((item) => item.dueToday).length;
    final cadenceCount = _countBySource(
      items,
      IncomingTalentOperatingEscalationSource.cadence,
    );
    final ownerReliefCount = _countBySource(
      items,
      IncomingTalentOperatingEscalationSource.ownerRebalance,
    );
    final workstreamPressureCount = _countBySource(
      items,
      IncomingTalentOperatingEscalationSource.workstreamPressure,
    );
    final inboxItemCount = _countBySource(
      items,
      IncomingTalentOperatingEscalationSource.inbox,
    );

    return IncomingTalentOperatingEscalationSummary(
      totalCount: items.length,
      criticalCount: criticalCount,
      highCount: highCount,
      watchCount: watchCount,
      overdueCount: overdueCount,
      dueTodayCount: dueTodayCount,
      cadenceCount: cadenceCount,
      ownerReliefCount: ownerReliefCount,
      workstreamPressureCount: workstreamPressureCount,
      inboxItemCount: inboxItemCount,
      nextAction: _nextAction(
        totalCount: items.length,
        criticalCount: criticalCount,
        highCount: highCount,
        overdueCount: overdueCount,
        dueTodayCount: dueTodayCount,
        ownerReliefCount: ownerReliefCount,
      ),
    );
  }
}

int _countBySeverity(
  List<IncomingTalentOperatingEscalationItem> items,
  IncomingTalentOperatingEscalationSeverity severity,
) {
  return items.where((item) => item.severity == severity).length;
}

int _countBySource(
  List<IncomingTalentOperatingEscalationItem> items,
  IncomingTalentOperatingEscalationSource source,
) {
  return items.where((item) => item.source == source).length;
}

String _nextAction({
  required int totalCount,
  required int criticalCount,
  required int highCount,
  required int overdueCount,
  required int dueTodayCount,
  required int ownerReliefCount,
}) {
  if (totalCount == 0) return 'Talent escalation board is clear.';
  if (criticalCount > 0) {
    return 'Clear $criticalCount critical talent ${_plural(criticalCount, 'escalation')}.';
  }
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue talent ${_plural(overdueCount, 'escalation')}.';
  }
  if (dueTodayCount > 0) {
    return 'Close $dueTodayCount talent ${_plural(dueTodayCount, 'escalation')} due today.';
  }
  if (ownerReliefCount > 0) {
    return 'Rebalance $ownerReliefCount talent owner ${_plural(ownerReliefCount, 'escalation')}.';
  }
  if (highCount > 0) {
    return 'Resolve $highCount high-priority talent ${_plural(highCount, 'escalation')}.';
  }
  return 'Track $totalCount talent operating ${_plural(totalCount, 'signal')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
