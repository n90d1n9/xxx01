import 'incoming_talent_operating_sla_item.dart';

/// Summary of cross-HRIS talent operating SLA health.
class IncomingTalentOperatingSlaSummary {
  final int itemCount;
  final int overdueCount;
  final int dueTodayCount;
  final int atRiskCount;
  final int onTrackCount;
  final int ownerCount;
  final int sourceCount;
  final int evidenceCount;
  final String nextAction;

  const IncomingTalentOperatingSlaSummary({
    required this.itemCount,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.atRiskCount,
    required this.onTrackCount,
    required this.ownerCount,
    required this.sourceCount,
    required this.evidenceCount,
    required this.nextAction,
  });

  factory IncomingTalentOperatingSlaSummary.fromItems(
    List<IncomingTalentOperatingSlaItem> items,
  ) {
    final overdueCount = _countByStatus(
      items,
      IncomingTalentOperatingSlaStatus.overdue,
    );
    final dueTodayCount = _countByStatus(
      items,
      IncomingTalentOperatingSlaStatus.dueToday,
    );
    final atRiskCount = _countByStatus(
      items,
      IncomingTalentOperatingSlaStatus.atRisk,
    );
    final onTrackCount = _countByStatus(
      items,
      IncomingTalentOperatingSlaStatus.onTrack,
    );
    final ownerCount = items.map((item) => item.ownerName).toSet().length;
    final sourceCount = items.map((item) => item.source).toSet().length;
    final evidenceCount = items.fold<int>(
      0,
      (total, item) => total + item.evidenceCount,
    );

    return IncomingTalentOperatingSlaSummary(
      itemCount: items.length,
      overdueCount: overdueCount,
      dueTodayCount: dueTodayCount,
      atRiskCount: atRiskCount,
      onTrackCount: onTrackCount,
      ownerCount: ownerCount,
      sourceCount: sourceCount,
      evidenceCount: evidenceCount,
      nextAction: _nextAction(
        itemCount: items.length,
        overdueCount: overdueCount,
        dueTodayCount: dueTodayCount,
        atRiskCount: atRiskCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentOperatingSlaItem> items,
  IncomingTalentOperatingSlaStatus status,
) {
  return items.where((item) => item.status == status).length;
}

String _nextAction({
  required int itemCount,
  required int overdueCount,
  required int dueTodayCount,
  required int atRiskCount,
}) {
  if (itemCount == 0) return 'Talent operating SLAs are clear.';
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue talent operating SLA ${_plural(overdueCount, 'item')}.';
  }
  if (dueTodayCount > 0) {
    return 'Close $dueTodayCount talent operating SLA ${_plural(dueTodayCount, 'item')} due today.';
  }
  if (atRiskCount > 0) {
    return 'Stabilize $atRiskCount at-risk talent operating SLA ${_plural(atRiskCount, 'item')}.';
  }
  return 'Keep $itemCount talent operating SLA ${_plural(itemCount, 'item')} on track.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
