import 'package:dio/dio.dart';

class DioErrorUtil {
  // general methods:------------------------------------------------------------
  static String handleError(DioException error) {
    final method = error.requestOptions.method;
    final path = error.requestOptions.path;
    final status = error.response?.statusCode;
    final base = '[${error.type.name.toUpperCase()}] $method $path';

    String errorDescription = "";
    switch (error.type) {
      case DioExceptionType.cancel:
        errorDescription = '$base Request was cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        errorDescription = '$base Connection timeout';
        break;
      case DioExceptionType.unknown:
        if (error.error is FormatException) {
          errorDescription =
              '$base Invalid JSON in API response (status: ${status ?? 'unknown'})';
        } else {
          errorDescription =
              '$base Unexpected connection/runtime error: ${error.message ?? error.error}';
        }
        break;
      case DioExceptionType.receiveTimeout:
        errorDescription = '$base Receive timeout';
        break;
      case DioExceptionType.badResponse:
        errorDescription = '$base Received status code: $status';
        break;
      case DioExceptionType.sendTimeout:
        errorDescription = '$base Send timeout';
        break;
      default:
        errorDescription = '$base Unexpected error occurred';
        break;
    }

    final contentType = error.response?.headers.value('content-type');
    final bodyPreview = _preview(error.response?.data);
    if (status != null || contentType != null || bodyPreview != null) {
      errorDescription =
          '$errorDescription | status=$status | content-type=$contentType | body=$bodyPreview';
    }

    return errorDescription;
  }

  static String? _preview(dynamic data) {
    if (data == null) {
      return null;
    }
    final raw = data is String ? data : data.toString();
    final normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return null;
    }
    const maxLen = 200;
    return normalized.length <= maxLen
        ? normalized
        : '${normalized.substring(0, maxLen)}...';
  }
}
