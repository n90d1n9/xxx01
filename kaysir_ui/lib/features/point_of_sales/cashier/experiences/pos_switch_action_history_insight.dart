import 'pos_switch_action_history.dart';
import 'pos_switch_action_result.dart';
import 'pos_switch_action_text.dart';

enum POSSwitchActionHistoryInsightLevel { ready, review, attention }

class POSSwitchActionHistoryInsight {
  final POSSwitchActionHistoryInsightLevel level;
  final int recordedCount;
  final String summaryLabel;
  final String headline;
  final String detail;
  final String nextStep;
  final POSSwitchActionHistoryEntry? referenceEntry;

  const POSSwitchActionHistoryInsight({
    required this.level,
    required this.recordedCount,
    required this.summaryLabel,
    required this.headline,
    required this.detail,
    required this.nextStep,
    this.referenceEntry,
  });

  factory POSSwitchActionHistoryInsight.fromHistory(
    POSSwitchActionHistory history,
  ) {
    final blockedEntry = _firstWhereOrNull(history.entries, _blocked);
    if (blockedEntry != null) {
      final text = POSSwitchActionText.fromResult(blockedEntry.result);

      return POSSwitchActionHistoryInsight(
        level: POSSwitchActionHistoryInsightLevel.attention,
        recordedCount: history.entries.length,
        summaryLabel: _summaryLabel(history),
        headline: 'Blocked switch needs review',
        detail: text.supportSummary,
        nextStep:
            text.operatorGuidance ??
            'Resolve the blocked requirement, then retry the switch.',
        referenceEntry: blockedEntry,
      );
    }

    final cancelledEntry = _firstWhereOrNull(history.entries, _cancelled);
    if (cancelledEntry != null) {
      final text = POSSwitchActionText.fromResult(cancelledEntry.result);

      return POSSwitchActionHistoryInsight(
        level: POSSwitchActionHistoryInsightLevel.review,
        recordedCount: history.entries.length,
        summaryLabel: _summaryLabel(history),
        headline: 'Cancelled switch recorded',
        detail: text.supportSummary,
        nextStep:
            text.operatorGuidance ??
            'Retry the switch when operators are ready.',
        referenceEntry: cancelledEntry,
      );
    }

    return POSSwitchActionHistoryInsight(
      level: POSSwitchActionHistoryInsightLevel.ready,
      recordedCount: history.entries.length,
      summaryLabel: _summaryLabel(history),
      headline:
          history.isEmpty ? 'No switch attempts yet' : 'Switching is healthy',
      detail:
          history.isEmpty
              ? 'Mode, runtime pack, and channel switch attempts will appear here.'
              : 'All recorded switch attempts completed successfully.',
      nextStep:
          history.isEmpty
              ? 'Run a switch attempt to start diagnostics.'
              : 'Continue monitoring switch attempts during rollout.',
      referenceEntry: history.latest,
    );
  }
}

bool _blocked(POSSwitchActionHistoryEntry entry) {
  return entry.result.outcome == POSSwitchActionOutcome.blocked;
}

POSSwitchActionHistoryEntry? _firstWhereOrNull(
  Iterable<POSSwitchActionHistoryEntry> entries,
  bool Function(POSSwitchActionHistoryEntry entry) test,
) {
  for (final entry in entries) {
    if (test(entry)) return entry;
  }

  return null;
}

bool _cancelled(POSSwitchActionHistoryEntry entry) {
  return entry.result.outcome == POSSwitchActionOutcome.cancelled;
}

String _summaryLabel(POSSwitchActionHistory history) {
  final count = history.entries.length;
  if (count == 0) return 'No switch attempts recorded';

  if (history.blockedCount > 0) {
    return '$count recorded, ${history.blockedCount} blocked';
  }
  if (history.cancelledCount > 0) {
    return '$count recorded, ${history.cancelledCount} cancelled';
  }

  return '$count recorded, ${history.appliedCount} applied';
}
