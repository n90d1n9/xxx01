import 'kitchen_station.dart';
import 'menu_category.dart';
import 'menu_item.dart';
import 'menu_recipe_readiness.dart';
import 'recipe.dart';

/// Menu item tag used when an operator has acknowledged catalog readiness.
const fnbMenuCatalogReviewedTag = 'Catalog reviewed';

/// Combines one shared menu item with category, recipe, and station readiness.
class FnbMenuCatalogEntry {
  const FnbMenuCatalogEntry({
    required this.item,
    this.category,
    this.recipe,
    this.station,
    this.validatesStationRoute = false,
  });

  final FnbMenuItem item;
  final FnbMenuCategory? category;
  final FnbRecipe? recipe;
  final FnbKitchenStation? station;
  final bool validatesStationRoute;

  FnbMenuRecipeReadiness get readiness {
    return FnbMenuRecipeReadiness(
      item: item,
      recipe: recipe,
      station: station,
      validatesStationRoute: validatesStationRoute,
    );
  }

  String get id => item.id;

  String get name => item.name;

  String get categoryLabel => category?.name ?? item.categoryId;

  bool get hasRecipe => readiness.hasRecipe;

  bool get canOrder => readiness.canOrder;

  bool get hasAllergens => readiness.hasAllergens;

  bool get isReviewed => item.tags.contains(fnbMenuCatalogReviewedTag);

  bool get hasStationRoute => readiness.hasStationRoute;

  bool get hasKnownStation => readiness.hasKnownStation;

  bool get hasStationPressure => readiness.hasStationPressure;

  bool get needsStationRouteReview => readiness.needsStationRouteReview;

  bool get needsReview {
    return !isReviewed && readiness.needsAttention;
  }

  int? get grossMarginCents => readiness.grossMarginCents;

  double? get grossMarginPercent => readiness.grossMarginPercent;

  String get priceLabel => item.priceLabel;

  String get availabilityLabel => item.availabilityLabel;

  String get routeLabel => readiness.routeLabel;

  String get stationLoadLabel => readiness.stationLoadLabel;

  String get recipeLabel => readiness.recipeLabel;

  String get marginLabel => readiness.marginLabel;

  String get marginPercentLabel => readiness.marginPercentLabel;

  String get dietaryLabel => readiness.dietaryLabel;

  String get reviewLabel {
    if (isReviewed) return 'Review complete';
    return readiness.readinessLabel;
  }

  int get reviewRank {
    if (isReviewed) return 7;
    return readiness.readinessRank;
  }
}
