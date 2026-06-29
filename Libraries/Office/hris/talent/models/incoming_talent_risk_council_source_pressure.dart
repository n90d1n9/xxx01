import 'incoming_talent_risk_council_queue_item.dart';
import 'incoming_talent_risk_council_sla_item.dart';

/// Source-level pressure band for talent risk council triage.
enum IncomingTalentRiskCouncilSourcePressureLevel {
  critical('Critical'),
  watch('Watch'),
  steady('Steady');

  final String label;

  const IncomingTalentRiskCouncilSourcePressureLevel(this.label);
}

/// Aggregated SLA pressure for one upstream talent risk council source.
class IncomingTalentRiskCouncilSourcePressure {
  final IncomingTalentRiskCouncilQueueSource source;
  final IncomingTalentRiskCouncilSourcePressureLevel level;
  final int totalCount;
  final int candidateCount;
  final int blockedCount;
  final int escalatedCount;
  final int overdueCount;
  final int dueSoonCount;
  final int waitingDecisionCount;
  final int waitingFollowUpCount;
  final int activeFollowUpCount;
  final String nextAction;

  const IncomingTalentRiskCouncilSourcePressure({
    required this.source,
    required this.level,
    required this.totalCount,
    required this.candidateCount,
    required this.blockedCount,
    required this.escalatedCount,
    required this.overdueCount,
    required this.dueSoonCount,
    required this.waitingDecisionCount,
    required this.waitingFollowUpCount,
    required this.activeFollowUpCount,
    required this.nextAction,
  });

  factory IncomingTalentRiskCouncilSourcePressure.fromItems({
    required IncomingTalentRiskCouncilQueueSource source,
    required List<IncomingTalentRiskCouncilSlaItem> items,
  }) {
    final blockedCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilSlaStatus.blocked,
    );
    final escalatedCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilSlaStatus.escalated,
    );
    final overdueCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilSlaStatus.overdue,
    );
    final dueSoonCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilSlaStatus.dueSoon,
    );
    final waitingDecisionCount = _countBySlaSource(
      items,
      IncomingTalentRiskCouncilSlaSource.councilDecision,
    );
    final waitingFollowUpCount = _countBySlaSource(
      items,
      IncomingTalentRiskCouncilSlaSource.councilFollowUp,
    );
    final activeFollowUpCount = _countBySlaSource(
      items,
      IncomingTalentRiskCouncilSlaSource.followUpExecution,
    );
    final urgentCount = blockedCount + escalatedCount + overdueCount;

    return IncomingTalentRiskCouncilSourcePressure(
      source: source,
      level: _level(
        urgentCount: urgentCount,
        dueSoonCount: dueSoonCount,
        totalCount: items.length,
      ),
      totalCount: items.length,
      candidateCount: items.map((item) => item.candidateName).toSet().length,
      blockedCount: blockedCount,
      escalatedCount: escalatedCount,
      overdueCount: overdueCount,
      dueSoonCount: dueSoonCount,
      waitingDecisionCount: waitingDecisionCount,
      waitingFollowUpCount: waitingFollowUpCount,
      activeFollowUpCount: activeFollowUpCount,
      nextAction: _nextAction(
        source: source,
        totalCount: items.length,
        blockedCount: blockedCount,
        escalatedCount: escalatedCount,
        overdueCount: overdueCount,
        dueSoonCount: dueSoonCount,
        waitingDecisionCount: waitingDecisionCount,
        waitingFollowUpCount: waitingFollowUpCount,
        activeFollowUpCount: activeFollowUpCount,
      ),
    );
  }

  static List<IncomingTalentRiskCouncilSourcePressure> fromSlaItems(
    List<IncomingTalentRiskCouncilSlaItem> items,
  ) {
    final grouped =
        <
          IncomingTalentRiskCouncilQueueSource,
          List<IncomingTalentRiskCouncilSlaItem>
        >{};

    for (final item in items) {
      grouped.putIfAbsent(item.councilSource, () => []).add(item);
    }

    return [
      for (final entry in grouped.entries)
        IncomingTalentRiskCouncilSourcePressure.fromItems(
          source: entry.key,
          items: entry.value,
        ),
    ]..sort(_comparePressure);
  }

  int get urgentCount => blockedCount + escalatedCount + overdueCount;

  int get attentionCount => urgentCount + dueSoonCount;

  double get pressureRatio {
    if (totalCount == 0) return 0;

    final score =
        (urgentCount * 2) +
        dueSoonCount +
        waitingDecisionCount +
        waitingFollowUpCount +
        activeFollowUpCount;
    final ratio = score / (totalCount * 3);

    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }
}

int _comparePressure(
  IncomingTalentRiskCouncilSourcePressure left,
  IncomingTalentRiskCouncilSourcePressure right,
) {
  final level = left.level.index.compareTo(right.level.index);
  if (level != 0) return level;

  final attention = right.attentionCount.compareTo(left.attentionCount);
  if (attention != 0) return attention;

  final total = right.totalCount.compareTo(left.totalCount);
  if (total != 0) return total;

  return left.source.label.compareTo(right.source.label);
}

int _countByStatus(
  List<IncomingTalentRiskCouncilSlaItem> items,
  IncomingTalentRiskCouncilSlaStatus status,
) {
  return items.where((item) => item.status == status).length;
}

int _countBySlaSource(
  List<IncomingTalentRiskCouncilSlaItem> items,
  IncomingTalentRiskCouncilSlaSource source,
) {
  return items.where((item) => item.source == source).length;
}

IncomingTalentRiskCouncilSourcePressureLevel _level({
  required int urgentCount,
  required int dueSoonCount,
  required int totalCount,
}) {
  if (urgentCount > 0) {
    return IncomingTalentRiskCouncilSourcePressureLevel.critical;
  }
  if (dueSoonCount > 0 || totalCount > 0) {
    return IncomingTalentRiskCouncilSourcePressureLevel.watch;
  }
  return IncomingTalentRiskCouncilSourcePressureLevel.steady;
}

String _nextAction({
  required IncomingTalentRiskCouncilQueueSource source,
  required int totalCount,
  required int blockedCount,
  required int escalatedCount,
  required int overdueCount,
  required int dueSoonCount,
  required int waitingDecisionCount,
  required int waitingFollowUpCount,
  required int activeFollowUpCount,
}) {
  final label = source.label.toLowerCase();

  if (totalCount == 0) return 'No $label council pressure.';
  if (blockedCount > 0) {
    return 'Unblock $blockedCount $label SLA ${_plural(blockedCount, 'item')}.';
  }
  if (escalatedCount > 0) {
    return 'Track $escalatedCount escalated $label SLA ${_plural(escalatedCount, 'item')}.';
  }
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue $label SLA ${_plural(overdueCount, 'item')}.';
  }
  if (dueSoonCount > 0) {
    return 'Close $dueSoonCount $label SLA ${_plural(dueSoonCount, 'item')} due soon.';
  }
  if (waitingDecisionCount > 0) {
    return 'Prepare $waitingDecisionCount $label council ${_plural(waitingDecisionCount, 'decision')}.';
  }
  if (waitingFollowUpCount > 0) {
    return 'Create $waitingFollowUpCount $label ${_plural(waitingFollowUpCount, 'follow-up')}.';
  }
  if (activeFollowUpCount > 0) {
    return 'Track $activeFollowUpCount active $label ${_plural(activeFollowUpCount, 'follow-up')}.';
  }
  return 'Monitor $totalCount $label SLA ${_plural(totalCount, 'item')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
