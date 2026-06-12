import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  testWidgets('workspace toolbar lays out controls horizontally when wide', (
    tester,
  ) async {
    await _pumpToolbar(tester, width: 560);

    final switcherTopLeft = tester.getTopLeft(
      find.byType(RestaurantViewSwitcher),
    );
    final refreshTopLeft = tester.getTopLeft(
      find.byType(RestaurantWorkspaceRefreshButton),
    );

    expect(refreshTopLeft.dx, greaterThan(switcherTopLeft.dx));
    expect(refreshTopLeft.dy, switcherTopLeft.dy);
    expect(tester.takeException(), isNull);
  });

  testWidgets('workspace toolbar stacks controls when compact', (tester) async {
    await _pumpToolbar(tester, width: 320);

    final switcherTopLeft = tester.getTopLeft(
      find.byType(RestaurantViewSwitcher),
    );
    final refreshTopLeft = tester.getTopLeft(
      find.byType(RestaurantWorkspaceRefreshButton),
    );

    expect(refreshTopLeft.dx, switcherTopLeft.dx);
    expect(refreshTopLeft.dy, greaterThan(switcherTopLeft.dy));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpToolbar(WidgetTester tester, {required double width}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: RestaurantWorkspaceToolbar(
            selectedView: RestaurantWorkspaceView.pulse,
            availableViews: RestaurantWorkspaceView.values,
            isRefreshing: false,
            onViewChanged: (_) {},
            onRefresh: () {},
          ),
        ),
      ),
    ),
  );
}
