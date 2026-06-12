import '../models/experience_profile.dart';
import '../models/management_suite_destination.dart';
import 'management_suite_navigation_items.dart';

/// Named navigation profile for focused product management workspaces.
class ProductManagementSuiteNavigationProfile {
  const ProductManagementSuiteNavigationProfile({
    required this.id,
    required this.label,
    required this.sections,
  });

  final String id;
  final String label;
  final List<ProductManagementSuiteNavigationSection> sections;

  List<ProductManagementSuiteNavigationItem> get items {
    return productManagementSuiteNavigationItemsForSections(sections);
  }

  bool contains(ProductManagementSuiteDestination destination) {
    return items.any((item) => item.destination == destination);
  }
}

const productManagementFullSuiteNavigationProfile =
    ProductManagementSuiteNavigationProfile(
      id: 'full-suite',
      label: 'Full suite',
      sections: productManagementSuiteNavigationSections,
    );

const productManagementCatalogOperationsNavigationProfile =
    ProductManagementSuiteNavigationProfile(
      id: 'catalog-operations',
      label: 'Catalog operations',
      sections: [
        ProductManagementSuiteNavigationSection(
          id: 'catalog-ops',
          label: 'Catalog ops',
          items: [
            productManagementSuiteCatalogItem,
            productManagementSuiteAddProductItem,
            productManagementSuiteFreshnessReviewItem,
            productManagementSuiteStockMovementsItem,
            productManagementSuiteAddStockMovementItem,
            productManagementSuiteStockOpnameItem,
            productManagementSuiteScanProductItem,
            productManagementSuiteDiscrepancyReportItem,
          ],
        ),
        ProductManagementSuiteNavigationSection(
          id: 'catalog-readiness',
          label: 'Readiness',
          items: [
            productManagementSuiteAvailabilityManagementItem,
            productManagementSuiteChannelReadinessItem,
          ],
        ),
      ],
    );

const productManagementFreshGoodsNavigationProfile =
    ProductManagementSuiteNavigationProfile(
      id: 'fresh-goods',
      label: 'Fresh goods',
      sections: [
        ProductManagementSuiteNavigationSection(
          id: 'fresh-goods-ops',
          label: 'Fresh ops',
          items: [
            productManagementSuiteCatalogItem,
            productManagementSuiteAddProductItem,
            productManagementSuiteFreshnessReviewItem,
            productManagementSuiteStockOpnameItem,
            productManagementSuiteScanProductItem,
            productManagementSuiteDiscrepancyReportItem,
          ],
        ),
        ProductManagementSuiteNavigationSection(
          id: 'fresh-goods-controls',
          label: 'Controls',
          items: [
            productManagementSuiteAvailabilityManagementItem,
            productManagementSuiteChannelReadinessItem,
            productManagementSuiteSetupTargetsItem,
            productManagementSuitePackContractsItem,
          ],
        ),
      ],
    );

const productManagementCommercialNavigationProfile =
    ProductManagementSuiteNavigationProfile(
      id: 'commercial',
      label: 'Commercial',
      sections: [
        ProductManagementSuiteNavigationSection(
          id: 'commercial',
          label: 'Commercial',
          items: [
            productManagementSuitePricingManagementItem,
            productManagementSuiteSourcingManagementItem,
            productManagementSuiteAvailabilityManagementItem,
            productManagementSuiteChannelReadinessItem,
          ],
        ),
        ProductManagementSuiteNavigationSection(
          id: 'commercial-catalog',
          label: 'Catalog',
          items: [
            productManagementSuiteCatalogItem,
            productManagementSuiteAssortmentPlanningItem,
          ],
        ),
      ],
    );

const productManagementSetupContractsNavigationProfile =
    ProductManagementSuiteNavigationProfile(
      id: 'setup-contracts',
      label: 'Setup & contracts',
      sections: [
        ProductManagementSuiteNavigationSection(
          id: 'setup-contracts',
          label: 'Setup',
          items: [
            productManagementSuiteSetupTargetsItem,
            productManagementSuitePackContractsItem,
          ],
        ),
        ProductManagementSuiteNavigationSection(
          id: 'setup-review',
          label: 'Review',
          items: [
            productManagementSuiteStrategyItem,
            productManagementSuiteCatalogItem,
          ],
        ),
      ],
    );

const productManagementSuiteNavigationProfiles = [
  productManagementFullSuiteNavigationProfile,
  productManagementCatalogOperationsNavigationProfile,
  productManagementFreshGoodsNavigationProfile,
  productManagementCommercialNavigationProfile,
  productManagementSetupContractsNavigationProfile,
];

/// Chooses the default focused navigation profile for a suite destination.
ProductManagementSuiteNavigationProfile
productManagementSuiteNavigationProfileForDestination(
  ProductManagementSuiteDestination destination,
) {
  return switch (destination) {
    ProductManagementSuiteDestination.freshnessReview =>
      productManagementFreshGoodsNavigationProfile,
    ProductManagementSuiteDestination.pricingManagement ||
    ProductManagementSuiteDestination.sourcingManagement ||
    ProductManagementSuiteDestination.availabilityManagement ||
    ProductManagementSuiteDestination
        .channelReadiness => productManagementCommercialNavigationProfile,
    ProductManagementSuiteDestination.setupTargets ||
    ProductManagementSuiteDestination
        .packContracts => productManagementSetupContractsNavigationProfile,
    ProductManagementSuiteDestination.catalog ||
    ProductManagementSuiteDestination.addProduct ||
    ProductManagementSuiteDestination.stockMovements ||
    ProductManagementSuiteDestination.addStockMovement ||
    ProductManagementSuiteDestination.stockOpname ||
    ProductManagementSuiteDestination.scanProduct ||
    ProductManagementSuiteDestination.discrepancyReport =>
      productManagementCatalogOperationsNavigationProfile,
    _ => productManagementFullSuiteNavigationProfile,
  };
}

/// Builds a focused suite navigation profile from an experience profile.
ProductManagementSuiteNavigationProfile
productManagementSuiteNavigationProfileForExperienceProfile(
  ProductExperienceProfile experienceProfile, {
  required ProductManagementSuiteDestination activeDestination,
}) {
  final destinations = <ProductManagementSuiteDestination>{};
  for (final id in experienceProfile.destinationIds) {
    final destination = productManagementSuiteDestinationForModuleDestinationId(
      id,
    );
    if (destination != null) destinations.add(destination);
  }

  if (!destinations.contains(activeDestination)) {
    return productManagementSuiteNavigationProfileForDestination(
      activeDestination,
    );
  }

  final sections = [
    for (final section in productManagementSuiteNavigationSections)
      ProductManagementSuiteNavigationSection(
        id: section.id,
        label: section.label,
        items: [
          for (final item in section.items)
            if (destinations.contains(item.destination)) item,
        ],
      ),
  ].where((section) => section.hasItems).toList(growable: false);

  if (sections.isEmpty) {
    return productManagementSuiteNavigationProfileForDestination(
      activeDestination,
    );
  }

  return ProductManagementSuiteNavigationProfile(
    id: 'experience-${experienceProfile.id.value}',
    label: experienceProfile.workspaceTitle,
    sections: sections,
  );
}
