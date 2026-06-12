import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/edition.dart';
import 'package:kaysir/features/product/models/edition_readiness.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/states/edition_provider.dart';
import 'package:kaysir/features/product/states/edition_readiness_provider.dart';

void main() {
  test('product edition readiness provider exposes default ready registry', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final readiness = container.read(productEditionReadinessProvider);

    expect(readiness.isReady, isTrue);
    expect(readiness.statusLabel, 'All editions ready');
    expect(readiness.editions.length, defaultProductEditions.length);
  });

  test('product edition readiness provider supports edition overrides', () {
    const registry = ProductEditionRegistry([
      ProductEdition(
        id: ProductEditionId('broken'),
        title: 'Broken',
        subtitle: 'Invalid channel',
        description: 'Edition with a channel profile outside its pack.',
        kind: ProductEditionKind.kiosk,
        experienceProfileId: ProductExperienceProfileId.catalogOperations,
        managementPackId: ProductManagementPackId.groceryFreshGoods,
        channelProfileId: ProductSalesChannelProfileId.counterService,
        capabilityLabels: ['Kiosk flow'],
      ),
    ]);
    final container = ProviderContainer(
      overrides: [productEditionRegistryProvider.overrideWithValue(registry)],
    );
    addTearDown(container.dispose);

    final readiness = container.read(productEditionReadinessProvider);

    expect(readiness.isReady, isFalse);
    expect(readiness.statusLabel, '1 blocked');
    expect(
      readiness.editions.single.issues.single.type,
      ProductEditionReadinessIssueType.unavailableChannelProfile,
    );
  });
}
