import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_strategy.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/action_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/channel_strategy_panel.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/detail_row.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_close_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_header.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_section.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_header.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_surface.dart';

void main() {
  testWidgets('ChannelStrategyPanel renders coverage summary', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ChannelStrategyPanel(
              strategy: ChannelStrategy.fromProfile(ProductProfile.standard),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Channel strategy'), findsOneWidget);
    expect(find.text('Channel coverage ready'), findsOneWidget);
    expect(find.text('Inspect channels'), findsOneWidget);
    expect(find.text('3 channels'), findsWidgets);
    expect(find.text('4 modes'), findsOneWidget);
    expect(find.text('2 channels'), findsWidgets);
    expect(find.text('Tracking'), findsOneWidget);
    expect(find.text('Web store'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.byType(PanelHeader), findsOneWidget);
    expect(find.byType(PanelSurface), findsOneWidget);
    expect(find.byType(ActionButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelStrategyPanel highlights coverage gaps', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ChannelStrategyPanel(
              strategy: ChannelStrategy.fromProfile(
                ProductProfile.standard.copyWith(
                  salesChannels: const [SalesChannels.marketplace],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('2 coverage gaps'), findsOneWidget);
    expect(find.text('Not covered'), findsNWidgets(2));
    expect(find.text('No payment-capable channel'), findsOneWidget);
    expect(find.text('No customer-aware channel'), findsOneWidget);
    expect(find.text('Add payment-capable channel'), findsOneWidget);
    expect(find.text('1 more in channel details'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelStrategyPanel keeps optional coverage quiet', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ChannelStrategyPanel(
              strategy: ChannelStrategy.fromProfile(
                ProductProfile.standard.copyWith(
                  capabilities: const [ProductCapability.marketplaceOrders],
                  salesChannels: const [SalesChannels.marketplace],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Channel coverage ready'), findsOneWidget);
    expect(find.text('Optional'), findsNWidgets(2));
    expect(find.text('2 coverage gaps'), findsNothing);
    expect(find.text('No payment-capable channel'), findsNothing);
    expect(find.text('No customer-aware channel'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelStrategyPanel opens channel details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ChannelStrategyPanel(
              strategy: ChannelStrategy.fromProfile(ProductProfile.standard),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Inspect channels'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('channel_strategy_dialog')),
      findsOneWidget,
    );
    expect(find.text('Channel strategy details'), findsOneWidget);
    expect(find.byType(DialogCloseButton), findsOneWidget);
    expect(find.byType(DialogHeader), findsOneWidget);
    expect(find.byType(DialogSection), findsNWidgets(2));
    expect(find.byType(DetailRow), findsNWidgets(3));
    expect(find.text('Coverage'), findsOneWidget);
    expect(find.text('Customers'), findsWidgets);
    expect(find.text('Tracking'), findsWidgets);
    expect(find.text('Required'), findsNWidgets(5));
    expect(find.text('Web store'), findsWidgets);
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

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Channel strategy details'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelStrategyPanel opens channel playbook details', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ChannelStrategyPanel(
              strategy: ChannelStrategy.fromProfile(
                ProductProfile.standard.copyWith(
                  salesChannels: const [SalesChannels.marketplace],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Inspect channels'));
    await tester.pumpAndSettle();

    expect(find.text('Playbook'), findsOneWidget);
    expect(find.text('Add payment-capable channel'), findsWidgets);
    expect(find.text('Add customer identity coverage'), findsOneWidget);
    expect(find.text('Add payment'), findsWidgets);
    expect(find.text('Add identity'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelStrategyPanel stays quiet when empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChannelStrategyPanel(
            strategy: ChannelStrategy.fromProfile(
              ProductProfile.standard.copyWith(salesChannels: const []),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('channel_strategy_panel')), findsNothing);
    expect(find.byType(PanelSurface), findsNothing);
    expect(find.text('Channel strategy'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
