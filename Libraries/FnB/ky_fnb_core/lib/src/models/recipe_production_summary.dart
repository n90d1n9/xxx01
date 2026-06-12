import 'menu.dart';
import 'menu_item.dart';
import 'recipe.dart';
import 'recipe_production_entry.dart';

/// Builds shared recipe production state from FnB recipe and menu catalogs.
class FnbRecipeProductionSummary {
  const FnbRecipeProductionSummary({required this.entries, this.stationId});

  factory FnbRecipeProductionSummary.fromCatalog({
    required Iterable<FnbRecipe> recipes,
    FnbMenu? menu,
    String? stationId,
  }) {
    final normalizedStationId = stationId?.trim();
    final itemsByRecipeId = <String, FnbMenuItem>{};
    for (final item in menu?.items ?? const <FnbMenuItem>[]) {
      final recipeId = item.recipeId?.trim();
      if (recipeId == null || recipeId.isEmpty) continue;
      itemsByRecipeId.putIfAbsent(recipeId, () => item);
    }

    final entries = recipes
        .where(
          (recipe) =>
              normalizedStationId == null ||
              normalizedStationId.isEmpty ||
              recipe.stationId == normalizedStationId,
        )
        .map(
          (recipe) => FnbRecipeProductionEntry(
            recipe: recipe,
            menuItem: itemsByRecipeId[recipe.id],
          ),
        )
        .toList(growable: false);

    final sortedEntries = [...entries]..sort(_compareEntries);

    return FnbRecipeProductionSummary(
      entries: sortedEntries,
      stationId: normalizedStationId?.isEmpty ?? true
          ? null
          : normalizedStationId,
    );
  }

  final List<FnbRecipeProductionEntry> entries;
  final String? stationId;

  bool get hasEntries => entries.isNotEmpty;

  int get recipeCount => entries.length;

  int get linkedItemCount {
    return entries.where((entry) => entry.hasMenuItem).length;
  }

  int get orderableCount {
    return entries.where((entry) => entry.canOrder).length;
  }

  int get attentionCount {
    return entries.where((entry) => entry.needsAttention).length;
  }

  int get allergenCount {
    return entries.where((entry) => entry.hasAllergens).length;
  }

  int get averageTotalMinutes {
    if (entries.isEmpty) return 0;
    final total = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.recipe.totalMinutes,
    );
    return (total / entries.length).round();
  }

  List<String> get stationIds {
    final ids = entries
        .map((entry) => entry.stationId)
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);
    ids.sort();
    return ids;
  }

  FnbRecipeProductionEntry? get topAttentionEntry {
    for (final entry in entries) {
      if (entry.needsAttention) return entry;
    }
    return null;
  }

  String get recipeCountLabel {
    return recipeCount == 1 ? '1 recipe' : '$recipeCount recipes';
  }

  String get linkedItemCountLabel {
    return linkedItemCount == 1 ? '1 linked item' : '$linkedItemCount linked';
  }

  String get orderableCountLabel {
    return orderableCount == 1 ? '1 orderable' : '$orderableCount orderable';
  }

  String get attentionCountLabel {
    return attentionCount == 1
        ? '1 needs review'
        : '$attentionCount need review';
  }

  String get allergenCountLabel {
    return allergenCount == 1
        ? '1 allergen path'
        : '$allergenCount allergen paths';
  }

  String get averageTimeLabel {
    if (entries.isEmpty) return 'No timing';
    return '${averageTotalMinutes}m average';
  }

  String get scopeLabel {
    final station = stationId;
    if (station == null) return 'All stations';
    return 'Station $station';
  }

  static int _compareEntries(
    FnbRecipeProductionEntry first,
    FnbRecipeProductionEntry second,
  ) {
    final attention = first.attentionRank.compareTo(second.attentionRank);
    if (attention != 0) return attention;

    final station = first.stationId.compareTo(second.stationId);
    if (station != 0) return station;

    final timing = second.recipe.totalMinutes.compareTo(
      first.recipe.totalMinutes,
    );
    if (timing != 0) return timing;

    return first.name.compareTo(second.name);
  }
}
