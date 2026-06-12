import 'dietary_tag.dart';
import 'menu_availability.dart';
import 'menu_item.dart';
import 'money_format.dart';
import 'recipe.dart';

/// Menu item tag used when an operator has acknowledged production readiness.
const fnbRecipeProductionReviewedTag = 'Recipe production reviewed';

/// Combines a shared recipe with its sellable menu item for production review.
class FnbRecipeProductionEntry {
  const FnbRecipeProductionEntry({
    required this.recipe,
    required this.menuItem,
  });

  final FnbRecipe recipe;
  final FnbMenuItem? menuItem;

  String get id => recipe.id;

  String get name => menuItem?.name ?? recipe.name;

  String get categoryId => menuItem?.categoryId ?? recipe.categoryId;

  String get stationId => recipe.stationId;

  bool get hasMenuItem => menuItem != null;

  bool get canOrder => menuItem?.canOrder ?? false;

  bool get isReviewed {
    return menuItem?.tags.contains(fnbRecipeProductionReviewedTag) ?? false;
  }

  bool get hasAllergens {
    return recipe.hasAllergens || (menuItem?.hasAllergens ?? false);
  }

  bool get needsAttention {
    if (isReviewed) return false;
    final item = menuItem;
    if (item == null) return true;
    return item.availability.needsAttention ||
        item.availability == FnbMenuAvailability.hidden ||
        hasAllergens;
  }

  int? get grossMarginCents {
    final item = menuItem;
    if (item == null) return null;
    return item.priceCents - recipe.costCents;
  }

  double? get grossMarginPercent {
    final item = menuItem;
    if (item == null || item.priceCents == 0) return null;
    return (item.priceCents - recipe.costCents) / item.priceCents;
  }

  String get menuStatusLabel {
    final item = menuItem;
    if (item == null) return 'No linked item';
    return item.availabilityLabel;
  }

  String get stationLabel {
    final station = stationId.trim();
    if (station.isEmpty) return 'No station route';
    return 'Station $station';
  }

  String get timingLabel {
    return '${recipe.prepTimeLabel} + ${recipe.fireTimeLabel}';
  }

  String get productionLabel {
    return '${recipe.totalTimeLabel} - ${recipe.ingredientCountLabel}';
  }

  String get stepCountLabel {
    final count = recipe.steps.length;
    return count == 1 ? '1 step' : '$count steps';
  }

  String get dietaryLabel {
    final tags = recipe.dietaryTags.isNotEmpty
        ? recipe.dietaryTags
        : menuItem?.dietaryTags ?? const <FnbDietaryTag>{};
    if (tags.isEmpty) return 'No dietary tags';
    return tags.map((tag) => tag.label).join(', ');
  }

  String get priceCostLabel {
    final item = menuItem;
    if (item == null) return 'No menu price - ${recipe.costLabel} cost';
    return '${item.priceLabel} price - ${recipe.costLabel} cost';
  }

  String get grossMarginLabel {
    final margin = grossMarginCents;
    if (margin == null) return 'No margin';
    return '${_formatSignedMoney(margin)} margin';
  }

  String get grossMarginPercentLabel {
    final marginPercent = grossMarginPercent;
    if (marginPercent == null) return 'No margin %';
    return '${(marginPercent * 100).round()}% margin';
  }

  String get attentionLabel {
    if (isReviewed) return 'Review complete';
    final item = menuItem;
    if (item == null) return 'Link to a menu item';
    if (item.availability == FnbMenuAvailability.soldOut) return 'Sold out';
    if (item.availability == FnbMenuAvailability.limited) {
      return 'Limited availability';
    }
    if (item.availability == FnbMenuAvailability.hidden) {
      return 'Hidden from menu';
    }
    if (hasAllergens) return 'Allergen review';
    return 'Ready for service';
  }

  int get attentionRank {
    if (isReviewed) return 6;
    final item = menuItem;
    if (item == null) return 0;
    return switch (item.availability) {
      FnbMenuAvailability.soldOut => 1,
      FnbMenuAvailability.limited => 2,
      FnbMenuAvailability.hidden => 3,
      FnbMenuAvailability.available => hasAllergens ? 4 : 5,
    };
  }
}

String _formatSignedMoney(int cents) {
  if (cents >= 0) return formatFnbMoney(cents);
  return '-${formatFnbMoney(cents.abs())}';
}
