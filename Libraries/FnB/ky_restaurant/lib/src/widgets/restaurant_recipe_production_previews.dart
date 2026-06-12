import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/restaurant_models.dart';
import 'restaurant_recipe_production_panel.dart';
import 'restaurant_recipe_production_tile.dart';

/// Preview entry for restaurant recipe production readiness.
@Preview(name: 'Recipe Production Readiness', group: 'Restaurant')
Widget restaurantRecipeProductionPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RestaurantRecipeProductionPanel(
          summary: restaurantRecipeProductionPreviewSummary(),
          onReviewRecipe: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for one restaurant recipe production row.
@Preview(name: 'Recipe Production Tile', group: 'Restaurant')
Widget restaurantRecipeProductionTilePreview() {
  final summary = restaurantRecipeProductionPreviewSummary();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantRecipeProductionTile(
          entry: summary.entries.first,
          onReview: (_) {},
        ),
      ),
    ),
  );
}

/// Builds shared recipe production preview data for restaurant widgets.
RestaurantRecipeProductionSummary restaurantRecipeProductionPreviewSummary() {
  return RestaurantRecipeProductionSummary.fromCatalog(
    recipes: _previewRecipes,
    menu: _previewMenu,
  );
}

const _previewMenu = RestaurantMenu(
  id: 'dinner',
  name: 'Dinner',
  categories: [
    RestaurantMenuCategory(id: 'mains', name: 'Mains'),
    RestaurantMenuCategory(id: 'beverage', name: 'Beverage', displayOrder: 2),
  ],
  items: [
    RestaurantMenuItem(
      id: 'rib',
      name: 'Short Rib Rendang',
      categoryId: 'mains',
      recipeId: 'rendang',
      stationId: 'grill',
      priceCents: 3200,
      availability: RestaurantMenuAvailability.limited,
      dietaryTags: {RestaurantDietaryTag.containsNuts},
    ),
    RestaurantMenuItem(
      id: 'spritz',
      name: 'Pandan Spritz',
      categoryId: 'beverage',
      recipeId: 'spritz',
      stationId: 'barista',
      priceCents: 1400,
    ),
  ],
);

const _previewRecipes = [
  RestaurantRecipe(
    id: 'rendang',
    name: 'Short Rib Rendang',
    categoryId: 'mains',
    stationId: 'grill',
    prepMinutes: 12,
    fireMinutes: 18,
    yieldQuantity: 4,
    yieldUnit: 'portions',
    costCents: 1420,
    dietaryTags: {RestaurantDietaryTag.containsNuts},
  ),
  RestaurantRecipe(
    id: 'spritz',
    name: 'Pandan Spritz',
    categoryId: 'beverage',
    stationId: 'barista',
    prepMinutes: 4,
    fireMinutes: 2,
    yieldQuantity: 1,
    yieldUnit: 'glass',
    costCents: 360,
  ),
];
