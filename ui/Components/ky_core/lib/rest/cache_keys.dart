import 'dart:convert';

class RestCacheKey {
  static String from({
    required String method,
    required String uri,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    String? prefix,
  }) {
    final qp = queryParameters == null
        ? ''
        : _encodeKeyPart(_sorted(queryParameters));
    final payload = body == null ? '' : _encodeKeyPart(body);
    final base = '$method|$uri|$qp|$payload';
    return prefix == null || prefix.isEmpty ? base : '$prefix:$base';
  }

  static String _encodeKeyPart(dynamic value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  static Map<String, dynamic> _sorted(Map<String, dynamic> map) {
    final keys = map.keys.toList()..sort();
    final sorted = <String, dynamic>{};
    for (final key in keys) {
      sorted[key] = map[key];
    }
    return sorted;
  }
}
