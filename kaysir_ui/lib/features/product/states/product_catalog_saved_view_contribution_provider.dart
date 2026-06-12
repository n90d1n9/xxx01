import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_catalog_default_saved_view_contributions.dart';
import '../models/product_catalog_saved_view_contribution.dart';

final productCatalogSavedViewContributionsProvider =
    Provider<List<ProductCatalogSavedViewContribution>>((ref) {
      return defaultProductCatalogSavedViewContributionRegistry.contributions;
    });

final productCatalogSavedViewContributionRegistryProvider =
    Provider<ProductCatalogSavedViewContributionRegistry>((ref) {
      return ProductCatalogSavedViewContributionRegistry(
        contributions: ref.watch(productCatalogSavedViewContributionsProvider),
      );
    });
