import 'incoming_talent_operating_workstream_pressure.dart';

/// Summary of cross-workstream pressure in the talent operating inbox.
class IncomingTalentOperatingWorkstreamPressureSummary {
  final int workstreamCount;
  final int activeWorkstreamCount;
  final int criticalWorkstreamCount;
  final int elevatedWorkstreamCount;
  final int totalItemCount;
  final int criticalItemCount;
  final int overdueItemCount;
  final int overloadedOwnerCount;
  final String nextAction;

  const IncomingTalentOperatingWorkstreamPressureSummary({
    required this.workstreamCount,
    required this.activeWorkstreamCount,
    required this.criticalWorkstreamCount,
    required this.elevatedWorkstreamCount,
    required this.totalItemCount,
    required this.criticalItemCount,
    required this.overdueItemCount,
    required this.overloadedOwnerCount,
    required this.nextAction,
  });

  factory IncomingTalentOperatingWorkstreamPressureSummary.fromItems(
    List<IncomingTalentOperatingWorkstreamPressure> items,
  ) {
    final activeWorkstreamCount =
        items.where((item) => item.totalCount > 0).length;
    final criticalWorkstreamCount = _countByLevel(
      items,
      IncomingTalentOperatingWorkstreamPressureLevel.critical,
    );
    final elevatedWorkstreamCount = _countByLevel(
      items,
      IncomingTalentOperatingWorkstreamPressureLevel.elevated,
    );
    final totalItemCount = items.fold<int>(
      0,
      (sum, item) => sum + item.totalCount,
    );
    final criticalItemCount = items.fold<int>(
      0,
      (sum, item) => sum + item.criticalCount,
    );
    final overdueItemCount = items.fold<int>(
      0,
      (sum, item) => sum + item.overdueCount,
    );
    final overloadedOwnerCount = items.fold<int>(
      0,
      (sum, item) => sum + item.overloadedOwnerCount,
    );

    return IncomingTalentOperatingWorkstreamPressureSummary(
      workstreamCount: items.length,
      activeWorkstreamCount: activeWorkstreamCount,
      criticalWorkstreamCount: criticalWorkstreamCount,
      elevatedWorkstreamCount: elevatedWorkstreamCount,
      totalItemCount: totalItemCount,
      criticalItemCount: criticalItemCount,
      overdueItemCount: overdueItemCount,
      overloadedOwnerCount: overloadedOwnerCount,
      nextAction: _nextAction(
        activeWorkstreamCount: activeWorkstreamCount,
        criticalWorkstreamCount: criticalWorkstreamCount,
        elevatedWorkstreamCount: elevatedWorkstreamCount,
        overdueItemCount: overdueItemCount,
        overloadedOwnerCount: overloadedOwnerCount,
        totalItemCount: totalItemCount,
      ),
    );
  }
}

int _countByLevel(
  List<IncomingTalentOperatingWorkstreamPressure> items,
  IncomingTalentOperatingWorkstreamPressureLevel level,
) {
  return items.where((item) => item.level == level).length;
}

String _nextAction({
  required int activeWorkstreamCount,
  required int criticalWorkstreamCount,
  required int elevatedWorkstreamCount,
  required int overdueItemCount,
  required int overloadedOwnerCount,
  required int totalItemCount,
}) {
  if (activeWorkstreamCount == 0) {
    return 'Talent workstream pressure is clear.';
  }
  if (criticalWorkstreamCount > 0) {
    return 'Stabilize $criticalWorkstreamCount critical talent ${_plural(criticalWorkstreamCount, 'workstream')}.';
  }
  if (overdueItemCount > 0) {
    return 'Recover $overdueItemCount overdue talent workstream ${_plural(overdueItemCount, 'item')}.';
  }
  if (overloadedOwnerCount > 0) {
    return 'Rebalance $overloadedOwnerCount overloaded workstream ${_plural(overloadedOwnerCount, 'owner')}.';
  }
  if (elevatedWorkstreamCount > 0) {
    return 'Support $elevatedWorkstreamCount elevated talent ${_plural(elevatedWorkstreamCount, 'workstream')}.';
  }
  return 'Track $totalItemCount active talent workstream ${_plural(totalItemCount, 'item')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
