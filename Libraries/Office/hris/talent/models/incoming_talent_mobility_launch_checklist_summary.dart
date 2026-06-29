import 'incoming_talent_mobility_launch_checklist.dart';

class IncomingTalentMobilityLaunchChecklistSummary {
  final int totalCount;
  final int plannedCount;
  final int readyCount;
  final int blockedCount;
  final int launchedCount;
  final int dueSoonCount;
  final int incompleteCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentMobilityLaunchChecklistSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.readyCount,
    required this.blockedCount,
    required this.launchedCount,
    required this.dueSoonCount,
    required this.incompleteCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentMobilityLaunchChecklistSummary.fromChecklists({
    required List<IncomingTalentMobilityLaunchChecklist> checklists,
    required DateTime asOfDate,
  }) {
    final plannedCount = _countByStatus(
      checklists,
      IncomingTalentMobilityLaunchStatus.planned,
    );
    final readyCount = _countByStatus(
      checklists,
      IncomingTalentMobilityLaunchStatus.ready,
    );
    final blockedCount = _countByStatus(
      checklists,
      IncomingTalentMobilityLaunchStatus.blocked,
    );
    final launchedCount = _countByStatus(
      checklists,
      IncomingTalentMobilityLaunchStatus.launched,
    );
    final dueSoonCount =
        checklists.where((item) => item.isDueSoon(asOfDate)).length;
    final incompleteCount =
        checklists
            .where(
              (item) =>
                  item.status != IncomingTalentMobilityLaunchStatus.launched &&
                  !item.allGatesReady,
            )
            .length;
    final attentionCount =
        checklists.where((item) => item.needsAttention).length;

    return IncomingTalentMobilityLaunchChecklistSummary(
      totalCount: checklists.length,
      plannedCount: plannedCount,
      readyCount: readyCount,
      blockedCount: blockedCount,
      launchedCount: launchedCount,
      dueSoonCount: dueSoonCount,
      incompleteCount: incompleteCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalCount: checklists.length,
        plannedCount: plannedCount,
        readyCount: readyCount,
        blockedCount: blockedCount,
        launchedCount: launchedCount,
        incompleteCount: incompleteCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentMobilityLaunchChecklist> checklists,
  IncomingTalentMobilityLaunchStatus status,
) {
  return checklists.where((item) => item.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int plannedCount,
  required int readyCount,
  required int blockedCount,
  required int launchedCount,
  required int incompleteCount,
}) {
  if (totalCount == 0) return 'Prepare accepted mobility moves for launch.';
  if (blockedCount > 0) return 'Unblock $blockedCount mobility launches.';
  if (incompleteCount > 0) {
    return 'Close $incompleteCount mobility launch checklists.';
  }
  if (readyCount > 0) return 'Launch $readyCount ready mobility moves.';
  if (plannedCount > 0) return 'Prepare $plannedCount planned launches.';
  if (launchedCount > 0) return 'Review $launchedCount launched moves.';
  return 'Mobility launch readiness is current.';
}
