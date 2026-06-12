import 'order_save_outbox.dart';
import 'order_save_outbox_sync_behavior.dart';

enum POSOrderSaveOutboxFreshnessLevel { fresh, aging, stale }

class POSOrderSaveOutboxFreshnessState {
  final POSOrderSaveOutboxFreshnessLevel level;
  final int stalePendingCount;
  final int staleFailedCount;
  final int agingPendingCount;
  final int agingFailedCount;
  final Duration? oldestPendingAge;
  final Duration? oldestFailedAge;
  final POSOrderSaveOutboxSyncBehavior syncBehavior;

  const POSOrderSaveOutboxFreshnessState({
    required this.level,
    required this.stalePendingCount,
    required this.staleFailedCount,
    required this.agingPendingCount,
    required this.agingFailedCount,
    required this.oldestPendingAge,
    required this.oldestFailedAge,
    required this.syncBehavior,
  });

  const POSOrderSaveOutboxFreshnessState.fresh({
    POSOrderSaveOutboxSyncBehavior syncBehavior =
        POSOrderSaveOutboxSyncBehavior.standard,
  }) : this(
         level: POSOrderSaveOutboxFreshnessLevel.fresh,
         stalePendingCount: 0,
         staleFailedCount: 0,
         agingPendingCount: 0,
         agingFailedCount: 0,
         oldestPendingAge: null,
         oldestFailedAge: null,
         syncBehavior: syncBehavior,
       );

  factory POSOrderSaveOutboxFreshnessState.resolve({
    required POSOrderSaveOutbox outbox,
    required POSOrderSaveOutboxSyncBehavior syncBehavior,
    required DateTime now,
  }) {
    final pendingAges = outbox.pendingEntries
        .map((entry) {
          return _positiveAge(now.difference(entry.queuedAt));
        })
        .toList(growable: false);
    final failedAges = outbox.failedEntries
        .map((entry) {
          return _positiveAge(
            now.difference(entry.lastAttemptAt ?? entry.queuedAt),
          );
        })
        .toList(growable: false);

    final stalePendingCount = _countAtOrPast(
      pendingAges,
      syncBehavior.stalePendingAfter,
    );
    final staleFailedCount = _countAtOrPast(
      failedAges,
      syncBehavior.staleFailedAfter,
    );
    final agingPendingCount = _countBetween(
      pendingAges,
      _agingThreshold(syncBehavior.stalePendingAfter),
      syncBehavior.stalePendingAfter,
    );
    final agingFailedCount = _countBetween(
      failedAges,
      _agingThreshold(syncBehavior.staleFailedAfter),
      syncBehavior.staleFailedAfter,
    );

    final level =
        stalePendingCount + staleFailedCount > 0
            ? POSOrderSaveOutboxFreshnessLevel.stale
            : agingPendingCount + agingFailedCount > 0
            ? POSOrderSaveOutboxFreshnessLevel.aging
            : POSOrderSaveOutboxFreshnessLevel.fresh;

    return POSOrderSaveOutboxFreshnessState(
      level: level,
      stalePendingCount: stalePendingCount,
      staleFailedCount: staleFailedCount,
      agingPendingCount: agingPendingCount,
      agingFailedCount: agingFailedCount,
      oldestPendingAge: _oldestAge(pendingAges),
      oldestFailedAge: _oldestAge(failedAges),
      syncBehavior: syncBehavior,
    );
  }

  bool get shouldSurface => level != POSOrderSaveOutboxFreshnessLevel.fresh;

  bool get hasStaleFailed => staleFailedCount > 0;

  String get title {
    switch (level) {
      case POSOrderSaveOutboxFreshnessLevel.fresh:
        return 'Queue wait time healthy';
      case POSOrderSaveOutboxFreshnessLevel.aging:
        return 'Queue wait time rising';
      case POSOrderSaveOutboxFreshnessLevel.stale:
        return hasStaleFailed
            ? 'Failed saves are stale'
            : 'Queued saves are stale';
    }
  }

  String get message {
    switch (level) {
      case POSOrderSaveOutboxFreshnessLevel.fresh:
        return 'Queued and failed saves are within the expected wait window.';
      case POSOrderSaveOutboxFreshnessLevel.aging:
        return _agingMessage();
      case POSOrderSaveOutboxFreshnessLevel.stale:
        return _staleMessage();
    }
  }

  String _agingMessage() {
    final parts = <String>[
      if (agingFailedCount > 0)
        '${_countLabel(agingFailedCount, 'failed save')} approaching ${_durationLabel(syncBehavior.staleFailedAfter)}',
      if (agingPendingCount > 0)
        '${_countLabel(agingPendingCount, 'queued save')} approaching ${_durationLabel(syncBehavior.stalePendingAfter)}',
    ];
    return '${parts.join('; ')}. Keep an eye on this queue.';
  }

  String _staleMessage() {
    if (hasStaleFailed) {
      final oldest = oldestFailedAge;
      final ageText = oldest == null ? '' : ' for ${_durationLabel(oldest)}';
      return '${_countLabel(staleFailedCount, 'failed save')} waited$ageText. Retry before closing this register.';
    }

    final oldest = oldestPendingAge;
    final ageText = oldest == null ? '' : ' for ${_durationLabel(oldest)}';
    return '${_countLabel(stalePendingCount, 'queued save')} waited$ageText. Run ${syncBehavior.syncActionLabel} when ready.';
  }
}

Duration _positiveAge(Duration age) {
  return age.isNegative ? Duration.zero : age;
}

Duration _agingThreshold(Duration threshold) {
  if (threshold <= Duration.zero) return Duration.zero;
  final halfMicroseconds = threshold.inMicroseconds ~/ 2;
  return Duration(microseconds: halfMicroseconds);
}

int _countAtOrPast(List<Duration> ages, Duration threshold) {
  return ages.where((age) => age >= threshold).length;
}

int _countBetween(List<Duration> ages, Duration lower, Duration upper) {
  return ages.where((age) => age >= lower && age < upper).length;
}

Duration? _oldestAge(List<Duration> ages) {
  if (ages.isEmpty) return null;
  return ages.reduce((left, right) => left >= right ? left : right);
}

String _countLabel(int count, String noun) {
  return '$count $noun${count == 1 ? '' : 's'}';
}

String _durationLabel(Duration duration) {
  final seconds = duration.inSeconds;
  if (seconds < 60) return '$seconds sec';

  final minutes = duration.inMinutes;
  if (minutes < 60) return '$minutes min';

  final hours = duration.inHours;
  final remainingMinutes = minutes.remainder(60);
  if (remainingMinutes == 0) return '$hours hr';
  return '$hours hr $remainingMinutes min';
}
