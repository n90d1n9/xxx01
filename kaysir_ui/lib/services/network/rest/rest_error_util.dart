import 'package:dio/dio.dart';

class DioErrorUtil {
  // general methods:------------------------------------------------------------
  static String handleError(DioException error) {
    String errorDescription = "";
    switch (error.type) {
      case DioExceptionType.cancel:
        errorDescription = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        errorDescription = "Connection timeout with API server";
        break;
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        errorDescription =
            "Connection to API server failed due to internet connection";
        break;
      case DioExceptionType.receiveTimeout:
        errorDescription = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        errorDescription =
            statusCode == null
                ? "API server returned an invalid response"
                : "Received invalid status code: $statusCode";
        break;
      case DioExceptionType.sendTimeout:
        errorDescription = "Send timeout in connection with API server";
        break;
      case DioExceptionType.badCertificate:
        errorDescription = "API server certificate could not be verified";
        break;
    }
    return errorDescription;
  }

  static String safeMessage(
    Object? error, {
    String fallbackMessage = 'Something went wrong. Please try again.',
  }) {
    if (error is DioException) return handleError(error);

    final message = error?.toString().trim() ?? '';
    if (message.isEmpty) return fallbackMessage;
    if (_looksLikeRawDioMessage(message)) return fallbackMessage;

    const exceptionPrefix = 'Exception: ';
    if (message.startsWith(exceptionPrefix)) {
      final normalized = message.substring(exceptionPrefix.length).trim();
      return normalized.isEmpty ? fallbackMessage : normalized;
    }

    return message;
  }

  static bool _looksLikeRawDioMessage(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('dioexception') ||
        normalized.contains('dioerror') ||
        normalized.contains('requestoptions') ||
        normalized.contains('socketexception') ||
        normalized.contains('failed host lookup') ||
        normalized.contains('connection refused') ||
        normalized.contains('xmlhttprequest error');
  }
}
