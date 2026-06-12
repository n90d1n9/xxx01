import 'package:kaysir/services/network/rest/rest_error_util.dart';

const posOrderSaveFailureMessage =
    'Order could not be saved online. It remains queued and can be retried.';

const posOrderSyncFailureMessage =
    'Queued orders could not sync. Check the connection and retry.';

String friendlyPOSOrderSaveFailureMessage(
  Object? error, {
  String fallbackMessage = posOrderSaveFailureMessage,
}) {
  return _friendlyPOSOrderFailureMessage(
    error,
    fallbackMessage: fallbackMessage,
  );
}

String friendlyPOSOrderSyncFailureMessage(
  Object? error, {
  String fallbackMessage = posOrderSyncFailureMessage,
}) {
  return _friendlyPOSOrderFailureMessage(
    error,
    fallbackMessage: fallbackMessage,
  );
}

String _friendlyPOSOrderFailureMessage(
  Object? error, {
  required String fallbackMessage,
}) {
  final message =
      DioErrorUtil.safeMessage(error, fallbackMessage: fallbackMessage).trim();
  if (message.isEmpty) return fallbackMessage;
  if (_looksLikeInfrastructureMessage(message)) return fallbackMessage;

  return message;
}

bool _looksLikeInfrastructureMessage(String message) {
  final normalized = message.toLowerCase();
  return normalized.contains('api server') ||
      normalized.contains('connection timeout') ||
      normalized.contains('receive timeout') ||
      normalized.contains('send timeout') ||
      normalized.contains('invalid status code') ||
      normalized.contains('failed host lookup') ||
      normalized.contains('connection refused');
}
