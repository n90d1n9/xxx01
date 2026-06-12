import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_error_copy.dart';

void main() {
  test('save failure copy hides raw Dio exception strings', () {
    final message = friendlyPOSOrderSaveFailureMessage(
      'DioException [connection error]: Failed host lookup: api.local',
    );

    expect(message, posOrderSaveFailureMessage);
    expect(message, isNot(contains('DioException')));
  });

  test('sync failure copy hides actual Dio exceptions', () {
    final message = friendlyPOSOrderSyncFailureMessage(
      DioException(
        requestOptions: RequestOptions(path: '/orders'),
        type: DioExceptionType.connectionError,
      ),
    );

    expect(message, posOrderSyncFailureMessage);
    expect(message, isNot(contains('DioException')));
    expect(message, isNot(contains('API server')));
  });

  test('order failure copy preserves plain operator messages', () {
    final message = friendlyPOSOrderSaveFailureMessage('offline');

    expect(message, 'offline');
  });
}
