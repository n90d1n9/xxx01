import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/experience_profile_readiness.dart';
import 'package:kaysir/features/product/models/product_module_destination.dart';
import 'package:kaysir/features/product/widgets/experience_profile_readiness_panel.dart';

void main() {
  testWidgets('experience profile readiness panel renders registry health', (
    tester,
  ) async {
    ProductExperienceProfileId? selectedProfileId;
    var reviewCount = 0;

    await tester.binding.setSurfaceSize(const Size(1080, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductExperienceProfileReadinessPanel(
            readiness: assessProductExperienceProfileRegistryReadiness(
              defaultProductExperienceProfileRegistry,
            ),
            onProfileSelected:
                (readiness) => selectedProfileId = readiness.profile.id,
            onReviewProfiles: () => reviewCount += 1,
          ),
        ),
      ),
    );

    expect(find.text('Experience profiles'), findsOneWidget);
    expect(find.text('All profiles ready'), findsAtLeastNWidgets(1));
    expect(find.text('7 profiles'), findsOneWidget);
    expect(find.text('7/7'), findsOneWidget);
    expect(find.text('72/72'), findsOneWidget);
    expect(find.text('Fresh Goods'), findsOneWidget);
    expect(find.text('9/9 destinations'), findsOneWidget);
    expect(find.text('Omnichannel Products'), findsOneWidget);
    expect(find.text('Open workspace'), findsWidgets);
    expect(find.text('Review profile setup'), findsOneWidget);

    await tester.tap(find.text('Fresh Goods'));
    await tester.pump();

    expect(selectedProfileId, ProductExperienceProfileId.freshGoods);

    await tester.tap(find.text('Review profile setup'));
    await tester.pump();

    expect(reviewCount, 1);
  });

  testWidgets('experience profile readiness panel surfaces blocking gaps', (
    tester,
  ) async {
    const registry = ProductExperienceProfileRegistry([
      ProductExperienceProfile(
        id: ProductExperienceProfileId('broken'),
        workspaceTitle: 'Broken Workspace',
        workspaceSubtitle: '',
        workspaceDescription: '',
        destinationIds: [ProductModuleDestinationId.freshnessReview],
      ),
    ]);
    const destinations = ProductModuleDestinationRegistry([
      productCatalogDestination,
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductExperienceProfileReadinessPanel(
            readiness: assessProductExperienceProfileRegistryReadiness(
              registry,
              destinationRegistry: destinations,
            ),
          ),
        ),
      ),
    );

    expect(find.text('1 blocked'), findsAtLeastNWidgets(1));
    expect(find.text('1 profile'), findsOneWidget);
    expect(find.text('0/1'), findsAtLeastNWidgets(1));
    expect(find.text('Broken Workspace'), findsOneWidget);
    expect(find.text('No workspace subtitle set'), findsOneWidget);
    expect(find.text('0/1 destinations'), findsOneWidget);
    expect(
      find.textContaining('Destination freshnessReview is not registered.'),
      findsOneWidget,
    );
  });
}
