import 'incoming_talent_operating_cadence_forecast.dart';

/// Summary of due-date cadence across talent operating inbox work.
class IncomingTalentOperatingCadenceForecastSummary {
  final int windowCount;
  final int activeWindowCount;
  final int criticalWindowCount;
  final int watchWindowCount;
  final int totalItemCount;
  final int criticalItemCount;
  final int overdueItemCount;
  final int dueTodayItemCount;
  final String nextAction;

  const IncomingTalentOperatingCadenceForecastSummary({
    required this.windowCount,
    required this.activeWindowCount,
    required this.criticalWindowCount,
    required this.watchWindowCount,
    required this.totalItemCount,
    required this.criticalItemCount,
    required this.overdueItemCount,
    required this.dueTodayItemCount,
    required this.nextAction,
  });

  factory IncomingTalentOperatingCadenceForecastSummary.fromBuckets(
    List<IncomingTalentOperatingCadenceBucket> buckets,
  ) {
    final activeWindowCount =
        buckets.where((bucket) => bucket.totalCount > 0).length;
    final criticalWindowCount = _countByRisk(
      buckets,
      IncomingTalentOperatingCadenceRisk.critical,
    );
    final watchWindowCount = _countByRisk(
      buckets,
      IncomingTalentOperatingCadenceRisk.watch,
    );
    final totalItemCount = buckets.fold<int>(
      0,
      (sum, bucket) => sum + bucket.totalCount,
    );
    final criticalItemCount = buckets.fold<int>(
      0,
      (sum, bucket) => sum + bucket.criticalCount,
    );
    final overdueItemCount = buckets.fold<int>(
      0,
      (sum, bucket) => sum + bucket.overdueCount,
    );
    final dueTodayItemCount = buckets.fold<int>(
      0,
      (sum, bucket) => sum + bucket.dueTodayCount,
    );

    return IncomingTalentOperatingCadenceForecastSummary(
      windowCount: buckets.length,
      activeWindowCount: activeWindowCount,
      criticalWindowCount: criticalWindowCount,
      watchWindowCount: watchWindowCount,
      totalItemCount: totalItemCount,
      criticalItemCount: criticalItemCount,
      overdueItemCount: overdueItemCount,
      dueTodayItemCount: dueTodayItemCount,
      nextAction: _nextAction(
        activeWindowCount: activeWindowCount,
        criticalWindowCount: criticalWindowCount,
        overdueItemCount: overdueItemCount,
        dueTodayItemCount: dueTodayItemCount,
        criticalItemCount: criticalItemCount,
        totalItemCount: totalItemCount,
      ),
    );
  }
}

int _countByRisk(
  List<IncomingTalentOperatingCadenceBucket> buckets,
  IncomingTalentOperatingCadenceRisk risk,
) {
  return buckets.where((bucket) => bucket.risk == risk).length;
}

String _nextAction({
  required int activeWindowCount,
  required int criticalWindowCount,
  required int overdueItemCount,
  required int dueTodayItemCount,
  required int criticalItemCount,
  required int totalItemCount,
}) {
  if (activeWindowCount == 0) {
    return 'Talent cadence forecast is clear.';
  }
  if (overdueItemCount > 0) {
    return 'Recover $overdueItemCount overdue talent cadence ${_plural(overdueItemCount, 'item')}.';
  }
  if (dueTodayItemCount > 0) {
    return 'Close $dueTodayItemCount talent cadence ${_plural(dueTodayItemCount, 'item')} due today.';
  }
  if (criticalWindowCount > 0) {
    return 'Stabilize $criticalWindowCount critical talent cadence ${_plural(criticalWindowCount, 'window')}.';
  }
  if (criticalItemCount > 0) {
    return 'Resolve $criticalItemCount critical future talent cadence ${_plural(criticalItemCount, 'item')}.';
  }
  return 'Track $totalItemCount active talent cadence ${_plural(totalItemCount, 'item')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
