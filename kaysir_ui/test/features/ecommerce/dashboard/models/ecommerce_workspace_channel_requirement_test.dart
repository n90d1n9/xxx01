import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/capability.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_requirement.dart';

void main() {
  test('defaultChannelCoverageRequirements keeps stable registry order', () {
    expect(
      defaultChannelCoverageRequirements.map((requirement) => requirement.id),
      ['payments', 'customers', 'fulfillment_tracking'],
    );

    final paymentRequirement = channelCoverageRequirementFor(
      type: ChannelCoverageRequirementType.payments,
    );

    expect(
      paymentRequirement.isRequiredFor(const [
        ProductCapability.storefrontCheckout,
      ]),
      isTrue,
    );
    expect(
      paymentRequirement.isRequiredFor(const [
        ProductCapability.marketplaceOrders,
      ]),
      isFalse,
    );
    expect(
      paymentRequirement.coveredChannelCount(const [
        SalesChannels.webStore,
        SalesChannels.marketplace,
        SalesChannels.socialOrder,
      ]),
      2,
    );
  });

  test('ChannelCoverageRequirement supports custom modules', () {
    expect(
      ecommerceMarketplacePriceListChannelCoverageRequirement.isRequiredFor(
        const [ProductCapability.marketplaceOrders],
      ),
      isTrue,
    );
    expect(
      ecommerceMarketplacePriceListChannelCoverageRequirement
          .coveredChannelCount(const [
            SalesChannels.webStore,
            SalesChannels.marketplace,
          ]),
      1,
    );
    expect(
      ecommerceMarketplacePriceListChannelCoverageRequirement
          .recommendation
          ?.title,
      'Add price-list channel coverage',
    );
    expect(
      ecommerceMarketplacePriceListChannelCoverageRequirement
          .recommendation
          ?.actionLabel,
      'Review price lists',
    );
  });
}
