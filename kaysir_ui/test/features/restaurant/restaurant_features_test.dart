import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/restaurant/restaurant_features.dart';
import 'package:ky_core/core/features/feature_routes.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('restaurant feature exposes workspace and child sidebar routes', () {
    final restaurant = RestaurantFeatures().registerScreens().single;
    final childPaths = restaurant.items.map((route) => route.path).toList();

    expect(restaurant.name, RestaurantRoutes.workspaceRouteName);
    expect(restaurant.title, 'Restaurant');
    expect(restaurant.icon, 'restaurant');
    expect(restaurant.path, RestaurantRoutes.workspacePath);
    expect(restaurant.position, contains(MenuPosition.sidebar));
    expect(restaurant.pageBuilder, isNotNull);
    expect(childPaths, [
      RestaurantRoutes.floorPath,
      RestaurantRoutes.reservationsPath,
      RestaurantRoutes.menuPath,
      RestaurantRoutes.kitchenPath,
    ]);
    expect(
      RestaurantRoutes.pathForView(RestaurantWorkspaceView.floor),
      RestaurantRoutes.floorPath,
    );

    for (final route in restaurant.items) {
      expect(route.position, contains(MenuPosition.sidebar));
      expect(route.pageBuilder, isNotNull, reason: '${route.title} route');
      expect(route.description, isNotEmpty, reason: '${route.title} metadata');
    }
  });
}
