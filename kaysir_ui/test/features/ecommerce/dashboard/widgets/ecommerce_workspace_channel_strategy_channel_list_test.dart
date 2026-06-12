import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/channel_strategy_channel_list.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/detail_row.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/empty_state.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('ChannelStrategyChannelList renders channels', (tester) async {
    await tester.pumpWorkspaceWidget(
      const ChannelStrategyChannelList(channels: [SalesChannels.webStore]),
    );

    expect(find.byType(DetailRow), findsOneWidget);
    expect(find.text('Web store'), findsOneWidget);
    expect(find.byIcon(Icons.language_outlined), findsOneWidget);
    expect(
      find.text('Fulfillment: Pickup, Delivery, Shipment'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Capabilities: Payments, Customer identity, Promotions, Inventory reservation, Fulfillment tracking',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelStrategyChannelList renders empty state', (tester) async {
    await tester.pumpWorkspaceWidget(
      const ChannelStrategyChannelList(channels: []),
    );

    expect(find.byType(DetailRow), findsNothing);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(
      find.text('No sales channels are registered for this profile.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
