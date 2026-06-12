import 'package:flutter_test/flutter_test.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

void main() {
  test('menu availability describes ordering and attention states', () {
    expect(FnbMenuAvailability.available.canOrder, isTrue);
    expect(FnbMenuAvailability.limited.needsAttention, isTrue);
    expect(FnbMenuAvailability.soldOut.canOrder, isFalse);
    expect(FnbMenuAvailability.hidden.needsAttention, isFalse);
    expect(FnbMenuAvailability.soldOut.label, 'Sold out');
  });

  test('dietary tags identify allergen labels', () {
    expect(FnbDietaryTag.vegan.label, 'Vegan');
    expect(FnbDietaryTag.containsNuts.isAllergen, isTrue);
    expect(FnbDietaryTag.glutenFree.isAllergen, isFalse);
  });

  test('recipe ingredients and recipes expose production labels', () {
    const ingredient = FnbRecipeIngredient(
      inventoryItemId: 'rice',
      name: 'Heritage rice',
      quantity: 1.5,
      unit: 'kg',
      preparationNote: 'washed',
      costCents: 425,
    );

    final recipe = FnbRecipe(
      id: 'nasi-ulam',
      name: 'Nasi Ulam',
      categoryId: 'mains',
      stationId: 'wok',
      prepMinutes: 8,
      fireMinutes: 6,
      yieldQuantity: 4,
      yieldUnit: 'portions',
      ingredients: const [ingredient],
      steps: const ['Toast coconut', 'Fold herbs through rice'],
      dietaryTags: const {
        FnbDietaryTag.halalFriendly,
        FnbDietaryTag.containsNuts,
      },
      costCents: 1180,
    );

    expect(ingredient.quantityLabel, '1.50 kg');
    expect(ingredient.costLabel, r'$4.25');
    expect(ingredient.label, '1.50 kg Heritage rice, washed');
    expect(recipe.totalMinutes, 14);
    expect(recipe.totalTimeLabel, '14m total');
    expect(recipe.prepTimeLabel, '8m prep');
    expect(recipe.fireTimeLabel, '6m fire');
    expect(recipe.yieldLabel, '4 portions');
    expect(recipe.costLabel, r'$11.80');
    expect(recipe.ingredientCountLabel, '1 ingredient');
    expect(recipe.hasAllergens, isTrue);
    expect(recipe.dietaryLabel, 'Halal friendly, Contains nuts');
  });

  test('menu items expose pricing, routing, and dietary labels', () {
    const item = FnbMenuItem(
      id: 'rendang',
      name: 'Short Rib Rendang',
      categoryId: 'mains',
      priceCents: 2450,
      recipeId: 'rendang-recipe',
      stationId: 'grill',
      prepMinutes: 18,
      availability: FnbMenuAvailability.limited,
      dietaryTags: {FnbDietaryTag.halalFriendly, FnbDietaryTag.spicy},
      tags: ['Signature'],
    );

    expect(item.priceLabel, r'$24.50');
    expect(item.canOrder, isTrue);
    expect(item.hasRecipe, isTrue);
    expect(item.hasKitchenRoute, isTrue);
    expect(item.kitchenRouteLabel, 'Station grill');
    expect(item.prepTimeLabel, '18m');
    expect(item.availabilityLabel, 'Limited');
    expect(item.dietaryLabel, 'Halal friendly, Spicy');
  });

  test('menu recipe readiness evaluates margin recipe and route state', () {
    const item = FnbMenuItem(
      id: 'rendang',
      name: 'Short Rib Rendang',
      categoryId: 'mains',
      priceCents: 3200,
      recipeId: 'rendang-recipe',
      stationId: 'grill',
      availability: FnbMenuAvailability.limited,
      dietaryTags: {FnbDietaryTag.containsNuts},
    );
    const recipe = FnbRecipe(
      id: 'rendang-recipe',
      name: 'Short Rib Rendang',
      categoryId: 'mains',
      stationId: 'grill',
      prepMinutes: 12,
      fireMinutes: 18,
      yieldQuantity: 4,
      yieldUnit: 'portions',
      costCents: 1420,
      dietaryTags: {FnbDietaryTag.containsNuts},
    );
    const station = FnbKitchenStation(
      id: 'grill',
      name: 'Grill',
      lead: 'Ayu',
      ticketsInProgress: 8,
      averageFireMinutes: 14,
      queueLabel: 'Steaks',
      status: FnbServiceStatus.busy,
    );

    const readiness = FnbMenuRecipeReadiness(
      item: item,
      recipe: recipe,
      station: station,
      validatesStationRoute: true,
    );

    expect(readiness.hasRecipe, isTrue);
    expect(readiness.canOrder, isTrue);
    expect(readiness.hasAllergens, isTrue);
    expect(readiness.hasStationPressure, isTrue);
    expect(readiness.needsStationRouteReview, isFalse);
    expect(readiness.grossMarginCents, 1780);
    expect(readiness.grossMarginPercent, closeTo(.556, .001));
    expect(readiness.marginLabel, r'$17.80 margin');
    expect(readiness.marginPercentLabel, '56% margin');
    expect(readiness.recipeLabel, '30m total recipe');
    expect(readiness.routeLabel, 'Grill station');
    expect(readiness.stationLoadLabel, 'Busy: 8 tickets');
    expect(readiness.dietaryLabel, 'Contains nuts');
    expect(
      readiness.primaryIssue,
      FnbMenuRecipeReadinessIssue.limitedInventory,
    );
    expect(readiness.readinessLabel, 'Limited inventory');
    expect(readiness.readinessRank, 2);
  });

  test('menu recipe readiness catches missing recipes and routes', () {
    const missingRecipe = FnbMenuRecipeReadiness(
      item: FnbMenuItem(
        id: 'ulam',
        name: 'Nasi Ulam',
        categoryId: 'mains',
        priceCents: 1800,
        stationId: 'pass',
      ),
      validatesStationRoute: true,
    );
    const missingRoute = FnbMenuRecipeReadiness(
      item: FnbMenuItem(
        id: 'bread',
        name: 'Service Bread',
        categoryId: 'mains',
        priceCents: 500,
        recipeId: 'bread',
      ),
      recipe: FnbRecipe(
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
      validatesStationRoute: true,
    );
    const staleRoute = FnbMenuRecipeReadiness(
      item: FnbMenuItem(
        id: 'soup',
        name: 'Stale Route Soup',
        categoryId: 'mains',
        priceCents: 900,
        recipeId: 'soup',
        stationId: 'expo',
      ),
      recipe: FnbRecipe(
        id: 'soup',
        name: 'Stale Route Soup',
        categoryId: 'mains',
        stationId: 'expo',
        prepMinutes: 2,
        fireMinutes: 3,
        yieldQuantity: 1,
        yieldUnit: 'bowl',
        costCents: 280,
      ),
      validatesStationRoute: true,
    );

    expect(
      missingRecipe.primaryIssue,
      FnbMenuRecipeReadinessIssue.missingRecipe,
    );
    expect(missingRecipe.routeLabel, 'Missing station: pass');
    expect(missingRecipe.stationLoadLabel, 'Station load unknown');
    expect(missingRecipe.marginLabel, 'No recipe cost');
    expect(missingRecipe.marginPercentLabel, 'No margin %');
    expect(
      missingRoute.primaryIssue,
      FnbMenuRecipeReadinessIssue.stationRouteMissing,
    );
    expect(missingRoute.routeLabel, 'No station route');
    expect(
      staleRoute.primaryIssue,
      FnbMenuRecipeReadinessIssue.stationRouteMissing,
    );
    expect(staleRoute.routeLabel, 'Missing station: expo');
  });

  test('recipe production entry exposes linked menu readiness labels', () {
    const entry = FnbRecipeProductionEntry(
      recipe: FnbRecipe(
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
      menuItem: FnbMenuItem(
        id: 'rib',
        name: 'Short Rib Rendang',
        categoryId: 'mains',
        recipeId: 'rendang',
        stationId: 'grill',
        priceCents: 3200,
        availability: FnbMenuAvailability.limited,
        dietaryTags: {FnbDietaryTag.containsNuts},
      ),
    );

    expect(entry.id, 'rendang');
    expect(entry.name, 'Short Rib Rendang');
    expect(entry.categoryId, 'mains');
    expect(entry.stationId, 'grill');
    expect(entry.hasMenuItem, isTrue);
    expect(entry.canOrder, isTrue);
    expect(entry.hasAllergens, isTrue);
    expect(entry.needsAttention, isTrue);
    expect(entry.grossMarginCents, 1780);
    expect(entry.grossMarginPercent, closeTo(.556, .001));
    expect(entry.menuStatusLabel, 'Limited');
    expect(entry.stationLabel, 'Station grill');
    expect(entry.timingLabel, '12m prep + 18m fire');
    expect(entry.productionLabel, '30m total - 2 ingredients');
    expect(entry.stepCountLabel, '3 steps');
    expect(entry.dietaryLabel, 'Contains nuts');
    expect(entry.priceCostLabel, r'$32.00 price - $14.20 cost');
    expect(entry.grossMarginLabel, r'$17.80 margin');
    expect(entry.grossMarginPercentLabel, '56% margin');
    expect(entry.attentionLabel, 'Limited availability');
    expect(entry.attentionRank, 2);
  });

  test('recipe production entry handles unlinked and unrouted recipes', () {
    const entry = FnbRecipeProductionEntry(
      recipe: FnbRecipe(
        id: 'bread',
        name: 'Service Bread',
        categoryId: 'mains',
        stationId: '',
        prepMinutes: 2,
        fireMinutes: 3,
        yieldQuantity: 1,
        yieldUnit: 'basket',
        costCents: 180,
      ),
      menuItem: null,
    );

    expect(entry.name, 'Service Bread');
    expect(entry.hasMenuItem, isFalse);
    expect(entry.canOrder, isFalse);
    expect(entry.needsAttention, isTrue);
    expect(entry.menuStatusLabel, 'No linked item');
    expect(entry.stationLabel, 'No station route');
    expect(entry.dietaryLabel, 'No dietary tags');
    expect(entry.priceCostLabel, r'No menu price - $1.80 cost');
    expect(entry.grossMarginLabel, 'No margin');
    expect(entry.grossMarginPercentLabel, 'No margin %');
    expect(entry.attentionLabel, 'Link to a menu item');
    expect(entry.attentionRank, 0);
  });

  test('menu books sort visible items by category and item order', () {
    const mains = FnbMenuCategory(id: 'mains', name: 'Mains', displayOrder: 2);
    const starters = FnbMenuCategory(
      id: 'starters',
      name: 'Starters',
      displayOrder: 1,
    );
    const hidden = FnbMenuCategory(
      id: 'hidden',
      name: 'Hidden',
      displayOrder: 3,
      isActive: false,
    );
    const menu = FnbMenu(
      id: 'dinner',
      name: 'Dinner',
      categories: [mains, hidden, starters],
      items: [
        FnbMenuItem(
          id: 'rendang',
          name: 'Short Rib Rendang',
          categoryId: 'mains',
          priceCents: 2450,
          displayOrder: 2,
        ),
        FnbMenuItem(
          id: 'ulam',
          name: 'Nasi Ulam',
          categoryId: 'mains',
          priceCents: 1650,
          displayOrder: 1,
        ),
        FnbMenuItem(
          id: 'salad',
          name: 'Herb Salad',
          categoryId: 'starters',
          priceCents: 950,
        ),
        FnbMenuItem(
          id: 'secret',
          name: 'Staff Meal',
          categoryId: 'hidden',
          priceCents: 0,
          availability: FnbMenuAvailability.hidden,
        ),
      ],
    );

    expect(menu.activeCategories.map((category) => category.id), [
      'starters',
      'mains',
    ]);
    expect(menu.visibleItems.map((item) => item.id), [
      'salad',
      'ulam',
      'rendang',
    ]);
    expect(menu.itemsForCategory('mains').map((item) => item.id), [
      'ulam',
      'rendang',
    ]);
    expect(menu.itemCount, 4);
    expect(menu.availableItemCount, 3);
    expect(menu.attentionItemCount, 0);
    expect(menu.itemCountLabel, '4 items');
    expect(menu.availabilitySummaryLabel, '3 available, 0 need attention');
    expect(menu.categoryById('starters')?.name, 'Starters');
    expect(menu.itemById('ulam')?.name, 'Nasi Ulam');
  });
}
