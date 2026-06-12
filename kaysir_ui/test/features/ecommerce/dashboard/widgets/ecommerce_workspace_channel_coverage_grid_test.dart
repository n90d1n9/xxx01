import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_strategy.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/channel_coverage_grid.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/responsive_wrap_grid.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

void main() {
  testWidgets('ChannelCoverageGrid renders all signals', (tester) async {
    final strategy = ChannelStrategy.fromProfile(ProductProfile.standard);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 680,
            child: ChannelCoverageGrid(
              signals: strategy.coverageSignals,
              maxColumns: 2,
              showRequirementBadges: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Channels'), findsOneWidget);
    expect(find.text('Fulfillment'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Tracking'), findsOneWidget);
    expect(find.text('Required'), findsNWidgets(5));
    expect(find.byType(ResponsiveWrapGrid), findsOneWidget);
    expect(
      find.byType(TextBadge),
      findsNWidgets(strategy.coverageSignals.length),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelCoverageGrid distinguishes optional coverage', (
    tester,
  ) async {
    final strategy = ChannelStrategy.fromProfile(
      ProductProfile.standard.copyWith(
        capabilities: const [ProductCapability.marketplaceOrders],
        salesChannels: const [SalesChannels.marketplace],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 680,
            child: ChannelCoverageGrid(
              signals: strategy.coverageSignals,
              maxColumns: 2,
              showRequirementBadges: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Required'), findsNWidgets(2));
    expect(find.text('Optional'), findsNWidgets(5));
    expect(
      find.byType(TextBadge),
      findsNWidgets(strategy.coverageSignals.length),
    );
    expect(find.text('Not required by profile'), findsNWidgets(2));
    expect(find.text('Not covered'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
