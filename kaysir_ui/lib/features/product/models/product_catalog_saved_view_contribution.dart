import '../../inventory/models/inventory_product_catalog_presentation_state.dart';
import '../../inventory/models/inventory_product_catalog_saved_view.dart';
import 'management_pack.dart';
import 'sales_channel_profile.dart';

typedef ProductCatalogSavedViewContributionPredicate =
    bool Function(ProductCatalogSavedViewContributionContext context);

typedef ProductCatalogSavedViewContributionBuilder =
    Iterable<InventoryProductCatalogSavedView> Function(
      ProductCatalogSavedViewContributionContext context,
    );

class ProductCatalogSavedViewContributionContext {
  const ProductCatalogSavedViewContributionContext({
    required this.seedKey,
    required this.pack,
    required this.channelProfile,
  });

  final String seedKey;
  final ProductManagementPack pack;
  final ProductSalesChannelProfile channelProfile;

  String get modeShortLabel {
    if (pack.id != ProductManagementPackId.coreCatalog) return pack.title;

    return channelProfile.title;
  }

  InventoryProductCatalogSavedView starterView({
    required String suffix,
    required String label,
    required String description,
    required InventoryProductCatalogPresentationPreset preset,
    InventoryProductCatalogPresentationState? presentationState,
  }) {
    return InventoryProductCatalogSavedView(
      id: 'starter-$seedKey.$suffix',
      label: label,
      description: description,
      presentationState: presentationState ?? preset.presentationState,
    );
  }
}

class ProductCatalogSavedViewContribution {
  const ProductCatalogSavedViewContribution({
    required this.id,
    required this.buildViews,
    this.sectionLabel = 'Starter views',
    this.appliesTo = productCatalogSavedViewContributionAlwaysApplies,
  });

  final String id;
  final String sectionLabel;
  final ProductCatalogSavedViewContributionPredicate appliesTo;
  final ProductCatalogSavedViewContributionBuilder buildViews;

  Iterable<InventoryProductCatalogSavedView> viewsFor(
    ProductCatalogSavedViewContributionContext context,
  ) {
    if (!appliesTo(context)) return const <InventoryProductCatalogSavedView>[];

    return buildViews(context);
  }
}

class ProductCatalogSavedViewContributionResult {
  const ProductCatalogSavedViewContributionResult({
    required this.views,
    required this.sectionLabelsByViewId,
  });

  final List<InventoryProductCatalogSavedView> views;
  final Map<String, String> sectionLabelsByViewId;
}

class ProductCatalogSavedViewContributionRegistry {
  const ProductCatalogSavedViewContributionRegistry({
    this.contributions = const <ProductCatalogSavedViewContribution>[],
  });

  final List<ProductCatalogSavedViewContribution> contributions;

  List<String> get contributionIds {
    return List.unmodifiable(
      contributions.map((contribution) => contribution.id),
    );
  }

  List<InventoryProductCatalogSavedView> starterViewsFor(
    ProductCatalogSavedViewContributionContext context,
  ) {
    return starterViewResultFor(context).views;
  }

  ProductCatalogSavedViewContributionResult starterViewResultFor(
    ProductCatalogSavedViewContributionContext context,
  ) {
    final views = <InventoryProductCatalogSavedView>[];
    final sectionLabelsByViewId = <String, String>{};

    for (final contribution in contributions) {
      final contributionViews = contribution
          .viewsFor(context)
          .toList(growable: false);
      final sectionLabel = contribution.sectionLabel.trim();
      views.addAll(contributionViews);

      if (sectionLabel.isEmpty) continue;
      for (final view in contributionViews) {
        final id = view.id.trim();
        if (id.isEmpty) continue;

        sectionLabelsByViewId[id] = sectionLabel;
      }
    }

    final normalizedViews = normalizeInventoryProductCatalogSavedViews(views);
    return ProductCatalogSavedViewContributionResult(
      views: normalizedViews,
      sectionLabelsByViewId: Map.unmodifiable({
        for (final view in normalizedViews)
          if (_sectionLabelForView(sectionLabelsByViewId, view) != null)
            view.id: _sectionLabelForView(sectionLabelsByViewId, view)!,
      }),
    );
  }
}

bool productCatalogSavedViewContributionAlwaysApplies(
  ProductCatalogSavedViewContributionContext context,
) {
  return true;
}

String? _sectionLabelForView(
  Map<String, String> sectionLabelsByViewId,
  InventoryProductCatalogSavedView view,
) {
  final label = sectionLabelsByViewId[view.id]?.trim();
  if (label == null || label.isEmpty) return null;

  return label;
}
