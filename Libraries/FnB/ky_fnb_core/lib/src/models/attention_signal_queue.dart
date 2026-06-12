import 'attention_signal.dart';
import 'service_status.dart';

/// Ranked collection of cross-functional FnB attention signals.
class FnbAttentionSignalQueue {
  FnbAttentionSignalQueue({required Iterable<FnbAttentionSignal> signals})
    : signals = _sortedSignals(signals);

  /// Builds a ranked queue from any mix of attention signal adapters.
  factory FnbAttentionSignalQueue.fromSignals(
    Iterable<FnbAttentionSignal> signals,
  ) {
    return FnbAttentionSignalQueue(signals: signals);
  }

  final List<FnbAttentionSignal> signals;

  bool get hasSignals => signals.isNotEmpty;

  List<FnbAttentionSignal> get attentionSignals {
    return List<FnbAttentionSignal>.unmodifiable(
      signals.where((signal) => signal.needsAttention),
    );
  }

  bool get hasAttention => attentionSignals.isNotEmpty;

  int get signalCount => signals.length;

  int get attentionCount => attentionSignals.length;

  FnbAttentionSignal? get topSignal => attentionSignals.firstOrNull;

  FnbServiceStatus get serviceStatus {
    var status = FnbServiceStatus.calm;
    for (final signal in attentionSignals) {
      status = status.mostUrgent(signal.status);
    }
    return status;
  }

  List<FnbAttentionSignal> signalsForKind(FnbAttentionSignalKind kind) {
    return List<FnbAttentionSignal>.unmodifiable(
      signals.where((signal) => signal.kind == kind),
    );
  }

  int attentionCountForKind(FnbAttentionSignalKind kind) {
    return attentionSignals.where((signal) => signal.kind == kind).length;
  }

  List<FnbAttentionSignal> topAttention({int limit = 5}) {
    assert(limit > 0, 'limit must be greater than zero.');
    return List<FnbAttentionSignal>.unmodifiable(attentionSignals.take(limit));
  }

  String get attentionCountLabel {
    return attentionCount == 1
        ? '1 signal needs attention'
        : '$attentionCount signals need attention';
  }
}

List<FnbAttentionSignal> _sortedSignals(Iterable<FnbAttentionSignal> signals) {
  return List<FnbAttentionSignal>.unmodifiable(
    List<FnbAttentionSignal>.of(signals)..sort(compareFnbAttentionSignals),
  );
}
