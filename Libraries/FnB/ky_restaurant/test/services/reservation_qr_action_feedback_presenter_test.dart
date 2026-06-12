import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test(
    'reservation QR action feedback presenter describes handled actions',
    () {
      const presenter = RestaurantReservationQrActionFeedbackPresenter();

      final presentation = presenter.build(
        RestaurantReservationQrActionHandlingResult.handled(
          RestaurantReservationQrScanAction.confirmCheckIn,
        ),
      );

      expect(presentation.title, 'Confirm check-in handled');
      expect(
        presentation.message,
        'Reservation workflow updated from QR scan.',
      );
      expect(
        presentation.semanticsLabel,
        'Confirm check-in handled. Reservation workflow updated from QR scan.',
      );
    },
  );

  test('reservation QR action feedback presenter preserves detail copy', () {
    const presenter = RestaurantReservationQrActionFeedbackPresenter();

    final pending = presenter.build(
      RestaurantReservationQrActionHandlingResult.pending(
        RestaurantReservationQrScanAction.joinWaitlist,
      ),
    );
    final failed = presenter.build(
      RestaurantReservationQrActionHandlingResult.failed(
        RestaurantReservationQrScanAction.joinWaitlist,
        detail: 'Reservation service offline.',
      ),
    );

    expect(pending.title, 'Join waitlist in progress');
    expect(pending.message, 'Keep this scan open while the workflow finishes.');
    expect(failed.title, 'Join waitlist failed');
    expect(failed.message, 'Reservation service offline.');
  });

  test('reservation QR action feedback presenter explains setup gaps', () {
    const presenter = RestaurantReservationQrActionFeedbackPresenter();

    final unavailable = presenter.build(
      RestaurantReservationQrActionHandlingResult.unavailable(null),
    );
    final missingId = presenter.build(
      RestaurantReservationQrActionHandlingResult.missingReservationId(
        RestaurantReservationQrScanAction.confirmCheckIn,
      ),
    );

    expect(unavailable.title, 'Action needs setup');
    expect(unavailable.message, 'No handler is configured for this QR action.');
    expect(missingId.title, 'Reservation id missing');
    expect(
      missingId.message,
      'A reservation id is required to confirm QR check-in.',
    );
  });
}
