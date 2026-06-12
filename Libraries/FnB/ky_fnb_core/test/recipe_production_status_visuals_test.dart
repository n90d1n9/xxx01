import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

void main() {
  const colors = ColorScheme.light();

  test('recipe production visuals describe reviewed entries', () {
    final visuals = fnbRecipeProductionStatusVisuals(
      colors: colors,
      entry: _entry(
        item: _item(
          availability: FnbMenuAvailability.available,
          tags: [fnbRecipeProductionReviewedTag],
        ),
      ),
    );

    expect(visuals.color, colors.primary);
    expect(visuals.icon, Icons.check_circle_outline);
    expect(visuals.label, 'Review complete');
  });

  test('recipe production visuals describe missing menu links', () {
    final visuals = fnbRecipeProductionStatusVisuals(
      colors: colors,
      entry: _entry(),
    );

    expect(visuals.color, colors.error);
    expect(visuals.icon, Icons.link_off_outlined);
    expect(visuals.label, 'No linked item');
  });

  test('recipe production visuals describe hidden menu items', () {
    final visuals = fnbRecipeProductionStatusVisuals(
      colors: colors,
      entry: _entry(item: _item(availability: FnbMenuAvailability.hidden)),
    );

    expect(visuals.color, colors.tertiary);
    expect(visuals.icon, Icons.visibility_off_outlined);
    expect(visuals.label, 'Hidden');
  });

  test('recipe production visuals keep caller-specific ready icons', () {
    final visuals = fnbRecipeProductionStatusVisuals(
      colors: colors,
      entry: _entry(item: _item()),
      readyIcon: Icons.restaurant_menu_outlined,
    );

    expect(visuals.color, colors.primary);
    expect(visuals.icon, Icons.restaurant_menu_outlined);
    expect(visuals.label, 'Available');
  });
}

FnbRecipeProductionEntry _entry({FnbMenuItem? item}) {
  return FnbRecipeProductionEntry(recipe: _recipe, menuItem: item);
}

FnbMenuItem _item({
  FnbMenuAvailability availability = FnbMenuAvailability.available,
  List<String> tags = const [],
}) {
  return FnbMenuItem(
    id: 'rib',
    name: 'Short Rib Rendang',
    categoryId: 'mains',
    recipeId: _recipe.id,
    stationId: _recipe.stationId,
    priceCents: 3200,
    availability: availability,
    tags: tags,
  );
}

const _recipe = FnbRecipe(
  id: 'rendang',
  name: 'Short Rib Rendang',
  categoryId: 'mains',
  stationId: 'grill',
  prepMinutes: 12,
  fireMinutes: 18,
  yieldQuantity: 4,
  yieldUnit: 'portions',
  costCents: 1420,
);
