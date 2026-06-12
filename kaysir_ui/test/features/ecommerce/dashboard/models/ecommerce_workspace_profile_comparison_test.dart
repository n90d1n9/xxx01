import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_business_motion.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_comparison.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';

void main() {
  test('profileComparisonRows preserves registry order', () {
    final rows = profileComparisonRows(defaultProductProfiles);

    expect(rows.map((row) => row.profileId), [
      'standard',
      'operations_first',
      'remote_payment',
      'subscription_commerce',
      'fulfillment_first',
      'marketplace_operations',
    ]);
  });

  test('ProfileComparisonRow summarizes profile shape', () {
    final row = ProfileComparisonRow.fromProfile(
      ProductProfile.marketplaceOperations,
    );

    expect(row.profileId, 'marketplace_operations');
    expect(row.label, 'Marketplace operations');
    expect(row.presentationLabel, 'Operations first workspace');
    expect(row.salesChannelCount, 3);
    expect(row.capabilityCount, 4);
    expect(row.moduleCount, 6);
    expect(row.actionRuleCount, 10);
    expect(row.searchKeywordCount, 4);
    expect(row.launchComplexityScore, 23);
    expect(row.launchComplexity, ProfileLaunchComplexity.advanced);
    expect(row.launchComplexity.label, 'Advanced launch');
    expect(row.businessMotion, ProfileBusinessMotion.marketplace);
    expect(row.businessMotion.label, 'Marketplace motion');
    expect(
      profileLaunchComplexityScoreForProfile(
        ProductProfile.marketplaceOperations,
      ),
      23,
    );
    expect(
      profileLaunchComplexityForProfile(ProductProfile.marketplaceOperations),
      ProfileLaunchComplexity.advanced,
    );
  });

  test('profileLaunchComplexityFor buckets profile scope', () {
    expect(profileLaunchComplexityFor(17), ProfileLaunchComplexity.lean);
    expect(profileLaunchComplexityFor(18), ProfileLaunchComplexity.standard);
    expect(profileLaunchComplexityFor(20), ProfileLaunchComplexity.standard);
    expect(profileLaunchComplexityFor(21), ProfileLaunchComplexity.advanced);
  });
}
