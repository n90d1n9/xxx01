import '../model/cache_entry.dart';

/// Caching service for performance
class CacheService {
  final Map<String, CacheEntry> _cache = {};
  final Duration defaultTTL = const Duration(minutes: 5);

  void set(String key, dynamic data, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(ttl ?? defaultTTL),
    );
  }

  dynamic get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data;
  }

  void clear() => _cache.clear();
}
