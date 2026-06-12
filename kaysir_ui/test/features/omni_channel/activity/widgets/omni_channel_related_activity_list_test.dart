import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_relation.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_related_activity_list.dart';

void main() {
  testWidgets('omni-channel related activity list selects related entries', (
    tester,
  ) async {
    OmniChannelActivityEntry? selectedEntry;
    final relatedEntry = OmniChannelActivityEntry(
      id: 'sync',
      kind: OmniChannelActivityKind.orderSync,
      sourceId: 'point_of_sales',
      sourceLabel: 'Point of sale',
      occurredAt: DateTime(2026, 6, 9, 11),
      title: 'Counter sync completed',
      detail: 'The POS handoff reached ecommerce.',
      channelId: 'marketplace',
      channelLabel: 'Marketplace',
      orderId: 'ECOM-1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OmniChannelRelatedActivityList(
            entries: [
              OmniChannelRelatedActivityEntry(
                entry: relatedEntry,
                relation: OmniChannelActivityRelationKind.sameOrder,
              ),
            ],
            onEntrySelected: (entry) => selectedEntry = entry,
          ),
        ),
      ),
    );

    expect(find.text('Related activity'), findsOneWidget);
    expect(find.text('Same order'), findsOneWidget);

    await tester.tap(find.text('Counter sync completed'));
    await tester.pump();

    expect(selectedEntry, relatedEntry);
    expect(tester.takeException(), isNull);
  });
}
