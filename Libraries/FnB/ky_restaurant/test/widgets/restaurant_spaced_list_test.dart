import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  testWidgets('spaced list renders indexed items without trailing spacing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantSpacedList<String>(
          items: const ['A', 'B', 'A'],
          spacing: 7,
          itemBuilder: (context, item, index) => Text('$index:$item'),
        ),
      ),
    );

    expect(find.text('0:A'), findsOneWidget);
    expect(find.text('1:B'), findsOneWidget);
    expect(find.text('2:A'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 7,
      ),
      findsNWidgets(2),
    );
  });
}
