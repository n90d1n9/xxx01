import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/edition.dart';
import 'package:kaysir/features/product/models/edition_readiness.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test('default product editions are ready', () {
    final readiness = assessProductEditionRegistryReadiness(
      defaultProductEditionRegistry,
    );

    expect(readiness.isReady, isTrue);
    expect(readiness.statusLabel, 'All editions ready');
    expect(readiness.blockedEditionCount, 0);
    expect(readiness.warningEditionCount, 0);
    expect(readiness.issueCount, 0);
    expect(readiness.editions.length, defaultProductEditions.length);
  });

  test('edition readiness reports metadata and reference gaps', () {
    const edition = ProductEdition(
      id: ProductEditionId('broken'),
      title: ' ',
      subtitle: '',
      description: '',
      kind: ProductEditionKind.kiosk,
      experienceProfileId: ProductExperienceProfileId('missing_profile'),
      managementPackId: ProductManagementPackId.coreCatalog,
      channelProfileId: ProductSalesChannelProfileId('ghost_channel'),
    );

    final readiness = assessProductEditionReadiness(edition);

    expect(readiness.level, ProductEditionReadinessLevel.blocked);
    expect(readiness.statusLabel, 'Blocked');
    expect(
      readiness.issues.map((issue) => issue.type),
      containsAll([
        ProductEditionReadinessIssueType.emptyTitle,
        ProductEditionReadinessIssueType.emptySubtitle,
        ProductEditionReadinessIssueType.emptyDescription,
        ProductEditionReadinessIssueType.emptyCapabilitySet,
        ProductEditionReadinessIssueType.missingExperienceProfile,
        ProductEditionReadinessIssueType.unavailableChannelProfile,
      ]),
    );
    expect(readiness.blockingIssues.length, 3);
    expect(readiness.warningIssues.length, 3);
  });

  test('edition readiness reports missing management pack', () {
    const edition = ProductEdition(
      id: ProductEditionId('unknown_pack'),
      title: 'Unknown Pack',
      subtitle: 'Pack gap',
      description: 'Edition references a pack that is not registered.',
      kind: ProductEditionKind.operations,
      experienceProfileId: ProductExperienceProfileId.coreOperations,
      managementPackId: ProductManagementPackId('ghost_pack'),
      channelProfileId: ProductSalesChannelProfileId.omniRetail,
      capabilityLabels: ['Catalog operations'],
    );

    final readiness = assessProductEditionReadiness(edition);

    expect(readiness.level, ProductEditionReadinessLevel.blocked);
    expect(
      readiness.issues.single.type,
      ProductEditionReadinessIssueType.missingManagementPack,
    );
  });

  test('registry readiness reports duplicate edition ids', () {
    const registry = ProductEditionRegistry([
      coreRetailProductEdition,
      coreRetailProductEdition,
    ]);

    final readiness = assessProductEditionRegistryReadiness(registry);

    expect(readiness.isReady, isFalse);
    expect(readiness.blockedEditionCount, 1);
    expect(readiness.statusLabel, '1 blocked');
    expect(
      readiness.editions.last.issues.single.type,
      ProductEditionReadinessIssueType.duplicateEdition,
    );
  });

  test('registry readiness supports custom registries', () {
    const registry = ProductEditionRegistry([
      ProductEdition(
        id: ProductEditionId('coffee_counter'),
        title: 'Coffee Counter',
        subtitle: 'Counter catalog',
        description: 'Coffee shop edition for cashier-led products.',
        kind: ProductEditionKind.counterService,
        experienceProfileId: ProductExperienceProfileId.catalogOperations,
        managementPackId: ProductManagementPackId.coreCatalog,
        channelProfileId: ProductSalesChannelProfileId.counterService,
        capabilityLabels: ['Menu catalog', 'Fast checkout'],
      ),
    ]);

    final readiness = assessProductEditionRegistryReadiness(registry);

    expect(readiness.isReady, isTrue);
    expect(readiness.editions.single.statusLabel, 'Ready');
  });
}
