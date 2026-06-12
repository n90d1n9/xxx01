import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_business_motion.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';

void main() {
  test('profileBusinessMotionForProfile classifies presets', () {
    expect(
      profileBusinessMotionForProfile(ProductProfile.standard),
      ProfileBusinessMotion.omnichannel,
    );
    expect(
      profileBusinessMotionForProfile(ProductProfile.operationsFirst),
      ProfileBusinessMotion.operations,
    );
    expect(
      profileBusinessMotionForProfile(ProductProfile.remotePayment),
      ProfileBusinessMotion.assistedSelling,
    );
    expect(
      profileBusinessMotionForProfile(ProductProfile.subscriptionCommerce),
      ProfileBusinessMotion.subscription,
    );
    expect(
      profileBusinessMotionForProfile(ProductProfile.fulfillmentFirst),
      ProfileBusinessMotion.fulfillment,
    );
    expect(
      profileBusinessMotionForProfile(ProductProfile.marketplaceOperations),
      ProfileBusinessMotion.marketplace,
    );
  });

  test('profileBusinessMotionFor supports channel-only packs', () {
    expect(
      profileBusinessMotionFor(
        capabilities: const [],
        salesChannels: const [
          SalesChannels.webStore,
          SalesChannels.marketplace,
        ],
      ),
      ProfileBusinessMotion.omnichannel,
    );
  });

  test('business motion labels stay concise for registry chips', () {
    expect(ProfileBusinessMotion.marketplace.label, 'Marketplace motion');
    expect(ProfileBusinessMotion.focused.label, 'Focused commerce');
  });

  test('profileBusinessMotionFor falls back to focused commerce', () {
    expect(
      profileBusinessMotionFor(
        capabilities: const [ProductCapability.storefrontCheckout],
      ),
      ProfileBusinessMotion.focused,
    );
  });
}
