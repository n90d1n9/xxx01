import 'dietary_tag.dart';
import 'kitchen_station.dart';
import 'menu_availability.dart';
import 'menu_item.dart';
import 'money_format.dart';
import 'recipe.dart';
import 'service_status.dart';

/// Describes the primary recipe-readiness issue for a menu item.
enum FnbMenuRecipeReadinessIssue {
  missingRecipe,
  soldOut,
  limitedInventory,
  hiddenFromMenu,
  stationRouteMissing,
  allergenReview;

  String get label => switch (this) {
    FnbMenuRecipeReadinessIssue.missingRecipe => 'Recipe link missing',
    FnbMenuRecipeReadinessIssue.soldOut => 'Sold out',
    FnbMenuRecipeReadinessIssue.limitedInventory => 'Limited inventory',
    FnbMenuRecipeReadinessIssue.hiddenFromMenu => 'Hidden from menu',
    FnbMenuRecipeReadinessIssue.stationRouteMissing => 'Station route missing',
    FnbMenuRecipeReadinessIssue.allergenReview => 'Allergen review',
  };

  int get rank => switch (this) {
    FnbMenuRecipeReadinessIssue.missingRecipe => 0,
    FnbMenuRecipeReadinessIssue.soldOut => 1,
    FnbMenuRecipeReadinessIssue.limitedInventory => 2,
    FnbMenuRecipeReadinessIssue.hiddenFromMenu => 3,
    FnbMenuRecipeReadinessIssue.stationRouteMissing => 4,
    FnbMenuRecipeReadinessIssue.allergenReview => 5,
  };
}

/// Evaluates recipe, margin, allergen, and station readiness for a menu item.
class FnbMenuRecipeReadiness {
  const FnbMenuRecipeReadiness({
    required this.item,
    this.recipe,
    this.station,
    this.validatesStationRoute = false,
  });

  final FnbMenuItem item;
  final FnbRecipe? recipe;
  final FnbKitchenStation? station;
  final bool validatesStationRoute;

  bool get hasRecipe => recipe != null;

  bool get canOrder => item.canOrder;

  bool get hasAllergens {
    return item.hasAllergens || (recipe?.hasAllergens ?? false);
  }

  bool get hasStationRoute {
    final stationId = item.stationId?.trim();
    return stationId != null && stationId.isNotEmpty;
  }

  bool get hasKnownStation => station != null;

  bool get hasStationPressure {
    return station?.status.needsAttention ?? false;
  }

  bool get needsStationRouteReview {
    return validatesStationRoute && (!hasStationRoute || !hasKnownStation);
  }

  bool get needsAttention => primaryIssue != null;

  int? get grossMarginCents {
    final recipe = this.recipe;
    if (recipe == null) return null;
    return item.priceCents - recipe.costCents;
  }

  double? get grossMarginPercent {
    final recipe = this.recipe;
    if (recipe == null || item.priceCents == 0) return null;
    return (item.priceCents - recipe.costCents) / item.priceCents;
  }

  FnbMenuRecipeReadinessIssue? get primaryIssue {
    if (!hasRecipe) return FnbMenuRecipeReadinessIssue.missingRecipe;
    return switch (item.availability) {
      FnbMenuAvailability.soldOut => FnbMenuRecipeReadinessIssue.soldOut,
      FnbMenuAvailability.limited =>
        FnbMenuRecipeReadinessIssue.limitedInventory,
      FnbMenuAvailability.hidden => FnbMenuRecipeReadinessIssue.hiddenFromMenu,
      FnbMenuAvailability.available =>
        needsStationRouteReview
            ? FnbMenuRecipeReadinessIssue.stationRouteMissing
            : hasAllergens
            ? FnbMenuRecipeReadinessIssue.allergenReview
            : null,
    };
  }

  String get recipeLabel {
    final recipe = this.recipe;
    if (recipe == null) return 'No recipe';
    return '${recipe.totalTimeLabel} recipe';
  }

  String get routeLabel {
    final stationId = item.stationId?.trim();
    if (stationId == null || stationId.isEmpty) return 'No station route';
    final station = this.station;
    if (station != null) return '${station.name} station';
    if (validatesStationRoute) return 'Missing station: $stationId';
    return item.kitchenRouteLabel;
  }

  String get stationLoadLabel {
    final station = this.station;
    if (station == null) return 'Station load unknown';
    if (station.status == FnbServiceStatus.calm) {
      return '${station.ticketLabel} steady';
    }
    return '${station.status.label}: ${station.ticketLabel}';
  }

  String get marginLabel {
    final margin = grossMarginCents;
    if (margin == null) return 'No recipe cost';
    return '${_formatSignedMoney(margin)} margin';
  }

  String get marginPercentLabel {
    final marginPercent = grossMarginPercent;
    if (marginPercent == null) return 'No margin %';
    return '${(marginPercent * 100).round()}% margin';
  }

  String get dietaryLabel {
    final tags = <FnbDietaryTag>{...item.dietaryTags, ...?recipe?.dietaryTags};
    if (tags.isEmpty) return 'No dietary tags';
    return tags.map((tag) => tag.label).join(', ');
  }

  String get readinessLabel => primaryIssue?.label ?? 'Ready for service';

  int get readinessRank => primaryIssue?.rank ?? 6;
}

String _formatSignedMoney(int cents) {
  if (cents >= 0) return formatFnbMoney(cents);
  return '-${formatFnbMoney(cents.abs())}';
}
