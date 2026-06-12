import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  testWidgets('workspace panel layout stacks panels below breakpoint', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 480,
            child: RestaurantWorkspacePanelLayout(
              panels: const [
                _TestPanel(label: 'Panel A'),
                _TestPanel(label: 'Panel B'),
                _TestPanel(label: 'Panel C'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Row), findsNothing);
    expect(find.byType(RestaurantWorkspacePanelColumn), findsOneWidget);
    expect(find.text('Panel A'), findsOneWidget);
    expect(find.text('Panel C'), findsOneWidget);
  });

  testWidgets('workspace panel layout balances panels above breakpoint', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: RestaurantWorkspacePanelLayout(
              wideBreakpoint: 700,
              panels: const [
                _TestPanel(label: 'Panel A'),
                _TestPanel(label: 'Panel B'),
                _TestPanel(label: 'Panel C'),
                _TestPanel(label: 'Panel D'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Row), findsOneWidget);
    expect(find.byType(RestaurantWorkspacePanelColumn), findsNWidgets(2));
    expect(
      tester.getTopLeft(find.text('Panel C')).dx,
      greaterThan(tester.getTopLeft(find.text('Panel A')).dx),
    );
  });

  testWidgets('workspace panel deck passes menu catalog into menu panel', (
    tester,
  ) async {
    final reviewedIds = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RestaurantWorkspacePanelDeck(
              plan: RestaurantWorkspacePanelPlan.menu,
              snapshot: restaurantDemoSnapshot,
              panelFocus: const RestaurantWorkspacePanelFocus(
                kind: RestaurantWorkspacePanelFocusKind.menuSignal,
                targetId: 'short-rib-rendang',
              ),
              actions: RestaurantWorkspacePanelActions(
                onReviewCatalogItem: reviewedIds.add,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(RestaurantMenuCatalogPanel), findsOneWidget);
    expect(find.text('Catalog readiness'), findsOneWidget);
    expect(find.text('Dinner - 5 items'), findsOneWidget);
    expect(find.text('3 need review'), findsOneWidget);
    expect(find.text('Grill station'), findsOneWidget);
    expect(find.text('Critical: 12 tickets'), findsOneWidget);
    expect(find.text('Cold Pass station'), findsOneWidget);
    expect(find.byType(RestaurantMenuSignalList), findsOneWidget);
    expect(
      tester
          .widget<RestaurantMenuSignalCard>(
            find.ancestor(
              of: find.text('Short Rib Rendang'),
              matching: find.byType(RestaurantMenuSignalCard),
            ),
          )
          .focused,
      isTrue,
    );

    await tester.ensureVisible(
      find.byTooltip('Review Nasi Ulam catalog readiness'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Review Nasi Ulam catalog readiness'));
    await tester.pumpAndSettle();

    expect(reviewedIds, ['nasi-ulam']);
  });

  testWidgets(
    'workspace panel deck focuses recipe production in kitchen panel',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RestaurantWorkspacePanelDeck(
                plan: RestaurantWorkspacePanelPlan.kitchen,
                snapshot: restaurantDemoSnapshot,
                panelFocus: const RestaurantWorkspacePanelFocus(
                  kind: RestaurantWorkspacePanelFocusKind.recipeProduction,
                  targetId: 'burnt-cheesecake',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RestaurantRecipeProductionPanel), findsOneWidget);
      expect(find.text('Recipe production'), findsOneWidget);
      expect(find.text('Burnt Cheesecake'), findsWidgets);

      final focusedTile = tester
          .widgetList<RestaurantRecipeProductionTile>(
            find.byType(RestaurantRecipeProductionTile),
          )
          .singleWhere((tile) => tile.entry.id == 'burnt-cheesecake');
      expect(focusedTile.focused, isTrue);
    },
  );
}

class _TestPanel extends StatelessWidget {
  const _TestPanel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 24, child: Text(label));
  }
}
