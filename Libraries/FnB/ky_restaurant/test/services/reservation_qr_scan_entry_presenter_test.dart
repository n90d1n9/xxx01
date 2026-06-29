import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  group('reservation QR scan entry presenter', () {
    const presenter = RestaurantReservationQrScanEntryPresenter();

    test('normalizes typed values and enables submission', () {
      final presentation = presenter.build(
        value: '  https://tables.kaysir.test/qr?payload=encoded  ',
        enabled: true,
        hasSubmitHandler: true,
      );

      expect(
        presentation.normalizedValue,
        'https://tables.kaysir.test/qr?payload=encoded',
      );
      expect(presentation.hasValue, isTrue);
      expect(presentation.canSubmit, isTrue);
      expect(presentation.helperText, 'Ready to resolve this QR handoff.');
      expect(presentation.submitTooltip, 'Resolve this reservation QR scan');
    });

    test('describes the empty state', () {
      final presentation = presenter.build(
        value: '   ',
        enabled: true,
        hasSubmitHandler: true,
      );

      expect(presentation.normalizedValue, isEmpty);
      expect(presentation.hasValue, isFalse);
      expect(presentation.canSubmit, isFalse);
      expect(
        presentation.helperText,
        'Scan or paste a QR handoff link to resolve the guest action.',
      );
    });

    test('keeps disabled and unbound entries non-submittable', () {
      final disabled = presenter.build(
        value: 'https://tables.kaysir.test/qr?payload=encoded',
        enabled: false,
        hasSubmitHandler: true,
      );
      final unbound = presenter.build(
        value: 'https://tables.kaysir.test/qr?payload=encoded',
        enabled: true,
        hasSubmitHandler: false,
      );

      expect(disabled.canSubmit, isFalse);
      expect(
        disabled.helperText,
        'Scanning is paused for the current handoff.',
      );
      expect(unbound.canSubmit, isFalse);
      expect(
        unbound.helperText,
        'Connect a scan handler before resolving QR values.',
      );
    });
  });
}
