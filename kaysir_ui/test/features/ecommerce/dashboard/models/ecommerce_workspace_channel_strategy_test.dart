import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_recommendation.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_requirement.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_strategy.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';

void main() {
  test('ChannelStrategy summarizes standard coverage', () {
    final strategy = ChannelStrategy.fromProfile(ProductProfile.standard);

    expect(strategy.hasChannels, isTrue);
    expect(strategy.channelCount, 3);
    expect(strategy.channelCountLabel, '3 channels');
    expect(strategy.fulfillmentModeCount, 4);
    expect(strategy.fulfillmentModeCountLabel, '4 modes');
    expect(strategy.fulfillmentSummary, contains('Pickup'));
    expect(strategy.fulfillmentSummary, contains('Shipment'));
    expect(strategy.paymentChannelCount, 2);
    expect(strategy.customerIdentityChannelCount, 2);
    expect(strategy.fulfillmentTrackingChannelCount, 3);
    expect(strategy.paymentCoverageLabel, '2 channels');
    expect(strategy.requiresPaymentCoverage, isTrue);
    expect(strategy.requiresCustomerCoverage, isTrue);
    expect(strategy.requiresFulfillmentTrackingCoverage, isTrue);
    expect(strategy.coverageRequirements.map((requirement) => requirement.id), [
      'payments',
      'customers',
      'fulfillment_tracking',
    ]);
    expect(strategy.hasCoverageGaps, isFalse);
    expect(strategy.coverageGapCount, 0);
    expect(strategy.coverageHeadline, 'Channel coverage ready');
    expect(strategy.coverageSignals.map((signal) => signal.label), [
      'Channels',
      'Fulfillment',
      'Payments',
      'Customers',
      'Tracking',
    ]);
  });

  test('ChannelStrategy reports empty coverage', () {
    final profile = ProductProfile.standard.copyWith(salesChannels: const []);
    final strategy = ChannelStrategy.fromProfile(profile);

    expect(strategy.hasChannels, isFalse);
    expect(strategy.channelCountLabel, '0 channels');
    expect(strategy.fulfillmentModeCountLabel, 'No modes');
    expect(strategy.fulfillmentSummary, 'No fulfillment modes');
    expect(strategy.paymentCoverageLabel, 'Not covered');
    expect(strategy.customerCoverageLabel, 'Not covered');
    expect(strategy.fulfillmentTrackingCoverageLabel, 'Not covered');
    expect(strategy.hasCoverageGaps, isTrue);
    expect(strategy.coverageGapCount, 5);
    expect(strategy.coverageHeadline, '5 coverage gaps');
    expect(
      strategy.coverageSignals.where((signal) => signal.needsAttention).length,
      5,
    );
  });

  test('ChannelStrategy flags partial coverage gaps', () {
    final profile = ProductProfile.standard.copyWith(
      salesChannels: const [SalesChannels.marketplace],
    );
    final strategy = ChannelStrategy.fromProfile(profile);

    expect(strategy.hasCoverageGaps, isTrue);
    expect(strategy.coverageGapCount, 2);
    expect(strategy.coverageHeadline, '2 coverage gaps');
    expect(
      strategy.coverageSignals
          .where((signal) => signal.needsAttention)
          .map((signal) => signal.label),
      ['Payments', 'Customers'],
    );
    expect(
      strategy.coverageSignals
          .singleWhere((signal) => signal.label == 'Payments')
          .detail,
      'No payment-capable channel',
    );
  });

  test('ChannelStrategy treats non-required coverage as optional', () {
    final profile = ProductProfile.standard.copyWith(
      capabilities: const [ProductCapability.marketplaceOrders],
      salesChannels: const [SalesChannels.marketplace],
    );
    final strategy = ChannelStrategy.fromProfile(profile);

    expect(strategy.requiresPaymentCoverage, isFalse);
    expect(strategy.requiresCustomerCoverage, isFalse);
    expect(strategy.requiresFulfillmentTrackingCoverage, isFalse);
    expect(strategy.hasCoverageGaps, isFalse);
    expect(strategy.coverageHeadline, 'Channel coverage ready');
    expect(
      strategy.coverageSignals
          .where((signal) => !signal.isRequired)
          .map((signal) => signal.label),
      ['Payments', 'Customers', 'Tracking'],
    );
    expect(
      strategy.coverageSignals
          .where((signal) => signal.value == 'Optional')
          .map((signal) => signal.label),
      ['Payments', 'Customers'],
    );
    expect(
      strategy.coverageSignals
          .singleWhere((signal) => signal.label == 'Tracking')
          .value,
      '1 channel',
    );
  });

  test('ChannelStrategy keeps unique fulfillment modes stable', () {
    final profile = ProductProfile.standard.copyWith(
      salesChannels: const [SalesChannels.socialOrder, SalesChannels.webStore],
    );
    final strategy = ChannelStrategy.fromProfile(profile);

    expect(strategy.fulfillmentModes.map((mode) => mode.label), [
      'Pickup',
      'Delivery',
      'Shipment',
      'Pre-order',
    ]);
  });

  test('ChannelStrategy appends custom registry requirements', () {
    final profile = ProductProfile.standard.copyWith(
      capabilities: const [ProductCapability.marketplaceOrders],
      salesChannels: const [SalesChannels.marketplace],
    );
    final strategy = ChannelStrategy.fromProfile(
      profile,
      coverageRequirements: const [
        ecommerceMarketplacePriceListChannelCoverageRequirement,
      ],
    );

    expect(strategy.coverageRequirements, [
      ecommerceMarketplacePriceListChannelCoverageRequirement,
    ]);
    expect(strategy.coverageSignals.map((signal) => signal.label), [
      'Channels',
      'Fulfillment',
      'Price lists',
    ]);
    expect(
      strategy.coverageSignals.singleWhere(
        (signal) => signal.label == 'Price lists',
      ),
      isA<ChannelCoverageSignal>()
          .having(
            (signal) => signal.type,
            'type',
            ChannelCoverageSignalType.channelRequirement,
          )
          .having(
            (signal) => signal.requirementId,
            'requirementId',
            'price_lists',
          )
          .having((signal) => signal.value, 'value', '1 channel')
          .having((signal) => signal.needsAttention, 'needsAttention', isFalse),
    );
    expect(strategy.hasCoverageGaps, isFalse);
  });

  test('ChannelStrategy recommends custom requirement gaps', () {
    final profile = ProductProfile.standard.copyWith(
      capabilities: const [ProductCapability.marketplaceOrders],
      salesChannels: const [SalesChannels.webStore],
    );
    final strategy = ChannelStrategy.fromProfile(
      profile,
      coverageRequirements: const [
        ecommerceMarketplacePriceListChannelCoverageRequirement,
      ],
    );

    expect(strategy.hasCoverageGaps, isTrue);
    expect(
      strategy.coverageSignals
          .singleWhere((signal) => signal.label == 'Price lists')
          .detail,
      'No price-list channel',
    );
    final recommendation = strategy.recommendations.singleWhere(
      (recommendation) =>
          recommendation.type ==
          ChannelRecommendationType.addChannelRequirementCoverage,
    );

    expect(recommendation.title, 'Add price-list channel coverage');
    expect(
      recommendation.detail,
      'Marketplace operations need a channel that can apply marketplace-specific price lists before orders are reconciled.',
    );
    expect(recommendation.actionLabel, 'Review price lists');
    expect(recommendation.priority, 55);
    expect(recommendation.coverageRequirementId, 'price_lists');
    expect(
      strategy.recommendations.map((recommendation) => recommendation.type),
      contains(ChannelRecommendationType.addChannelRequirementCoverage),
    );
  });

  test('ChannelStrategy recommends missing coverage steps', () {
    final profile = ProductProfile.standard.copyWith(
      salesChannels: const [SalesChannels.marketplace],
    );
    final strategy = ChannelStrategy.fromProfile(profile);

    expect(strategy.hasRecommendations, isTrue);
    expect(
      strategy.recommendations.map((recommendation) => recommendation.type),
      [
        ChannelRecommendationType.addPaymentChannel,
        ChannelRecommendationType.addCustomerIdentityChannel,
      ],
    );
    expect(strategy.recommendations.first.title, 'Add payment-capable channel');
    expect(strategy.recommendations.first.actionLabel, 'Add payment');
    expect(strategy.recommendations.first.coverageRequirementId, 'payments');
  });

  test('ChannelStrategy keeps optional recommendations quiet', () {
    final profile = ProductProfile.standard.copyWith(
      capabilities: const [ProductCapability.marketplaceOrders],
      salesChannels: const [SalesChannels.marketplace],
    );
    final strategy = ChannelStrategy.fromProfile(profile);

    expect(strategy.hasRecommendations, isFalse);
    expect(strategy.recommendations, isEmpty);
  });

  test('channelRecommendationsFor respects recommendation limits', () {
    final strategy = ChannelStrategy.fromProfile(
      ProductProfile.standard.copyWith(salesChannels: const []),
    );

    final recommendations = channelRecommendationsFor(
      strategy,
      maxRecommendations: 2,
    );

    expect(recommendations.map((recommendation) => recommendation.type), [
      ChannelRecommendationType.registerChannels,
      ChannelRecommendationType.addFulfillmentModes,
    ]);
  });
}
