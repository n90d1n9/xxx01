import 'incoming_talent_operating_evidence_gap.dart';

/// Summary metrics for auditable evidence gaps in talent operations.
class IncomingTalentOperatingEvidenceGapSummary {
  final int totalCount;
  final int criticalCount;
  final int highCount;
  final int watchCount;
  final int overdueCount;
  final int dueTodayCount;
  final int linkedEscalationCount;
  final int ownerCount;
  final int workstreamCount;
  final String nextAction;

  const IncomingTalentOperatingEvidenceGapSummary({
    required this.totalCount,
    required this.criticalCount,
    required this.highCount,
    required this.watchCount,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.linkedEscalationCount,
    required this.ownerCount,
    required this.workstreamCount,
    required this.nextAction,
  });

  factory IncomingTalentOperatingEvidenceGapSummary.fromItems(
    List<IncomingTalentOperatingEvidenceGap> items,
  ) {
    final criticalCount = _countByRisk(
      items,
      IncomingTalentOperatingEvidenceGapRisk.critical,
    );
    final highCount = _countByRisk(
      items,
      IncomingTalentOperatingEvidenceGapRisk.high,
    );
    final watchCount = _countByRisk(
      items,
      IncomingTalentOperatingEvidenceGapRisk.watch,
    );
    final overdueCount = items.where((item) => item.overdue).length;
    final dueTodayCount = items.where((item) => item.dueToday).length;
    final linkedEscalationCount =
        items.where((item) => item.hasEscalationLink).length;
    final ownerCount = items.map((item) => item.ownerName).toSet().length;
    final workstreamCount =
        items.map((item) => item.workstreamLabel).toSet().length;

    return IncomingTalentOperatingEvidenceGapSummary(
      totalCount: items.length,
      criticalCount: criticalCount,
      highCount: highCount,
      watchCount: watchCount,
      overdueCount: overdueCount,
      dueTodayCount: dueTodayCount,
      linkedEscalationCount: linkedEscalationCount,
      ownerCount: ownerCount,
      workstreamCount: workstreamCount,
      nextAction: _nextAction(
        totalCount: items.length,
        criticalCount: criticalCount,
        highCount: highCount,
        overdueCount: overdueCount,
        dueTodayCount: dueTodayCount,
        linkedEscalationCount: linkedEscalationCount,
      ),
    );
  }
}

int _countByRisk(
  List<IncomingTalentOperatingEvidenceGap> items,
  IncomingTalentOperatingEvidenceGapRisk risk,
) {
  return items.where((item) => item.risk == risk).length;
}

String _nextAction({
  required int totalCount,
  required int criticalCount,
  required int highCount,
  required int overdueCount,
  required int dueTodayCount,
  required int linkedEscalationCount,
}) {
  if (totalCount == 0) return 'Talent evidence gaps are clear.';
  if (criticalCount > 0) {
    return 'Close $criticalCount critical talent evidence ${_plural(criticalCount, 'gap')}.';
  }
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue talent evidence ${_plural(overdueCount, 'gap')}.';
  }
  if (dueTodayCount > 0) {
    return 'Close $dueTodayCount talent evidence ${_plural(dueTodayCount, 'gap')} due today.';
  }
  if (linkedEscalationCount > 0) {
    return 'Attach evidence for $linkedEscalationCount escalated talent ${_plural(linkedEscalationCount, 'item')}.';
  }
  if (highCount > 0) {
    return 'Prepare $highCount high-priority talent evidence ${_plural(highCount, 'gap')}.';
  }
  return 'Track $totalCount talent evidence ${_plural(totalCount, 'gap')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
