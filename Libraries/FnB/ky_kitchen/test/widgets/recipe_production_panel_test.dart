import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets('recipe production panel renders linked catalog review state', (
    tester,
  ) async {
    final selectedIds = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: KitchenRecipeProductionPanel(
              summary: _summary(),
              selectedRecipeId: 'rendang',
              onRecipeSelected: (entry) => selectedIds.add(entry.id),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Recipe production'), findsOneWidget);
    expect(find.text('All stations - 3 recipes'), findsOneWidget);
    expect(find.text('17m average'), findsOneWidget);
    expect(find.text('2 linked'), findsOneWidget);
    expect(find.text('2 orderable'), findsOneWidget);
    expect(find.text('2 need review'), findsOneWidget);
    expect(find.text('1 allergen path'), findsOneWidget);
    expect(find.text('Nasi Ulam: Link to a menu item'), findsOneWidget);
    expect(find.text('Nasi Ulam'), findsWidgets);
    expect(find.text('Short Rib Rendang'), findsOneWidget);
    expect(find.text('Pandan Spritz'), findsOneWidget);
    expect(find.text('Limited'), findsOneWidget);
    expect(find.text('56% margin'), findsOneWidget);
    expect(find.text('Vegetarian'), findsOneWidget);

    await tester.tap(
      find.byTooltip('Review recipe production for Short Rib Rendang'),
    );
    await tester.pump();

    expect(selectedIds, ['rendang']);
  });

  testWidgets('recipe production panel renders empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenRecipeProductionPanel(
            summary: KitchenRecipeProductionSummary.fromCatalog(
              recipes: const [],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Recipe production'), findsOneWidget);
    expect(find.text('All stations - 0 recipes'), findsOneWidget);
    expect(find.text('No timing'), findsOneWidget);
    expect(
      find.text('No recipes ready for production review.'),
      findsOneWidget,
    );
  });

  testWidgets('recipe production panel keeps selected entries visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenRecipeProductionPanel(
            summary: _summary(),
            limit: 1,
            selectedRecipeId: 'spritz',
          ),
        ),
      ),
    );

    expect(find.text('Pandan Spritz'), findsOneWidget);
    expect(find.text('Nasi Ulam'), findsNothing);
    expect(find.byType(KitchenRecipeProductionTile), findsOneWidget);
    expect(
      tester.widget<KitchenRecipeProductionTile>(
        find.byType(KitchenRecipeProductionTile),
      ),
      isA<KitchenRecipeProductionTile>()
          .having((tile) => tile.entry.id, 'entry.id', 'spritz')
          .having((tile) => tile.selected, 'selected', isTrue),
    );
  });

  testWidgets('recipe production tile renders reviewed state', (tester) async {
    final reviewedSummary = KitchenRecipeProductionSummary.fromCatalog(
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: KitchenRecipeProductionPanel(summary: reviewedSummary),
          ),
        ),
      ),
    );

    expect(find.text('Review complete'), findsOneWidget);
    expect(find.text('Short Rib Rendang: Review complete'), findsNothing);
    expect(
      tester
          .widgetList<KitchenRecipeProductionTile>(
            find.byType(KitchenRecipeProductionTile),
          )
          .singleWhere((tile) => tile.entry.id == 'rendang')
          .entry
          .isReviewed,
      isTrue,
    );
  });
}

KitchenRecipeProductionSummary _summary() {
  return KitchenRecipeProductionSummary.fromCatalog(
    recipes: _recipes,
    menu: _menu,
  );
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
      ),
      FnbRecipeIngredient(
        inventoryItemId: 'spice',
        name: 'Rendang paste',
        quantity: 240,
        unit: 'g',
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
