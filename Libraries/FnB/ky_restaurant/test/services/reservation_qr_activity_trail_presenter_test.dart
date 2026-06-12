import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR activity trail presenter builds row copy', () {
    const presenter = RestaurantReservationQrActivityTrailPresenter();

    final presentation = presenter.buildItem(
      RestaurantReservationQrSessionActivity.actionSelected(
        action: RestaurantReservationQrScanAction.confirmCheckIn,
        occurredAt: DateTime(2026, 6, 10, 9, 5),
      ),
    );

    expect(
      presentation.kind,
      RestaurantReservationQrSessionActivityKind.actionSelected,
    );
    expect(
      presentation.tone,
      RestaurantReservationQrSessionActivityTone.neutral,
    );
    expect(presentation.label, 'Confirm check-in selected');
    expect(presentation.detail, 'Confirm the arriving party.');
    expect(presentation.timeLabel, '09:05');
    expect(
      presentation.semanticsLabel,
      'Confirm check-in selected. Confirm the arriving party. Recorded at 09:05.',
    );
  });

  test('reservation QR activity trail presenter limits visible rows', () {
    const presenter = RestaurantReservationQrActivityTrailPresenter();
    final activities = [
      RestaurantReservationQrSessionActivity.sessionReset(
        occurredAt: DateTime(2026, 6, 10, 9),
      ),
      RestaurantReservationQrSessionActivity.scanCleared(
        occurredAt: DateTime(2026, 6, 10, 9, 1),
      ),
      RestaurantReservationQrSessionActivity.linkCleared(
        occurredAt: DateTime(2026, 6, 10, 9, 2),
      ),
    ];

    final visible = presenter.buildVisible(
      activities: activities,
      maxVisible: 2,
    );

    expect(visible, hasLength(2));
    expect(visible.first.label, 'QR session reset');
    expect(visible.last.label, 'Scan cleared');
  });
}
