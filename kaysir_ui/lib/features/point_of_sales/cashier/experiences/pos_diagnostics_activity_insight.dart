import 'pos_diagnostics_activity.dart';

class POSDiagnosticsActivityInsight {
  final POSDiagnosticsActivitySeverity severity;
  final int eventCount;
  final int attentionCount;
  final int reviewCount;
  final String summaryLabel;
  final String headline;
  final String detail;
  final String nextStep;
  final POSDiagnosticsActivityEntry? referenceEntry;

  const POSDiagnosticsActivityInsight({
    required this.severity,
    required this.eventCount,
    required this.attentionCount,
    required this.reviewCount,
    required this.summaryLabel,
    required this.headline,
    required this.detail,
    required this.nextStep,
    this.referenceEntry,
  });

  factory POSDiagnosticsActivityInsight.fromSnapshot(
    POSDiagnosticsActivitySnapshot snapshot,
  ) {
    final attentionEntry = snapshot.attentionEntries.firstOrNull;
    if (attentionEntry != null) {
      return POSDiagnosticsActivityInsight(
        severity: POSDiagnosticsActivitySeverity.attention,
        eventCount: snapshot.entries.length,
        attentionCount: snapshot.attentionCount,
        reviewCount: snapshot.reviewCount,
        summaryLabel: _summaryLabel(snapshot),
        headline: 'Activity needs attention',
        detail: attentionEntry.supportSummary ?? attentionEntry.title,
        nextStep: 'Resolve attention events before rollout.',
        referenceEntry: attentionEntry,
      );
    }

    final reviewEntry = snapshot.reviewEntries.firstOrNull;
    if (reviewEntry != null) {
      return POSDiagnosticsActivityInsight(
        severity: POSDiagnosticsActivitySeverity.review,
        eventCount: snapshot.entries.length,
        attentionCount: snapshot.attentionCount,
        reviewCount: snapshot.reviewCount,
        summaryLabel: _summaryLabel(snapshot),
        headline: 'Activity review recommended',
        detail: reviewEntry.supportSummary ?? reviewEntry.title,
        nextStep: 'Confirm review events before rollout.',
        referenceEntry: reviewEntry,
      );
    }

    if (snapshot.isEmpty) {
      return const POSDiagnosticsActivityInsight(
        severity: POSDiagnosticsActivitySeverity.ready,
        eventCount: 0,
        attentionCount: 0,
        reviewCount: 0,
        summaryLabel: 'No activity recorded',
        headline: 'No POS activity yet',
        detail:
            'Switch attempts, channel changes, and order sync events will appear here.',
        nextStep: 'Run POS activity to start diagnostics.',
      );
    }

    return POSDiagnosticsActivityInsight(
      severity: POSDiagnosticsActivitySeverity.ready,
      eventCount: snapshot.entries.length,
      attentionCount: snapshot.attentionCount,
      reviewCount: snapshot.reviewCount,
      summaryLabel: _summaryLabel(snapshot),
      headline: 'Activity is healthy',
      detail: 'All recorded POS activity is clear.',
      nextStep: 'Continue monitoring POS activity.',
      referenceEntry: snapshot.entries.first,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    for (final value in this) {
      return value;
    }

    return null;
  }
}

String _summaryLabel(POSDiagnosticsActivitySnapshot snapshot) {
  final parts = <String>[
    _countLabel(snapshot.entries.length, 'event'),
    if (snapshot.attentionCount > 0)
      _countLabel(snapshot.attentionCount, 'attention'),
    if (snapshot.reviewCount > 0) _countLabel(snapshot.reviewCount, 'review'),
  ];

  return parts.join(', ');
}

String _countLabel(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}
