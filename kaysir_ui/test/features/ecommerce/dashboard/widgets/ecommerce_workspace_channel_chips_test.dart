import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/channel_chips.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_label_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

void main() {
  testWidgets('ChannelChips renders channel labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChannelChips(
            channels: [
              SalesChannels.webStore,
              SalesChannels.marketplace,
              SalesChannels.socialOrder,
            ],
          ),
        ),
      ),
    );

    expect(find.text('Web store'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Social order'), findsOneWidget);
    expect(find.byType(IconLabelChip), findsNWidgets(3));
    expect(find.byType(TextBadge), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelChips summarizes hidden channels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChannelChips(
            maxVisible: 2,
            channels: [
              SalesChannels.webStore,
              SalesChannels.marketplace,
              SalesChannels.socialOrder,
              SalesChannels.deliveryApp,
            ],
          ),
        ),
      ),
    );

    expect(find.text('Web store'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Social order'), findsNothing);
    expect(find.text('Delivery app'), findsNothing);
    expect(find.text('+2 channels'), findsOneWidget);
    expect(find.byType(IconLabelChip), findsNWidgets(2));
    expect(find.byType(TextBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
