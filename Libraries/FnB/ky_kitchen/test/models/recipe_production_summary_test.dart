import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('recipe production summary links menu items and ranks review work', () {
    final summary = KitchenRecipeProductionSummary.fromCatalog(
      recipes: _recipes,
      menu: _menu,
    );

    expect(summary, isA<FnbRecipeProductionSummary>());
    expect(summary.recipeCount, 3);
    expect(summary.linkedItemCount, 2);
    expect(summary.orderableCount, 2);
    expect(summary.attentionCount, 2);
    expect(summary.allergenCount, 1);
    expect(summary.averageTotalMinutes, 17);
    expect(summary.stationIds, ['bar', 'grill', 'pass']);
    expect(summary.topAttentionEntry?.id, 'ulam');
    expect(summary.entries.map((entry) => entry.id), [
      'ulam',
      'rendang',
      'spritz',
    ]);
  });

  test('recipe production entry exposes costing and service labels', () {
    final summary = KitchenRecipeProductionSummary.fromCatalog(
      recipes: _recipes,
      menu: _menu,
    );
    final entry = summary.entries.firstWhere((entry) => entry.id == 'rendang');

    expect(entry, isA<FnbRecipeProductionEntry>());
    expect(entry.name, 'Short Rib Rendang');
    expect(entry.canOrder, isTrue);
    expect(entry.needsAttention, isTrue);
    expect(entry.menuStatusLabel, 'Limited');
    expect(entry.stationLabel, 'Station grill');
    expect(entry.productionLabel, '30m total - 2 ingredients');
    expect(entry.stepCountLabel, '3 steps');
    expect(entry.priceCostLabel, '\$32.00 price - \$14.20 cost');
    expect(entry.grossMarginLabel, '\$17.80 margin');
    expect(entry.grossMarginPercentLabel, '56% margin');
    expect(entry.attentionLabel, 'Limited availability');
  });

  test('recipe production summary filters by station', () {
    final summary = KitchenRecipeProductionSummary.fromCatalog(
      recipes: _recipes,
      menu: _menu,
      stationId: 'bar',
    );

    expect(summary.scopeLabel, 'Station bar');
    expect(summary.recipeCountLabel, '1 recipe');
    expect(summary.entries.single.id, 'spritz');
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
