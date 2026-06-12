import 'kitchen_station.dart';
import 'menu.dart';
import 'menu_availability.dart';
import 'menu_catalog_entry.dart';
import 'recipe.dart';

/// Summarizes shared menu catalog readiness for FnB operating surfaces.
class FnbMenuCatalogSummary {
  const FnbMenuCatalogSummary({required this.menu, required this.entries});

  factory FnbMenuCatalogSummary.fromMenu({
    required FnbMenu menu,
    Iterable<FnbRecipe> recipes = const [],
    Iterable<FnbKitchenStation>? stations,
  }) {
    final recipesById = <String, FnbRecipe>{
      for (final recipe in recipes) recipe.id: recipe,
    };
    final stationsById = stations == null
        ? null
        : <String, FnbKitchenStation>{
            for (final station in stations) station.id: station,
          };
    final entries = menu.items
        .map((item) {
          final recipeId = item.recipeId?.trim();
          final recipe = recipeId == null || recipeId.isEmpty
              ? null
              : recipesById[recipeId];
          final stationId = item.stationId?.trim();
          return FnbMenuCatalogEntry(
            item: item,
            category: menu.categoryById(item.categoryId),
            recipe: recipe,
            station: stationId == null || stationId.isEmpty
                ? null
                : stationsById?[stationId],
            validatesStationRoute: stationsById != null,
          );
        })
        .toList(growable: false);

    final sortedEntries = [...entries]..sort(_compareEntries);

    return FnbMenuCatalogSummary(menu: menu, entries: sortedEntries);
  }

  final FnbMenu menu;
  final List<FnbMenuCatalogEntry> entries;

  bool get hasEntries => entries.isNotEmpty;

  int get itemCount => entries.length;

  int get categoryCount => menu.categories.length;

  int get orderableCount => entries.where((entry) => entry.canOrder).length;

  int get linkedRecipeCount {
    return entries.where((entry) => entry.hasRecipe).length;
  }

  int get reviewCount {
    return entries.where((entry) => entry.needsReview).length;
  }

  int get allergenCount {
    return entries.where((entry) => entry.hasAllergens).length;
  }

  int get hiddenCount {
    return entries
        .where((entry) => entry.item.availability == FnbMenuAvailability.hidden)
        .length;
  }

  FnbMenuCatalogEntry? get topReviewEntry {
    for (final entry in entries) {
      if (entry.needsReview) return entry;
    }
    return null;
  }

  String get itemCountLabel => itemCount == 1 ? '1 item' : '$itemCount items';

  String get categoryCountLabel {
    return categoryCount == 1 ? '1 category' : '$categoryCount categories';
  }

  String get orderableCountLabel {
    return orderableCount == 1 ? '1 orderable' : '$orderableCount orderable';
  }

  String get linkedRecipeCountLabel {
    return linkedRecipeCount == 1
        ? '1 recipe linked'
        : '$linkedRecipeCount recipes linked';
  }

  String get reviewCountLabel {
    return reviewCount == 1 ? '1 needs review' : '$reviewCount need review';
  }

  String get allergenCountLabel {
    return allergenCount == 1
        ? '1 allergen path'
        : '$allergenCount allergen paths';
  }

  String get hiddenCountLabel {
    return hiddenCount == 1 ? '1 hidden item' : '$hiddenCount hidden';
  }

  static int _compareEntries(
    FnbMenuCatalogEntry first,
    FnbMenuCatalogEntry second,
  ) {
    final review = first.reviewRank.compareTo(second.reviewRank);
    if (review != 0) return review;

    final firstCategory = first.category?.displayOrder ?? 1 << 20;
    final secondCategory = second.category?.displayOrder ?? 1 << 20;
    final category = firstCategory.compareTo(secondCategory);
    if (category != 0) return category;

    final itemOrder = first.item.displayOrder.compareTo(
      second.item.displayOrder,
    );
    if (itemOrder != 0) return itemOrder;

    return first.name.compareTo(second.name);
  }
}
