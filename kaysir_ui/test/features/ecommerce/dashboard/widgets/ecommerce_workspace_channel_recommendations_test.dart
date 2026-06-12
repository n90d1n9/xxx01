import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_recommendation.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_strategy.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/channel_recommendations.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/detail_row.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/empty_state.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/inset_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

void main() {
  testWidgets('ChannelRecommendations renders playbook items', (tester) async {
    final strategy = ChannelStrategy.fromProfile(
      ProductProfile.standard.copyWith(
        salesChannels: const [SalesChannels.marketplace],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChannelRecommendations(
            recommendations: strategy.recommendations,
          ),
        ),
      ),
    );

    expect(find.text('Playbook'), findsOneWidget);
    expect(find.text('Add payment-capable channel'), findsOneWidget);
    expect(find.text('Add customer identity coverage'), findsOneWidget);
    expect(find.text('Add payment'), findsOneWidget);
    expect(find.text('Add identity'), findsOneWidget);
    expect(find.byType(InsetSurface), findsNWidgets(2));
    expect(find.byType(DetailRow), findsNWidgets(2));
    expect(find.byType(TextBadge), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelRecommendations can stay compact', (tester) async {
    final strategy = ChannelStrategy.fromProfile(
      ProductProfile.standard.copyWith(
        salesChannels: const [SalesChannels.marketplace],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChannelRecommendations(
            recommendations: strategy.recommendations,
            maxVisible: 1,
            showHeader: false,
          ),
        ),
      ),
    );

    expect(find.text('Playbook'), findsNothing);
    expect(find.text('Add payment-capable channel'), findsOneWidget);
    expect(find.text('Add customer identity coverage'), findsNothing);
    expect(find.text('1 more in channel details'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelRecommendations renders custom requirement copy', (
    tester,
  ) async {
    final strategy = ChannelStrategy.fromProfile(
      ProductProfile.marketplaceOperations.copyWith(
        salesChannels: const [SalesChannels.webStore],
      ),
      coverageRequirements:
          ProductProfile.marketplaceOperations.channelCoverageRequirements,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChannelRecommendations(
            recommendations: strategy.recommendations,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('channel_recommendation_price_lists')),
      findsOneWidget,
    );
    expect(find.text('Add price-list channel coverage'), findsOneWidget);
    expect(
      find.text(
        'Marketplace operations need a channel that can apply marketplace-specific price lists before orders are reconciled.',
      ),
      findsOneWidget,
    );
    expect(find.text('Review price lists'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelRecommendations can show empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChannelRecommendations(
            recommendations: [],
            showEmptyState: true,
          ),
        ),
      ),
    );

    expect(find.text('No channel playbook recommendations.'), findsOneWidget);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
