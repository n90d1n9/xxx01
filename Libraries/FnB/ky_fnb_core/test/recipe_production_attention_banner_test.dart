import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

void main() {
  testWidgets('recipe production attention banner renders issue copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _WidgetHarness(
        child: FnbRecipeProductionAttentionBanner(
          entry: FnbRecipeProductionEntry(recipe: _recipe, menuItem: null),
        ),
      ),
    );

    expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
    expect(find.text('Batch Sambal: Link to a menu item'), findsOneWidget);
  });

  testWidgets('recipe production attention banner uses status color rules', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _WidgetHarness(
        child: FnbRecipeProductionAttentionBanner(
          entry: FnbRecipeProductionEntry(recipe: _recipe, menuItem: _soldOut),
        ),
      ),
    );

    final context = tester.element(
      find.byType(FnbRecipeProductionAttentionBanner),
    );
    final colors = Theme.of(context).colorScheme;
    final icon = tester.widget<Icon>(find.byIcon(Icons.priority_high_rounded));

    expect(icon.color, colors.error);
    expect(find.text('Batch Sambal: Sold out'), findsOneWidget);
  });
}

/// Minimal Material wrapper for shared FnB widget tests.
class _WidgetHarness extends StatelessWidget {
  const _WidgetHarness({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }
}

const _recipe = FnbRecipe(
  id: 'sambal',
  name: 'Batch Sambal',
  categoryId: 'mains',
  stationId: 'wok',
  prepMinutes: 6,
  fireMinutes: 0,
  yieldQuantity: 12,
  yieldUnit: 'portions',
);

const _soldOut = FnbMenuItem(
  id: 'sambal',
  name: 'Batch Sambal',
  categoryId: 'mains',
  recipeId: 'sambal',
  stationId: 'wok',
  priceCents: 800,
  availability: FnbMenuAvailability.soldOut,
);
