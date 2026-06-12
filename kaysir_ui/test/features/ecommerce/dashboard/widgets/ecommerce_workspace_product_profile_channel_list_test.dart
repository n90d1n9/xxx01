import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/detail_row.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/empty_state.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/product_profile_channel_list.dart';

void main() {
  testWidgets('ProductProfileChannelList renders channel detail rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductProfileChannelList(
            channels: [SalesChannels.marketplace, SalesChannels.deliveryApp],
          ),
        ),
      ),
    );

    expect(find.byType(DetailRow), findsNWidgets(2));
    expect(find.text('Marketplace'), findsOneWidget);
    expect(
      find.text('Third-party marketplace orders with platform policies.'),
      findsOneWidget,
    );
    expect(find.text('Fulfillment: Delivery, Shipment'), findsOneWidget);
    expect(
      find.text(
        'Capabilities: Inventory reservation, Fulfillment tracking, Price lists',
      ),
      findsWidgets,
    );
    expect(
      find.text('Traits: third-party, fees, policy-bound'),
      findsOneWidget,
    );
    expect(find.text('Delivery app'), findsOneWidget);
    expect(find.text('Traits: aggregator, courier, prep-time'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProductProfileChannelList shows empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProductProfileChannelList(channels: [])),
      ),
    );

    expect(find.byType(EmptyState), findsOneWidget);
    expect(
      find.text('No sales channels are registered for this profile.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
