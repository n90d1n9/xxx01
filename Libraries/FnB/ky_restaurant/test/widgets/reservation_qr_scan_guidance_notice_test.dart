import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR scan guidance notice renders host copy', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      const RestaurantReservationQrScanGuidanceNotice(
        guidance: RestaurantReservationQrScanGuidance(
          title: 'Generate a fresh QR',
          message: 'Refresh it before continuing.',
          tone: RestaurantReservationQrScanGuidanceTone.warning,
        ),
      ),
    );

    expect(find.text('Generate a fresh QR'), findsOneWidget);
    expect(find.text('Refresh it before continuing.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
