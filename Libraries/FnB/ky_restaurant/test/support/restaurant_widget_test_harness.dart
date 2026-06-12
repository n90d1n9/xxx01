import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

Future<void> pumpRestaurantPanel(WidgetTester tester, Widget panel) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: panel)),
    ),
  );
}

Future<void> pumpRestaurantViewSwitcher(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

Future<void> pumpRestaurantActionWorkspace(
  WidgetTester tester,
  RestaurantWorkspaceController controller, {
  required RestaurantWorkspaceView initialView,
  required List<RestaurantWorkspaceView> views,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RestaurantWorkspaceScreen(
        controller: controller,
        initialView: initialView,
        views: views,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> disposeRestaurantActionWorkspace(
  WidgetTester tester,
  RestaurantWorkspaceController controller,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  controller.dispose();
}
