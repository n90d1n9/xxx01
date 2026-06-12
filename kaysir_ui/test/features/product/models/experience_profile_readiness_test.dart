import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/experience_profile_readiness.dart';
import 'package:kaysir/features/product/models/product_module_destination.dart';

void main() {
  test('default product experience profiles are ready', () {
    final readiness = assessProductExperienceProfileRegistryReadiness(
      defaultProductExperienceProfileRegistry,
    );

    expect(readiness.isReady, isTrue);
    expect(readiness.blockedProfileCount, 0);
    expect(readiness.warningProfileCount, 0);
    expect(readiness.statusLabel, 'All profiles ready');
    expect(
      readiness.profiles.every(
        (profile) =>
            profile.level == ProductExperienceProfileReadinessLevel.ready,
      ),
      isTrue,
    );
  });

  test('profile readiness reports missing metadata and destinations', () {
    const profile = ProductExperienceProfile(
      id: ProductExperienceProfileId('broken'),
      workspaceTitle: ' ',
      workspaceSubtitle: '',
      workspaceDescription: '',
      destinationIds: [
        ProductModuleDestinationId.catalog,
        ProductModuleDestinationId.catalog,
        ProductModuleDestinationId.freshnessReview,
      ],
    );
    const source = ProductModuleDestinationRegistry([
      productCatalogDestination,
    ]);

    final readiness = assessProductExperienceProfileReadiness(
      profile,
      destinationRegistry: source,
    );

    expect(readiness.level, ProductExperienceProfileReadinessLevel.blocked);
    expect(readiness.statusLabel, 'Blocked');
    expect(readiness.destinationCoverageLabel, '1/3 destinations');
    expect(
      readiness.issues.map((issue) => issue.type),
      containsAll([
        ProductExperienceProfileReadinessIssueType.emptyWorkspaceTitle,
        ProductExperienceProfileReadinessIssueType.emptyWorkspaceSubtitle,
        ProductExperienceProfileReadinessIssueType.emptyWorkspaceDescription,
        ProductExperienceProfileReadinessIssueType.duplicateDestination,
        ProductExperienceProfileReadinessIssueType.missingDestination,
      ]),
    );
    expect(readiness.blockingIssues.length, 2);
    expect(readiness.warningIssues.length, 3);
  });

  test('empty profile destination set blocks readiness', () {
    const profile = ProductExperienceProfile(
      id: ProductExperienceProfileId('empty'),
      workspaceTitle: 'Empty',
      workspaceSubtitle: 'Empty profile',
      workspaceDescription: 'No destinations configured yet.',
      destinationIds: [],
    );

    final readiness = assessProductExperienceProfileReadiness(profile);

    expect(readiness.level, ProductExperienceProfileReadinessLevel.blocked);
    expect(readiness.destinationCoverageLabel, '0/0 destinations');
    expect(
      readiness.issues.single.type,
      ProductExperienceProfileReadinessIssueType.emptyDestinationSet,
    );
  });

  test('registry readiness summarizes blocked profiles', () {
    const registry = ProductExperienceProfileRegistry([
      productCatalogOperationsExperienceProfile,
      ProductExperienceProfile(
        id: ProductExperienceProfileId('empty'),
        workspaceTitle: '',
        workspaceSubtitle: '',
        workspaceDescription: '',
        destinationIds: [],
      ),
    ]);

    final readiness = assessProductExperienceProfileRegistryReadiness(registry);

    expect(readiness.isReady, isFalse);
    expect(readiness.blockedProfileCount, 1);
    expect(readiness.warningProfileCount, 0);
    expect(readiness.statusLabel, '1 blocked');
  });
}
