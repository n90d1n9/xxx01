import 'package:flutter_test/flutter_test.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

void main() {
  test('recipe production summary links menu items and ranks review work', () {
    final summary = FnbRecipeProductionSummary.fromCatalog(
      recipes: _recipes,
      menu: _menu,
    );

    expect(summary.hasEntries, isTrue);
    expect(summary.recipeCount, 3);
    expect(summary.linkedItemCount, 2);
    expect(summary.orderableCount, 2);
    expect(summary.attentionCount, 2);
    expect(summary.allergenCount, 1);
    expect(summary.averageTotalMinutes, 17);
    expect(summary.averageTimeLabel, '17m average');
    expect(summary.stationIds, ['bar', 'grill', 'pass']);
    expect(summary.scopeLabel, 'All stations');
    expect(summary.topAttentionEntry?.id, 'ulam');
    expect(summary.entries.map((entry) => entry.id), [
      'ulam',
      'rendang',
      'spritz',
    ]);
  });

  test('recipe production summary filters by station', () {
    final summary = FnbRecipeProductionSummary.fromCatalog(
      recipes: _recipes,
      menu: _menu,
      stationId: 'bar',
    );

    expect(summary.scopeLabel, 'Station bar');
    expect(summary.recipeCountLabel, '1 recipe');
    expect(summary.linkedItemCountLabel, '1 linked item');
    expect(summary.orderableCountLabel, '1 orderable');
    expect(summary.attentionCountLabel, '0 need review');
    expect(summary.allergenCountLabel, '0 allergen paths');
    expect(summary.entries.single.id, 'spritz');
  });

  test('reviewed recipe production entries are no longer actionable', () {
    final summary = FnbRecipeProductionSummary.fromCatalog(
      recipes: _recipes,
      menu: _menu.copyWith(
        items: [
          _menu.items.first.copyWith(
            availability: FnbMenuAvailability.available,
            tags: [fnbRecipeProductionReviewedTag],
          ),
          _menu.items.last,
        ],
      ),
    );

    final rendang = summary.entries.singleWhere(
      (entry) => entry.id == 'rendang',
    );

    expect(rendang.isReviewed, isTrue);
    expect(rendang.needsAttention, isFalse);
    expect(rendang.attentionLabel, 'Review complete');
    expect(summary.attentionCount, 1);
  });
}

const _menu = FnbMenu(
  id: 'dinner',
  name: 'Dinner',
  items: [
    FnbMenuItem(
      id: 'rib',
      name: 'Short Rib Rendang',
      categoryId: 'mains',
      recipeId: 'rendang',
      stationId: 'grill',
      priceCents: 3200,
      availability: FnbMenuAvailability.limited,
      dietaryTags: {FnbDietaryTag.containsNuts},
    ),
    FnbMenuItem(
      id: 'spritz',
      name: 'Pandan Spritz',
      categoryId: 'beverage',
      recipeId: 'spritz',
      stationId: 'bar',
      priceCents: 1400,
    ),
  ],
);

const _recipes = [
  FnbRecipe(
    id: 'rendang',
    name: 'Short Rib Rendang',
    categoryId: 'mains',
    stationId: 'grill',
    prepMinutes: 12,
    fireMinutes: 18,
    yieldQuantity: 4,
    yieldUnit: 'portions',
    costCents: 1420,
    dietaryTags: {FnbDietaryTag.containsNuts},
    ingredients: [
      FnbRecipeIngredient(
        inventoryItemId: 'rib',
        name: 'Braised short rib',
        quantity: 1.2,
        unit: 'kg',
        costCents: 900,
      ),
      FnbRecipeIngredient(
        inventoryItemId: 'spice',
        name: 'Rendang paste',
        quantity: 240,
        unit: 'g',
        costCents: 320,
      ),
    ],
    steps: [
      'Warm sauce and glaze short rib.',
      'Finish over grill.',
      'Confirm allergen garnish path.',
    ],
  ),
  FnbRecipe(
    id: 'spritz',
    name: 'Pandan Spritz',
    categoryId: 'beverage',
    stationId: 'bar',
    prepMinutes: 4,
    fireMinutes: 2,
    yieldQuantity: 1,
    yieldUnit: 'glass',
    costCents: 360,
    steps: ['Build syrup and citrus over ice.', 'Top with soda.'],
  ),
  FnbRecipe(
    id: 'ulam',
    name: 'Nasi Ulam',
    categoryId: 'mains',
    stationId: 'pass',
    prepMinutes: 8,
    fireMinutes: 6,
    yieldQuantity: 2,
    yieldUnit: 'bowls',
    costCents: 520,
    dietaryTags: {FnbDietaryTag.vegetarian},
    steps: ['Toss rice, herbs, sambal, and garnish.'],
  ),
];
