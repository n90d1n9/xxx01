import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/adapters/pos_diagnostics_omni_activity_adapter.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_diagnostics_activity.dart';

void main() {
  test('pos diagnostics activity maps into omni-channel activity feed', () {
    final snapshot = POSDiagnosticsActivitySnapshot(
      entries: [
        POSDiagnosticsActivityEntry(
          id: 'switch_1',
          source: POSDiagnosticsActivitySource.switchAction,
          occurredAt: DateTime(2026, 6, 1, 10),
          title: 'Blocked Runtime pack: No Payment Pack',
          detail: 'Runtime pack switch blocked.',
          severity: POSDiagnosticsActivitySeverity.attention,
          supportSummary: 'Finish current order first.',
          searchTerms: const ['runtime pack'],
        ),
      ],
    );

    final feed = snapshot.toOmniChannelActivityFeed();
    final entry = feed.entries.single;

    expect(entry.id, 'pos_switchAction_switch_1');
    expect(entry.kind, OmniChannelActivityKind.switchAction);
    expect(entry.sourceId, 'point_of_sales');
    expect(entry.severity, OmniChannelActivitySeverity.attention);
    expect(entry.supportSummary, 'Finish current order first.');
    expect(feed.attentionCount, 1);
    expect(feed.search('runtime'), [entry]);
  });
}
