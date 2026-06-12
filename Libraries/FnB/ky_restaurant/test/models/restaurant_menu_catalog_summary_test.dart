import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('menu catalog summary ranks readiness review work', () {
    final summary = RestaurantMenuCatalogSummary.fromMenu(
      menu: _menu,
      recipes: _recipes,
    );

    expect(summary.itemCount, 4);
    expect(summary.categoryCount, 2);
    expect(summary.orderableCount, 3);
    expect(summary.linkedRecipeCount, 3);
    expect(summary.reviewCount, 3);
    expect(summary.allergenCount, 1);
    expect(summary.hiddenCount, 1);
    expect(summary.topReviewEntry?.id, 'ulam');
    expect(summary.entries.map((entry) => entry.id), [
      'ulam',
      'rib',
      'hidden',
      'spritz',
    ]);
  });

  test('menu catalog entry exposes recipe, margin, and review labels', () {
    final summary = RestaurantMenuCatalogSummary.fromMenu(
      menu: _menu,
      recipes: _recipes,
    );
    final entry = summary.entries.firstWhere((entry) => entry.id == 'rib');

    expect(entry.name, 'Short Rib Rendang');
    expect(entry.categoryLabel, 'Mains');
    expect(entry.availabilityLabel, 'Limited');
    expect(entry.recipeLabel, '30m total recipe');
    expect(entry.routeLabel, 'Station grill');
    expect(entry.marginLabel, '\$17.80 margin');
    expect(entry.marginPercentLabel, '56% margin');
    expect(entry.dietaryLabel, 'Contains nuts');
    expect(entry.reviewLabel, 'Limited inventory');
    expect(entry.needsReview, isTrue);
  });

  test('menu catalog entry treats reviewed items as acknowledged', () {
    final reviewedMenu = _menu.copyWith(
      items: [
        _menu.items.first.copyWith(tags: const [restaurantCatalogReviewedTag]),
        ..._menu.items.skip(1),
      ],
    );
    final summary = RestaurantMenuCatalogSummary.fromMenu(
      menu: reviewedMenu,
      recipes: _recipes,
    );
    final entry = summary.entries.firstWhere((entry) => entry.id == 'rib');

    expect(entry.isReviewed, isTrue);
    expect(entry.needsReview, isFalse);
    expect(entry.reviewLabel, 'Review complete');
    expect(summary.reviewCount, 2);
    expect(summary.topReviewEntry?.id, 'ulam');
    expect(summary.entries.last.id, 'rib');
  });

  test('menu catalog summary resolves station names and route gaps', () {
    final menu = _menu.copyWith(
      items: [
        ..._menu.items,
        const RestaurantMenuItem(
          id: 'bread',
          name: 'Service Bread',
          categoryId: 'mains',
          recipeId: 'bread',
          priceCents: 500,
          displayOrder: 5,
        ),
        const RestaurantMenuItem(
          id: 'stale-route',
          name: 'Stale Route Soup',
          categoryId: 'mains',
          recipeId: 'bread',
          stationId: 'expo',
          priceCents: 900,
          displayOrder: 6,
        ),
      ],
    );
    final summary = RestaurantMenuCatalogSummary.fromMenu(
      menu: menu,
      recipes: [
        ..._recipes,
        const RestaurantRecipe(
          id: 'bread',
          name: 'Service Bread',
          categoryId: 'mains',
          stationId: 'grill',
          prepMinutes: 2,
          fireMinutes: 3,
          yieldQuantity: 1,
          yieldUnit: 'basket',
          costCents: 180,
        ),
      ],
      stations: _stations,
    );

    final rib = summary.entries.firstWhere((entry) => entry.id == 'rib');
    final bread = summary.entries.firstWhere((entry) => entry.id == 'bread');
    final staleRoute = summary.entries.firstWhere(
      (entry) => entry.id == 'stale-route',
    );

    expect(rib.routeLabel, 'Grill station');
    expect(rib.stationLoadLabel, 'Busy: 8 tickets');
    expect(rib.hasStationPressure, isTrue);
    expect(rib.needsStationRouteReview, isFalse);
    expect(bread.routeLabel, 'No station route');
    expect(bread.reviewLabel, 'Station route missing');
    expect(bread.needsReview, isTrue);
    expect(staleRoute.routeLabel, 'Missing station: expo');
    expect(staleRoute.needsStationRouteReview, isTrue);
  });
}

const _menu = RestaurantMenu(
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
      stationId: 'bar',
      priceCents: 1400,
      displayOrder: 2,
    ),
    RestaurantMenuItem(
      id: 'ulam',
      name: 'Nasi Ulam',
      categoryId: 'mains',
      stationId: 'pass',
      priceCents: 1800,
      displayOrder: 3,
    ),
    RestaurantMenuItem(
      id: 'hidden',
      name: 'Secret Dessert',
      categoryId: 'mains',
      recipeId: 'hidden',
      stationId: 'pastry',
      priceCents: 1200,
      availability: RestaurantMenuAvailability.hidden,
      displayOrder: 4,
    ),
  ],
);

const _recipes = [
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
    stationId: 'bar',
    prepMinutes: 4,
    fireMinutes: 2,
    yieldQuantity: 1,
    yieldUnit: 'glass',
    costCents: 360,
  ),
  RestaurantRecipe(
    id: 'hidden',
    name: 'Secret Dessert',
    categoryId: 'mains',
    stationId: 'pastry',
    prepMinutes: 6,
    fireMinutes: 6,
    yieldQuantity: 1,
    yieldUnit: 'plate',
    costCents: 420,
  ),
];

const _stations = [
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
    id: 'bar',
    name: 'Beverage Bar',
    lead: 'Laila',
    ticketsInProgress: 3,
    averageFireMinutes: 4,
    queueLabel: 'Drinks',
    status: RestaurantServiceStatus.calm,
  ),
];
