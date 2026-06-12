import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('service panel body renders pulse metric cards', (tester) async {
    await pumpRestaurantPanel(
      tester,
      RestaurantServicePanelBody(
        metrics: const [
          RestaurantServicePulseMetric(
            kind: RestaurantServicePulseMetricKind.floor,
            label: 'Floor pressure',
            value: '2 zones need attention',
            detail: 'Private Room is the top watch point.',
            status: RestaurantServiceStatus.critical,
          ),
          RestaurantServicePulseMetric(
            kind: RestaurantServicePulseMetricKind.menu,
            label: 'Menu spotlight',
            value: 'Short Rib Rendang',
            detail: '32 orders, 71% margin.',
            status: RestaurantServiceStatus.busy,
          ),
        ],
      ),
    );

    expect(find.text('Floor pressure'), findsOneWidget);
    expect(find.text('2 zones need attention'), findsOneWidget);
    expect(find.text('Menu spotlight'), findsOneWidget);
    expect(find.text('Short Rib Rendang'), findsOneWidget);
    expect(find.byType(RestaurantPulseMetricCard), findsNWidgets(2));
  });
}
