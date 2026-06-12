import 'incoming_talent_succession_activation_closure.dart';

class IncomingTalentSuccessionActivationClosureSummary {
  final int totalClosures;
  final int scheduledCount;
  final int activeCount;
  final int completedCount;
  final int deferredCount;
  final int dueSoonCount;
  final int overdueCount;
  final String nextAction;

  const IncomingTalentSuccessionActivationClosureSummary({
    required this.totalClosures,
    required this.scheduledCount,
    required this.activeCount,
    required this.completedCount,
    required this.deferredCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionActivationClosureSummary.fromClosures({
    required List<IncomingTalentSuccessionActivationClosure> closures,
    required DateTime asOfDate,
  }) {
    final scheduledCount =
        closures
            .where(
              (closure) =>
                  closure.status ==
                  IncomingTalentSuccessionActivationClosureStatus.scheduled,
            )
            .length;
    final activeCount =
        closures
            .where(
              (closure) =>
                  closure.status ==
                  IncomingTalentSuccessionActivationClosureStatus.active,
            )
            .length;
    final completedCount =
        closures
            .where(
              (closure) =>
                  closure.status ==
                  IncomingTalentSuccessionActivationClosureStatus.completed,
            )
            .length;
    final deferredCount =
        closures
            .where(
              (closure) =>
                  closure.status ==
                  IncomingTalentSuccessionActivationClosureStatus.deferred,
            )
            .length;
    final dueSoonCount =
        closures.where((closure) => closure.isDueSoon(asOfDate)).length;
    final overdueCount =
        closures.where((closure) => closure.isOverdue(asOfDate)).length;

    return IncomingTalentSuccessionActivationClosureSummary(
      totalClosures: closures.length,
      scheduledCount: scheduledCount,
      activeCount: activeCount,
      completedCount: completedCount,
      deferredCount: deferredCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      nextAction: _nextAction(
        totalClosures: closures.length,
        scheduledCount: scheduledCount,
        activeCount: activeCount,
        deferredCount: deferredCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

String _nextAction({
  required int totalClosures,
  required int scheduledCount,
  required int activeCount,
  required int deferredCount,
  required int dueSoonCount,
  required int overdueCount,
}) {
  if (totalClosures == 0) {
    return 'Close cleared succession transitions into HR records.';
  }
  if (deferredCount > 0) return 'Resolve $deferredCount deferred closures.';
  if (overdueCount > 0) return 'Update $overdueCount overdue closures.';
  if (dueSoonCount > 0) return 'Prepare $dueSoonCount closures due soon.';
  if (scheduledCount > 0) return 'Activate $scheduledCount scheduled closures.';
  if (activeCount > 0) return 'Complete $activeCount active closures.';
  return 'Succession transition closures are complete.';
}
