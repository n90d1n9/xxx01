import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('adaptive grid column policy follows width breakpoints', () {
    expect(RestaurantAdaptiveGrid.columnsForWidth(420), 1);
    expect(RestaurantAdaptiveGrid.columnsForWidth(680), 2);
    expect(RestaurantAdaptiveGrid.columnsForWidth(1100), 4);
    expect(
      RestaurantAdaptiveGrid.columnsForWidth(
        980,
        wideBreakpoint: 980,
        mediumBreakpoint: 620,
      ),
      4,
    );
  });

  testWidgets('adaptive grid configures fixed-height card layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            child: RestaurantAdaptiveGrid(
              itemCount: 3,
              itemExtent: 88,
              spacing: 10,
              itemBuilder: (context, index) {
                return Text('Item $index');
              },
            ),
          ),
        ),
      ),
    );

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, 2);
    expect(delegate.mainAxisExtent, 88);
    expect(delegate.crossAxisSpacing, 10);
    expect(delegate.mainAxisSpacing, 10);
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
  });
}
