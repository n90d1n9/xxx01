import 'incoming_talent_risk_council_agenda_item.dart';

class IncomingTalentRiskCouncilAgendaSummary {
  final int totalCount;
  final int criticalCount;
  final int highCount;
  final int normalCount;
  final int clearCount;
  final int totalTimeboxMinutes;
  final int sourceSignalCount;
  final int readinessTaskCount;
  final String nextAction;

  const IncomingTalentRiskCouncilAgendaSummary({
    required this.totalCount,
    required this.criticalCount,
    required this.highCount,
    required this.normalCount,
    required this.clearCount,
    required this.totalTimeboxMinutes,
    required this.sourceSignalCount,
    required this.readinessTaskCount,
    required this.nextAction,
  });

  factory IncomingTalentRiskCouncilAgendaSummary.fromItems(
    List<IncomingTalentRiskCouncilAgendaItem> items,
  ) {
    final criticalCount = _countByPriority(
      items,
      IncomingTalentRiskCouncilAgendaPriority.critical,
    );
    final highCount = _countByPriority(
      items,
      IncomingTalentRiskCouncilAgendaPriority.high,
    );
    final normalCount = _countByPriority(
      items,
      IncomingTalentRiskCouncilAgendaPriority.normal,
    );
    final clearCount = _countByPriority(
      items,
      IncomingTalentRiskCouncilAgendaPriority.clear,
    );
    final totalTimeboxMinutes = items.fold<int>(0, (sum, item) {
      return sum + item.timeboxMinutes;
    });
    final sourceSignalCount = items.fold<int>(0, (sum, item) {
      return sum + item.sourceCount;
    });
    final readinessTaskCount =
        items.expand((item) => item.readinessTaskIds).toSet().length;

    return IncomingTalentRiskCouncilAgendaSummary(
      totalCount: items.length,
      criticalCount: criticalCount,
      highCount: highCount,
      normalCount: normalCount,
      clearCount: clearCount,
      totalTimeboxMinutes: totalTimeboxMinutes,
      sourceSignalCount: sourceSignalCount,
      readinessTaskCount: readinessTaskCount,
      nextAction: _nextAction(
        totalCount: items.length,
        criticalCount: criticalCount,
        highCount: highCount,
        clearCount: clearCount,
      ),
    );
  }
}

int _countByPriority(
  List<IncomingTalentRiskCouncilAgendaItem> items,
  IncomingTalentRiskCouncilAgendaPriority priority,
) {
  return items.where((item) => item.priority == priority).length;
}

String _nextAction({
  required int totalCount,
  required int criticalCount,
  required int highCount,
  required int clearCount,
}) {
  if (totalCount == 0 || clearCount == totalCount) {
    return 'Council agenda is clear; confirm the next review date.';
  }
  if (criticalCount > 0) {
    return 'Start council with $criticalCount critical agenda ${_plural(criticalCount, 'item')}.';
  }
  if (highCount > 0) {
    return 'Review $highCount high-priority agenda ${_plural(highCount, 'item')} before council closes.';
  }
  return 'Run the council agenda and confirm owners before close.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
