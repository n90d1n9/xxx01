import 'incoming_talent_promotion_implementation.dart';

/// Aggregates promotion implementation work into operational metrics.
class IncomingTalentPromotionImplementationSummary {
  final int totalCount;
  final int plannedCount;
  final int inProgressCount;
  final int blockedCount;
  final int completedCount;
  final int cancelledCount;
  final int attentionCount;
  final int dueSoonCount;
  final int titleUpdateCount;
  final int compensationRouteCount;
  final double averageProgress;
  final String nextAction;

  const IncomingTalentPromotionImplementationSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.inProgressCount,
    required this.blockedCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.attentionCount,
    required this.dueSoonCount,
    required this.titleUpdateCount,
    required this.compensationRouteCount,
    required this.averageProgress,
    required this.nextAction,
  });

  factory IncomingTalentPromotionImplementationSummary.fromImplementations({
    required List<IncomingTalentPromotionImplementation> implementations,
    required DateTime asOfDate,
  }) {
    final plannedCount = _countStatus(
      implementations,
      IncomingTalentPromotionImplementationStatus.planned,
    );
    final inProgressCount = _countStatus(
      implementations,
      IncomingTalentPromotionImplementationStatus.inProgress,
    );
    final blockedCount = _countStatus(
      implementations,
      IncomingTalentPromotionImplementationStatus.blocked,
    );
    final completedCount = _countStatus(
      implementations,
      IncomingTalentPromotionImplementationStatus.completed,
    );
    final cancelledCount = _countStatus(
      implementations,
      IncomingTalentPromotionImplementationStatus.cancelled,
    );
    final attentionCount =
        implementations.where((item) => item.needsAttention).length;
    final dueSoonCount =
        implementations
            .where(
              (item) =>
                  !item.isClosed &&
                  !item.dueDate.isAfter(asOfDate.add(const Duration(days: 14))),
            )
            .length;
    final progressTotal = implementations.fold<double>(
      0,
      (total, item) => total + item.progressRatio,
    );

    return IncomingTalentPromotionImplementationSummary(
      totalCount: implementations.length,
      plannedCount: plannedCount,
      inProgressCount: inProgressCount,
      blockedCount: blockedCount,
      completedCount: completedCount,
      cancelledCount: cancelledCount,
      attentionCount: attentionCount,
      dueSoonCount: dueSoonCount,
      titleUpdateCount: _countAction(
        implementations,
        IncomingTalentPromotionImplementationAction.titleUpdate,
      ),
      compensationRouteCount: _countAction(
        implementations,
        IncomingTalentPromotionImplementationAction.compensationRoute,
      ),
      averageProgress:
          implementations.isEmpty ? 0 : progressTotal / implementations.length,
      nextAction: _nextAction(
        totalCount: implementations.length,
        blockedCount: blockedCount,
        cancelledCount: cancelledCount,
        dueSoonCount: dueSoonCount,
        inProgressCount: inProgressCount,
        plannedCount: plannedCount,
      ),
    );
  }
}

int _countStatus(
  List<IncomingTalentPromotionImplementation> implementations,
  IncomingTalentPromotionImplementationStatus status,
) {
  return implementations.where((item) => item.status == status).length;
}

int _countAction(
  List<IncomingTalentPromotionImplementation> implementations,
  IncomingTalentPromotionImplementationAction action,
) {
  return implementations.where((item) => item.action == action).length;
}

String _nextAction({
  required int totalCount,
  required int blockedCount,
  required int cancelledCount,
  required int dueSoonCount,
  required int inProgressCount,
  required int plannedCount,
}) {
  if (totalCount == 0) {
    return 'Create implementation packets for promotion decisions.';
  }
  if (blockedCount > 0 || cancelledCount > 0) {
    return 'Resolve $blockedCount blocked promotion implementations.';
  }
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount promotion implementations due soon.';
  }
  if (inProgressCount > 0) {
    return 'Track $inProgressCount promotion implementations in progress.';
  }
  if (plannedCount > 0) {
    return 'Start $plannedCount planned promotion implementations.';
  }
  return 'Archive completed promotion implementation evidence.';
}
