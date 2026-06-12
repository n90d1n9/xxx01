import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test(
    'reservation status action plan separates primary and cautionary work',
    () {
      final plan = RestaurantReservationStatusActionPlan.fromActions(
        RestaurantReservationStatus.confirmed.nextActions,
      );

      expect(plan.hasActions, isTrue);
      expect(plan.primaryAction, RestaurantReservationStatusAction.markArrived);
      expect(plan.secondaryActions, [
        RestaurantReservationStatusAction.markNoShow,
      ]);
      expect(
        plan.orderedActions,
        RestaurantReservationStatus.confirmed.nextActions,
      );
      expect(RestaurantReservationStatusAction.markNoShow.isCautionary, isTrue);
      expect(
        RestaurantReservationStatusAction.markArrived.isCautionary,
        isFalse,
      );
    },
  );

  test(
    'reservation status action plan handles empty and caution-only actions',
    () {
      final emptyPlan = RestaurantReservationStatusActionPlan.fromActions([]);
      final cautionPlan = RestaurantReservationStatusActionPlan.fromActions([
        RestaurantReservationStatusAction.cancel,
      ]);

      expect(emptyPlan.hasActions, isFalse);
      expect(emptyPlan.primaryAction, isNull);
      expect(emptyPlan.secondaryActions, isEmpty);
      expect(cautionPlan.hasActions, isTrue);
      expect(cautionPlan.primaryAction, isNull);
      expect(cautionPlan.secondaryActions, [
        RestaurantReservationStatusAction.cancel,
      ]);
    },
  );
}
