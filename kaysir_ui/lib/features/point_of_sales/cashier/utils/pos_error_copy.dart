import 'package:kaysir/services/network/rest/rest_error_util.dart';

const posServiceUnavailableMessage =
    'Live service is unavailable. Check the connection and retry.';

const posLocalCatalogFallbackMessage =
    'Using local catalog while live products are unavailable.';

String friendlyPOSErrorMessage(
  Object? error, {
  String fallbackMessage = posServiceUnavailableMessage,
}) {
  final message = DioErrorUtil.safeMessage(
    error,
    fallbackMessage: fallbackMessage,
  );

  if (_looksLikeInfrastructureMessage(message)) return fallbackMessage;
  return message;
}

String friendlyPOSCatalogFallbackMessage(String? errorMessage) {
  final message = friendlyPOSErrorMessage(
    errorMessage,
    fallbackMessage: posLocalCatalogFallbackMessage,
  );

  if (message == posLocalCatalogFallbackMessage) {
    return posLocalCatalogFallbackMessage;
  }

  return 'Using local catalog: $message';
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
