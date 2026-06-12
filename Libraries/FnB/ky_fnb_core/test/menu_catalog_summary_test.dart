import 'package:flutter_test/flutter_test.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

void main() {
  test('menu catalog summary ranks readiness review work', () {
    final summary = FnbMenuCatalogSummary.fromMenu(
      menu: _menu,
      recipes: _recipes,
    );

    expect(summary.hasEntries, isTrue);
    expect(summary.itemCount, 4);
    expect(summary.categoryCount, 2);
    expect(summary.orderableCount, 3);
    expect(summary.linkedRecipeCount, 3);
    expect(summary.reviewCount, 3);
    expect(summary.allergenCount, 1);
    expect(summary.hiddenCount, 1);
    expect(summary.itemCountLabel, '4 items');
    expect(summary.categoryCountLabel, '2 categories');
    expect(summary.linkedRecipeCountLabel, '3 recipes linked');
    expect(summary.reviewCountLabel, '3 need review');
    expect(summary.hiddenCountLabel, '1 hidden item');
    expect(summary.topReviewEntry?.id, 'ulam');
    expect(summary.entries.map((entry) => entry.id), [
      'ulam',
      'rib',
      'hidden',
      'spritz',
    ]);
  });

  test('menu catalog entry exposes recipe, margin, and review labels', () {
    final summary = FnbMenuCatalogSummary.fromMenu(
      menu: _menu,
      recipes: _recipes,
    );
    final entry = summary.entries.firstWhere((entry) => entry.id == 'rib');

    expect(entry.name, 'Short Rib Rendang');
    expect(entry.categoryLabel, 'Mains');
    expect(entry.availabilityLabel, 'Limited');
    expect(entry.recipeLabel, '30m total recipe');
    expect(entry.routeLabel, 'Station grill');
    expect(entry.marginLabel, r'$17.80 margin');
    expect(entry.marginPercentLabel, '56% margin');
    expect(entry.dietaryLabel, 'Contains nuts');
    expect(entry.reviewLabel, 'Limited inventory');
    expect(entry.needsReview, isTrue);
  });

  test('menu catalog entry treats reviewed items as acknowledged', () {
    final reviewedMenu = _menu.copyWith(
      items: [
        _menu.items.first.copyWith(tags: const [fnbMenuCatalogReviewedTag]),
        ..._menu.items.skip(1),
      ],
    );
    final summary = FnbMenuCatalogSummary.fromMenu(
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
        const FnbMenuItem(
          id: 'bread',
          name: 'Service Bread',
          categoryId: 'mains',
          recipeId: 'bread',
          priceCents: 500,
          displayOrder: 5,
        ),
        const FnbMenuItem(
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
    final summary = FnbMenuCatalogSummary.fromMenu(
      menu: menu,
      recipes: [
        ..._recipes,
        const FnbRecipe(
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

const _menu = FnbMenu(
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
      displayOrder: 2,
    ),
    FnbMenuItem(
      id: 'ulam',
      name: 'Nasi Ulam',
      categoryId: 'mains',
      stationId: 'pass',
      priceCents: 1800,
      displayOrder: 3,
    ),
    FnbMenuItem(
      id: 'hidden',
      name: 'Secret Dessert',
      categoryId: 'mains',
      recipeId: 'hidden',
      stationId: 'pastry',
      priceCents: 1200,
      availability: FnbMenuAvailability.hidden,
      displayOrder: 4,
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
  ),
  FnbRecipe(
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
  FnbKitchenStation(
    id: 'grill',
    name: 'Grill',
    lead: 'Ari',
    ticketsInProgress: 8,
    averageFireMinutes: 14,
    queueLabel: 'Grill queue',
    status: FnbServiceStatus.busy,
  ),
  FnbKitchenStation(
    id: 'bar',
    name: 'Beverage Bar',
    lead: 'Laila',
    ticketsInProgress: 3,
    averageFireMinutes: 4,
    queueLabel: 'Drinks',
    status: FnbServiceStatus.calm,
  ),
  FnbKitchenStation(
    id: 'pass',
    name: 'Expo Pass',
    lead: 'Dimas',
    ticketsInProgress: 5,
    averageFireMinutes: 6,
    queueLabel: 'Pass',
    status: FnbServiceStatus.calm,
  ),
  FnbKitchenStation(
    id: 'pastry',
    name: 'Pastry',
    lead: 'Nia',
    ticketsInProgress: 4,
    averageFireMinutes: 8,
    queueLabel: 'Dessert',
    status: FnbServiceStatus.busy,
  ),
];
