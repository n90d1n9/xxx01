import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/restaurant_menu_catalog_summary.dart';
import '../models/restaurant_models.dart';
import 'restaurant_menu_catalog_panel.dart';
import 'restaurant_menu_catalog_tile.dart';

/// Preview entry for restaurant menu catalog readiness.
@Preview(name: 'Menu Catalog Readiness', group: 'Restaurant')
Widget restaurantMenuCatalogPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RestaurantMenuCatalogPanel(
          summary: restaurantMenuCatalogPreviewSummary(),
          onReviewItem: (_) {},
        ),
      ),
    ),
  );
}

/// Preview entry for one restaurant menu catalog row.
@Preview(name: 'Menu Catalog Tile', group: 'Restaurant')
Widget restaurantMenuCatalogTilePreview() {
  final summary = restaurantMenuCatalogPreviewSummary();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantMenuCatalogTile(
          entry: summary.entries.first,
          onReview: (_) {},
        ),
      ),
    ),
  );
}

/// Builds shared menu catalog preview data for restaurant widgets.
RestaurantMenuCatalogSummary restaurantMenuCatalogPreviewSummary() {
  return RestaurantMenuCatalogSummary.fromMenu(
    menu: _previewMenu,
    recipes: _previewRecipes,
    stations: _previewStations,
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
    RestaurantMenuItem(
      id: 'ulam',
      name: 'Nasi Ulam',
      categoryId: 'mains',
      stationId: 'wok',
      priceCents: 1800,
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

const _previewStations = [
  RestaurantKitchenStation(
    id: 'grill',
    name: 'Grill',
    lead: 'Ari',
    ticketsInProgress: 8,
    averageFireMinutes: 14,
    queueLabel: 'Grill queue',
    status: RestaurantServiceStatus.busy,
  ),
  RestaurantKitchenStation(
    id: 'barista',
    name: 'Barista',
    lead: 'Laila',
    ticketsInProgress: 3,
    averageFireMinutes: 4,
    queueLabel: 'Drinks',
    status: RestaurantServiceStatus.calm,
  ),
  RestaurantKitchenStation(
    id: 'wok',
    name: 'Wok',
    lead: 'Mei',
    ticketsInProgress: 5,
    averageFireMinutes: 9,
    queueLabel: 'Rice and noodles',
    status: RestaurantServiceStatus.busy,
  ),
];
