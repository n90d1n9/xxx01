import '../../../point_of_sales/cashier/experiences/pos_diagnostics_activity.dart';
import '../models/omni_channel_activity.dart';

extension POSDiagnosticsActivityOmniAdapter on POSDiagnosticsActivityEntry {
  OmniChannelActivityEntry toOmniChannelActivityEntry() {
    return OmniChannelActivityEntry(
      id: 'pos_${source.name}_$id',
      kind: _kindFor(source),
      sourceId: 'point_of_sales',
      sourceLabel: 'Point of sale',
      occurredAt: occurredAt,
      title: title,
      detail: detail,
      severity: _severityFor(severity),
      supportSummary: supportSummary,
      searchTerms: [
        'pos',
        'cashier',
        source.label,
        severity.label,
        ...searchTerms,
      ],
      attributes: {'posSource': source.name},
    );
  }
}

extension POSDiagnosticsSnapshotOmniAdapter on POSDiagnosticsActivitySnapshot {
  OmniChannelActivityFeed toOmniChannelActivityFeed({
    Iterable<OmniChannelActivityEntry> additionalEntries = const [],
  }) {
    return OmniChannelActivityFeed(
      entries: [
        for (final entry in entries) entry.toOmniChannelActivityEntry(),
        ...additionalEntries,
      ],
    );
  }
}

OmniChannelActivityKind _kindFor(POSDiagnosticsActivitySource source) {
  switch (source) {
    case POSDiagnosticsActivitySource.channelSwitch:
      return OmniChannelActivityKind.channelSwitch;
    case POSDiagnosticsActivitySource.switchAction:
      return OmniChannelActivityKind.switchAction;
    case POSDiagnosticsActivitySource.orderSync:
      return OmniChannelActivityKind.orderSync;
  }
}

OmniChannelActivitySeverity _severityFor(
  POSDiagnosticsActivitySeverity severity,
) {
  switch (severity) {
    case POSDiagnosticsActivitySeverity.ready:
      return OmniChannelActivitySeverity.ready;
    case POSDiagnosticsActivitySeverity.review:
      return OmniChannelActivitySeverity.review;
    case POSDiagnosticsActivitySeverity.attention:
      return OmniChannelActivitySeverity.attention;
  }
}
