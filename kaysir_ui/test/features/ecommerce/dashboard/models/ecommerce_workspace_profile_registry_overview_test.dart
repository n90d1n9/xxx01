import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_registry_overview.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';

void main() {
  test('ProfileRegistryOverview summarizes defaults', () {
    final overview = ProfileRegistryOverview.fromProfiles(
      defaultProductProfiles,
    );

    expect(overview.profileCount, 6);
    expect(overview.salesChannelCount, 6);
    expect(overview.capabilityCount, 7);
    expect(overview.moduleCount, 7);
    expect(overview.actionRuleCount, 11);
    expect(overview.searchKeywordCount, 25);
  });

  test('ProfileRegistryOverview de-duplicates values', () {
    final overview = ProfileRegistryOverview.fromProfiles([
      ProductProfile.standard.copyWith(
        searchKeywords: const ['Retail', ' retail ', 'multi   channel'],
      ),
      ProductProfile.standard.copyWith(
        id: 'standard_copy',
        searchKeywords: const ['retail', 'multi channel'],
      ),
    ]);

    expect(overview.profileCount, 2);
    expect(overview.salesChannelCount, 3);
    expect(overview.capabilityCount, 5);
    expect(overview.moduleCount, 3);
    expect(overview.actionRuleCount, 7);
    expect(overview.searchKeywordCount, 2);
  });

  test('ProfileRegistryOverview handles empty registry', () {
    final overview = ProfileRegistryOverview.fromProfiles(const []);

    expect(overview, ProfileRegistryOverview.empty);
  });
}
