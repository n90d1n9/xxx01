import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/responsive_wrap_grid.dart';

void main() {
  testWidgets('ResponsiveWrapGrid applies column widths', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: ResponsiveWrapGrid(
              itemCount: 3,
              spacing: 20,
              columnsForWidth: (width) => width >= 480 ? 2 : 1,
              itemBuilder: (context, index, itemWidth) {
                return SizedBox(
                  key: ValueKey('responsive_grid_tile_$index'),
                  width: itemWidth,
                  height: 12,
                );
              },
            ),
          ),
        ),
      ),
    );

    final firstTile = tester.widget<SizedBox>(
      find.byKey(const ValueKey('responsive_grid_tile_0')),
    );

    expect(firstTile.width, closeTo(240, 0.01));
    expect(find.byType(ResponsiveWrapGrid), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ResponsiveWrapGrid stays quiet when empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResponsiveWrapGrid(
            itemCount: 0,
            columnsForWidth: (_) => 3,
            itemBuilder: (context, index, itemWidth) {
              return Text('$index:$itemWidth');
            },
          ),
        ),
      ),
    );

    expect(find.textContaining(':'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
