import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_error_copy.dart';

void main() {
  test('friendly POS errors hide raw Dio exception strings', () {
    final message = friendlyPOSErrorMessage(
      'DioException [connection error]: Failed host lookup: api.local',
      fallbackMessage: 'Catalog unavailable.',
    );

    expect(message, 'Catalog unavailable.');
    expect(message, isNot(contains('DioException')));
  });

  test('friendly POS errors preserve business messages', () {
    final message = friendlyPOSErrorMessage(
      'Backend unavailable',
      fallbackMessage: 'Catalog unavailable.',
    );

    expect(message, 'Backend unavailable');
  });

  test('catalog fallback copy avoids technical network wording', () {
    final message = friendlyPOSCatalogFallbackMessage(
      'DioException [connection error]: Failed host lookup: api.local',
    );

    expect(message, posLocalCatalogFallbackMessage);
    expect(message, isNot(contains('DioException')));
    expect(message.toLowerCase(), isNot(contains('fallback')));
  });
}
