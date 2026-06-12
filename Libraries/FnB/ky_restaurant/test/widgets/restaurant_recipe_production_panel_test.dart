import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets(
    'recipe production panel renders readiness signals and review action',
    (tester) async {
      final reviewedIds = <String>[];

      await pumpRestaurantPanel(
        tester,
        RestaurantRecipeProductionPanel(
          summary: RestaurantRecipeProductionSummary.fromCatalog(
            recipes: _recipes,
            menu: _menu,
          ),
          onReviewRecipe: reviewedIds.add,
        ),
      );

      expect(find.text('Recipe production'), findsOneWidget);
      expect(find.text('All stations - 3 recipes'), findsOneWidget);
      expect(find.text('2 need review'), findsWidgets);
      expect(find.text('2 linked'), findsOneWidget);
      expect(find.text('2 orderable'), findsOneWidget);
      expect(find.text('14m average'), findsOneWidget);
      expect(find.text('Batch Sambal: Link to a menu item'), findsOneWidget);
      expect(find.text('Short Rib Rendang'), findsOneWidget);
      expect(find.text('Limited'), findsOneWidget);
      expect(find.text('12m prep + 18m fire'), findsOneWidget);
      expect(find.text('Station grill'), findsOneWidget);
      expect(find.text('56% margin'), findsOneWidget);
      expect(find.text('4 portions'), findsOneWidget);
      expect(find.text('Contains nuts'), findsOneWidget);

      await tester.tap(
        find.byTooltip('Review Short Rib Rendang recipe production'),
      );
      await tester.pumpAndSettle();

      expect(reviewedIds, ['rendang']);
    },
  );

  testWidgets(
    'recipe production panel keeps a focused recipe inside its limit',
    (tester) async {
      await pumpRestaurantPanel(
        tester,
        RestaurantRecipeProductionPanel(
          summary: RestaurantRecipeProductionSummary.fromCatalog(
            recipes: _recipes,
            menu: _menu,
          ),
          limit: 1,
          focusedRecipeId: 'spritz',
        ),
      );

      expect(find.text('Pandan Spritz'), findsOneWidget);
      expect(find.text('Batch Sambal'), findsNothing);
      expect(find.byType(RestaurantRecipeProductionTile), findsOneWidget);
      expect(
        tester.widget<RestaurantRecipeProductionTile>(
          find.byType(RestaurantRecipeProductionTile),
        ),
        isA<RestaurantRecipeProductionTile>()
            .having((tile) => tile.entry.id, 'entry.id', 'spritz')
            .having((tile) => tile.focused, 'focused', isTrue),
      );
    },
  );

  testWidgets('recipe production tile renders reviewed state', (tester) async {
    final reviewedSummary = RestaurantRecipeProductionSummary.fromCatalog(
      recipes: _recipes,
      menu: _menu.copyWith(
        items: [
          _menu.items.first.copyWith(
            availability: RestaurantMenuAvailability.available,
            tags: [restaurantRecipeProductionReviewedTag],
          ),
          _menu.items.last,
        ],
      ),
    );

    await pumpRestaurantPanel(
      tester,
      RestaurantRecipeProductionPanel(summary: reviewedSummary),
    );

    expect(find.text('Review complete'), findsOneWidget);
    expect(find.text('Short Rib Rendang: Review complete'), findsNothing);
    expect(
      tester
          .widgetList<RestaurantRecipeProductionTile>(
            find.byType(RestaurantRecipeProductionTile),
          )
          .singleWhere((tile) => tile.entry.id == 'rendang')
          .entry
          .isReviewed,
      isTrue,
    );
  });

  testWidgets(
    'kitchen panel composes recipe production from shared menu and recipes',
    (tester) async {
      final reviewedIds = <String>[];

      await pumpRestaurantPanel(
        tester,
        RestaurantKitchenPanel(
          stations: restaurantTestKitchenStations,
          menu: _menu,
          recipes: _recipes,
          focusedRecipeProductionId: 'spritz',
          onReviewRecipeProduction: reviewedIds.add,
        ),
      );

      expect(find.text('Kitchen flow'), findsOneWidget);
      expect(find.text('Recipe production'), findsOneWidget);
      expect(find.text('Kitchen pressure'), findsOneWidget);
      expect(find.text('Pandan Spritz'), findsOneWidget);
      expect(find.byType(RestaurantRecipeProductionPanel), findsOneWidget);
      expect(find.byType(RestaurantKitchenStationCard), findsWidgets);

      final spritzTile = tester
          .widgetList<RestaurantRecipeProductionTile>(
            find.byType(RestaurantRecipeProductionTile),
          )
          .singleWhere((tile) => tile.entry.id == 'spritz');
      expect(spritzTile.focused, isTrue);

      await tester.ensureVisible(
        find.byTooltip('Review Pandan Spritz recipe production'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byTooltip('Review Pandan Spritz recipe production'),
      );
      await tester.pumpAndSettle();

      expect(reviewedIds, ['spritz']);
    },
  );
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
    id: 'sambal',
    name: 'Batch Sambal',
    categoryId: 'mains',
    stationId: 'wok',
    prepMinutes: 6,
    fireMinutes: 0,
    yieldQuantity: 12,
    yieldUnit: 'portions',
    costCents: 220,
  ),
];
