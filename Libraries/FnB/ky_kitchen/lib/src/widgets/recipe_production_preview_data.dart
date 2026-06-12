import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/recipe_production_summary.dart';

/// Builds sample shared menu data for recipe production previews.
FnbMenu kitchenRecipeProductionMenuPreviewData() {
  return const FnbMenu(
    id: 'dinner',
    name: 'Dinner',
    categories: [
      FnbMenuCategory(id: 'mains', name: 'Mains'),
      FnbMenuCategory(id: 'beverage', name: 'Beverage', displayOrder: 2),
    ],
    items: [
      FnbMenuItem(
        id: 'rib',
        name: 'Short Rib Rendang',
        categoryId: 'mains',
        recipeId: 'rendang',
        stationId: 'grill',
        priceCents: 3200,
        prepMinutes: 18,
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
        prepMinutes: 6,
      ),
    ],
  );
}

/// Builds sample shared recipe data for recipe production previews.
List<FnbRecipe> kitchenRecipeProductionRecipesPreviewData() {
  return const [
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
          preparationNote: 'nut-free batch unavailable',
          costCents: 320,
        ),
      ],
      steps: [
        'Warm sauce and glaze short rib.',
        'Finish over grill for caramelized edges.',
        'Confirm allergen garnish path before plating.',
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
      steps: [
        'Build pandan syrup, citrus, and soda over ice.',
        'Garnish with lime leaf.',
      ],
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
      steps: ['Toss rice, herbs, sambal, and crisp garnish.'],
    ),
  ];
}

/// Builds a sample recipe production summary for widget previews.
KitchenRecipeProductionSummary kitchenRecipeProductionSummaryPreviewData() {
  return KitchenRecipeProductionSummary.fromCatalog(
    recipes: kitchenRecipeProductionRecipesPreviewData(),
    menu: kitchenRecipeProductionMenuPreviewData(),
  );
}
