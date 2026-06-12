import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/services/network/rest/rest_error_util.dart';

void main() {
  DioException dioError(DioExceptionType type) {
    return DioException(
      requestOptions: RequestOptions(path: '/products'),
      type: type,
    );
  }

  test('connection errors are described as backend connectivity failures', () {
    final message = DioErrorUtil.handleError(
      dioError(DioExceptionType.connectionError),
    );

    expect(message, contains('Connection to API server failed'));
  });

  test('bad certificates get a specific message', () {
    final message = DioErrorUtil.handleError(
      dioError(DioExceptionType.badCertificate),
    );

    expect(message, contains('certificate'));
  });

  test('bad responses without status codes do not throw', () {
    final message = DioErrorUtil.handleError(
      dioError(DioExceptionType.badResponse),
    );

    expect(message, 'API server returned an invalid response');
  });

  test('safe messages hide raw Dio exception strings', () {
    final message = DioErrorUtil.safeMessage(
      'DioException [connection error]: Failed host lookup: api.local',
      fallbackMessage: 'Could not load data.',
    );

    expect(message, 'Could not load data.');
    expect(message, isNot(contains('DioException')));
  });

  test('safe messages keep plain business errors readable', () {
    final message = DioErrorUtil.safeMessage(
      Exception('Product SKU already exists.'),
      fallbackMessage: 'Could not save product.',
    );

    expect(message, 'Product SKU already exists.');
  });
}
