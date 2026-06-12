import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets(
    'menu catalog panel renders readiness signals and review action',
    (tester) async {
      final reviewedIds = <String>[];

      await pumpRestaurantPanel(
        tester,
        RestaurantMenuCatalogPanel(
          summary: RestaurantMenuCatalogSummary.fromMenu(
            menu: _menu,
            recipes: _recipes,
          ),
          onReviewItem: reviewedIds.add,
        ),
      );

      expect(find.text('Catalog readiness'), findsOneWidget);
      expect(find.text('Dinner - 4 items'), findsOneWidget);
      expect(find.text('3 need review'), findsOneWidget);
      expect(find.text('2 categories'), findsOneWidget);
      expect(find.text('3 recipes linked'), findsOneWidget);
      expect(find.text('3 orderable'), findsOneWidget);
      expect(find.text('1 allergen path'), findsOneWidget);
      expect(find.text('Nasi Ulam: Recipe link missing'), findsOneWidget);
      expect(find.text('Short Rib Rendang'), findsOneWidget);
      expect(find.text('Limited'), findsOneWidget);
      expect(find.text('56% margin'), findsOneWidget);
      expect(find.text('Station grill'), findsOneWidget);
      expect(find.text('Station load unknown'), findsWidgets);
      expect(find.text('Contains nuts'), findsOneWidget);

      await tester.tap(
        find.byTooltip('Review Short Rib Rendang catalog readiness'),
      );
      await tester.pumpAndSettle();

      expect(reviewedIds, ['rib']);
    },
  );

  testWidgets(
    'menu panel composes catalog readiness when catalog is supplied',
    (tester) async {
      final reviewedIds = <String>[];

      await pumpRestaurantPanel(
        tester,
        RestaurantMenuPanel(
          signals: restaurantTestMenuSignals,
          menu: _menu,
          recipes: _recipes,
          stations: _stations,
          onReviewCatalogItem: reviewedIds.add,
        ),
      );

      expect(find.text('Menu mix'), findsOneWidget);
      expect(find.text('Catalog readiness'), findsOneWidget);
      expect(find.text('Grill station'), findsOneWidget);
      expect(find.text('Busy: 8 tickets'), findsOneWidget);
      expect(find.byType(RestaurantMenuCatalogPanel), findsOneWidget);
      expect(find.byType(RestaurantMenuControlsSection), findsOneWidget);
      expect(find.byType(RestaurantMenuSignalList), findsOneWidget);

      await tester.ensureVisible(find.text('Risk 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Risk 1'));
      await tester.pumpAndSettle();

      expect(find.text('Short Rib Rendang'), findsWidgets);
      expect(find.text('Burnt Cheesecake'), findsNothing);

      await tester.ensureVisible(
        find.byTooltip('Review Nasi Ulam catalog readiness'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Review Nasi Ulam catalog readiness'));
      await tester.pumpAndSettle();

      expect(reviewedIds, ['ulam']);
    },
  );

  testWidgets('menu catalog panel keeps a focused item inside its limit', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      RestaurantMenuCatalogPanel(
        summary: RestaurantMenuCatalogSummary.fromMenu(
          menu: _menu,
          recipes: _recipes,
        ),
        limit: 1,
        focusedItemId: 'spritz',
      ),
    );

    expect(find.text('Pandan Spritz'), findsOneWidget);
    expect(find.text('Short Rib Rendang'), findsNothing);
    expect(find.byType(RestaurantMenuCatalogTile), findsOneWidget);
    expect(
      tester.widget<RestaurantMenuCatalogTile>(
        find.byType(RestaurantMenuCatalogTile),
      ),
      isA<RestaurantMenuCatalogTile>()
          .having((tile) => tile.entry.id, 'entry.id', 'spritz')
          .having((tile) => tile.focused, 'focused', isTrue),
    );
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
  RestaurantKitchenStation(
    id: 'pass',
    name: 'Expo Pass',
    lead: 'Dimas',
    ticketsInProgress: 5,
    averageFireMinutes: 6,
    queueLabel: 'Pass',
    status: RestaurantServiceStatus.calm,
  ),
  RestaurantKitchenStation(
    id: 'pastry',
    name: 'Pastry',
    lead: 'Nia',
    ticketsInProgress: 4,
    averageFireMinutes: 8,
    queueLabel: 'Dessert',
    status: RestaurantServiceStatus.busy,
  ),
];
