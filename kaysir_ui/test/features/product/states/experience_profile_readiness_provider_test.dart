import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/experience_profile_readiness.dart';
import 'package:kaysir/features/product/models/product_module_destination.dart';
import 'package:kaysir/features/product/states/experience_profile_readiness_provider.dart';

void main() {
  test(
    'experience profile readiness provider exposes default ready registry',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final readiness = container.read(
        productExperienceProfileReadinessProvider,
      );

      expect(readiness.isReady, isTrue);
      expect(readiness.statusLabel, 'All profiles ready');
      expect(
        readiness.profiles.length,
        defaultProductExperienceProfiles.length,
      );
    },
  );

  test('experience profile readiness provider supports edition overrides', () {
    const registry = ProductExperienceProfileRegistry([
      ProductExperienceProfile(
        id: ProductExperienceProfileId('fresh_missing'),
        workspaceTitle: 'Fresh Missing',
        workspaceSubtitle: 'Fresh setup',
        workspaceDescription: 'Profile with a destination gap.',
        destinationIds: [ProductModuleDestinationId.freshnessReview],
      ),
    ]);
    const destinations = ProductModuleDestinationRegistry([
      productCatalogDestination,
    ]);
    final container = ProviderContainer(
      overrides: [
        productExperienceProfileRegistryProvider.overrideWithValue(registry),
        productModuleDestinationRegistryProvider.overrideWithValue(
          destinations,
        ),
      ],
    );
    addTearDown(container.dispose);

    final readiness = container.read(productExperienceProfileReadinessProvider);

    expect(readiness.isReady, isFalse);
    expect(readiness.statusLabel, '1 blocked');
    expect(
      readiness.profiles.single.level,
      ProductExperienceProfileReadinessLevel.blocked,
    );
    expect(
      readiness.profiles.single.issues.single.type,
      ProductExperienceProfileReadinessIssueType.missingDestination,
    );
  });
}
